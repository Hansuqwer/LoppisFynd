import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app/providers.dart';
import '../../core/tokens/app_tokens.dart';
import '../../gen/app_localizations.dart';
import '../../shared/widgets/glass_overlay.dart';

import 'email_otp_auth.dart';
import 'email_masking.dart';
import 'login_motif_layer.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.authOverride});

  final EmailOtpAuth? authOverride;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _emailFocus = FocusNode();
  final _codeFocus = FocusNode();
  bool _busy = false;
  bool _introShown = false;
  String? _lastEmailFromSettings;
  _LoginOtpStep _step = _LoginOtpStep.email;

  static const _kLastEmail = 'auth_last_email_v1';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _introShown = true);
    });

    () async {
      final db = ref.read(appDatabaseProvider);
      final last = (await db.appSettingsDao.getString(_kLastEmail))?.trim();
      if (last == null || last.isEmpty) return;
      if (!mounted) return;
      setState(() {
        _lastEmailFromSettings = last;
        _email.text = last;
      });
    }();
  }

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _emailFocus.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  Future<void> _persistEmailAttempt() async {
    final trimmed = _email.text.trim();
    final out = trimmed.isEmpty ? null : trimmed;
    final db = ref.read(appDatabaseProvider);
    await db.appSettingsDao.setString(_kLastEmail, out);
    if (!mounted) return;
    setState(() => _lastEmailFromSettings = out);
  }

  void _showErrorSnackBar(ScaffoldMessengerState messenger, String message) {
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  void _focusCodeFieldSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FocusScope.of(context).requestFocus(_codeFocus);
    });
  }

  void _focusEmailFieldSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FocusScope.of(context).requestFocus(_emailFocus);
    });
  }

  Future<void> _sendCode() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    if (_busy) return;

    await _persistEmailAttempt();
    final email = _email.text.trim();
    if (email.isEmpty) return;

    setState(() => _busy = true);
    try {
      final auth =
          widget.authOverride ??
          EmailOtpAuth.supabase(Supabase.instance.client);
      await auth.sendOtp(email);
      if (!mounted) return;
      setState(() {
        _step = _LoginOtpStep.code;
        _code.clear();
      });
      _focusCodeFieldSoon();
    } on AuthException catch (e) {
      _showErrorSnackBar(messenger, e.message);
    } on EmailOtpAuthException catch (e) {
      _showErrorSnackBar(
        messenger,
        e.message.isEmpty ? l10n.loginErrorGeneric : e.message,
      );
    } catch (_) {
      _showErrorSnackBar(messenger, l10n.loginErrorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verifyCode() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    if (_busy) return;

    await _persistEmailAttempt();
    final email = _email.text.trim();
    final code = _code.text.trim();
    if (email.isEmpty || code.length != 6) return;

    setState(() => _busy = true);
    try {
      final auth =
          widget.authOverride ??
          EmailOtpAuth.supabase(Supabase.instance.client);
      await auth.verifyOtp(email, code);
    } on AuthException catch (e) {
      _showErrorSnackBar(messenger, e.message);
    } on EmailOtpAuthException catch (e) {
      _showErrorSnackBar(
        messenger,
        e.message.isEmpty ? l10n.loginErrorGeneric : e.message,
      );
    } catch (_) {
      _showErrorSnackBar(messenger, l10n.loginErrorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _backToEmailStep() {
    if (_step == _LoginOtpStep.email) return;
    setState(() {
      _step = _LoginOtpStep.email;
      _code.clear();
    });
    _focusEmailFieldSoon();
  }

  void _continueAsLastEmail() {
    final last = _lastEmailFromSettings?.trim();
    if (last == null || last.isEmpty) return;
    if (_email.text.trim() != last) {
      _email.text = last;
      _email.selection = TextSelection.collapsed(offset: last.length);
    }
    _sendCode();
  }

  InputDecoration _pillInputDecoration({required String label}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.glassFill,
      labelStyle: const TextStyle(color: AppColors.textOnDark),
      floatingLabelStyle: const TextStyle(color: AppColors.textOnDark),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        borderSide: const BorderSide(color: AppColors.glassStroke),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        borderSide: const BorderSide(color: AppColors.textOnDark, width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final lastEmail = (_lastEmailFromSettings ?? '').trim();
    final showContinueAs = _step == _LoginOtpStep.email && lastEmail.isNotEmpty;
    final maskedLastEmail = showContinueAs ? maskEmailForUi(lastEmail) : '';

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('Assets/unnamed.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(child: Container(color: AppColors.heroScrim)),
          const Positioned.fill(child: LoginMotifLayer()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: AnimatedOpacity(
                    opacity: _introShown ? 1 : 0,
                    duration: AppMotion.spring,
                    curve: AppMotion.curve,
                    child: AnimatedSlide(
                      offset: _introShown ? Offset.zero : const Offset(0, 0.06),
                      duration: AppMotion.spring,
                      curve: AppMotion.curve,
                      child: AnimatedScale(
                        scale: _introShown ? 1 : 0.98,
                        duration: AppMotion.spring,
                        curve: AppMotion.curve,
                        child: GlassOverlay(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          blurSigma: 22,
                          fillColor: AppColors.glassFill.withAlpha(0x66),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.loginWelcome,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineLarge
                                    ?.copyWith(color: AppColors.textOnDark),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.glassStroke,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        'Assets/unnamed.jpg',
                                        fit: BoxFit.cover,
                                        alignment: const Alignment(0.35, -0.25),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Flexible(
                                    child: Text(
                                      l10n.loginAppName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: AppColors.textOnDark,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              TextField(
                                controller: _email,
                                focusNode: _emailFocus,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                readOnly: _step == _LoginOtpStep.code,
                                style: const TextStyle(
                                  color: AppColors.textOnDark,
                                ),
                                cursorColor: AppColors.textOnDark,
                                decoration: _pillInputDecoration(
                                  label: l10n.loginEmailLabel,
                                ),
                                onTap: _step == _LoginOtpStep.code
                                    ? _backToEmailStep
                                    : null,
                                onSubmitted: (_) {
                                  if (_step == _LoginOtpStep.email) {
                                    _sendCode();
                                  }
                                },
                                onChanged: (_) => setState(() {}),
                              ),
                              if (_step == _LoginOtpStep.code) ...[
                                const SizedBox(height: AppSpacing.md),
                                TextField(
                                  controller: _code,
                                  focusNode: _codeFocus,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [
                                    AutofillHints.oneTimeCode,
                                  ],
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(6),
                                  ],
                                  onSubmitted: (_) => _verifyCode(),
                                  style: const TextStyle(
                                    color: AppColors.textOnDark,
                                  ),
                                  cursorColor: AppColors.textOnDark,
                                  decoration: _pillInputDecoration(
                                    label: l10n.loginCodeLabel,
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ],
                              const SizedBox(height: AppSpacing.lg),
                              _LoginPillButton(
                                label: _busy
                                    ? l10n.loginWorking
                                    : switch (_step) {
                                        _LoginOtpStep.email =>
                                          l10n.loginSendCode,
                                        _LoginOtpStep.code => l10n.loginSignIn,
                                      },
                                tone: _LoginPillTone.primary,
                                onPressed: _busy
                                    ? null
                                    : switch (_step) {
                                        _LoginOtpStep.email => _sendCode,
                                        _LoginOtpStep.code => _verifyCode,
                                      },
                              ),
                              if (showContinueAs) ...[
                                const SizedBox(height: AppSpacing.md),
                                _LoginPillButton(
                                  label: l10n.loginContinueAs(maskedLastEmail),
                                  tone: _LoginPillTone.glass,
                                  onPressed: _busy
                                      ? null
                                      : _continueAsLastEmail,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _LoginOtpStep { email, code }

enum _LoginPillTone { primary, glass }

class _LoginPillButton extends StatefulWidget {
  const _LoginPillButton({
    required this.label,
    required this.tone,
    required this.onPressed,
  });

  final String label;
  final _LoginPillTone tone;
  final VoidCallback? onPressed;

  @override
  State<_LoginPillButton> createState() => _LoginPillButtonState();
}

class _LoginPillButtonState extends State<_LoginPillButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    final fg = AppColors.textOnPrimary;

    final decoration = switch (widget.tone) {
      _LoginPillTone.primary => BoxDecoration(
        color: enabled
            ? AppColors.primaryAction
            : AppColors.primaryAction.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: _pressed ? AppShadows.pressed : AppShadows.bento,
      ),
      _LoginPillTone.glass => BoxDecoration(
        color: enabled
            ? AppColors.glassFill
            : AppColors.glassFill.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.glassStroke),
        boxShadow: _pressed ? AppShadows.pressed : AppShadows.bento,
      ),
    };

    final child = AnimatedScale(
      duration: AppMotion.fast,
      curve: AppMotion.curve,
      scale: _pressed ? 0.985 : 1,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.curve,
        transform: Matrix4.identity()
          ..translateByDouble(0.0, _pressed ? 1.5 : 0.0, 0.0, 1.0),
        decoration: decoration,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            onTap: widget.onPressed,
            onTapDown: enabled ? (_) => _setPressed(true) : null,
            onTapUp: enabled ? (_) => _setPressed(false) : null,
            onTapCancel: enabled ? () => _setPressed(false) : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 54),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: fg),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.tone != _LoginPillTone.glass) return child;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: child,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app/providers.dart';
import '../../core/tokens/app_tokens.dart';
import '../../gen/app_localizations.dart';
import '../../shared/widgets/glass_overlay.dart';

import 'email_otp_auth.dart';
import 'login_motif_layer.dart';

String _formatAuthError(AppLocalizations l10n, AuthException e) {
  final msg = e.message.trim();
  if (msg.isNotEmpty) return msg;
  return l10n.loginErrorGeneric;
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.authOverride});

  final EmailOtpAuth? authOverride;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _busy = false;
  bool _introShown = false;
  String? _lastEmailFromSettings;
  _AuthMode _mode = _AuthMode.signUp;

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
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
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

  Future<void> _submitPasswordAuth() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    if (_busy) return;

    await _persistEmailAttempt();

    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar(messenger, l10n.loginErrorGeneric);
      return;
    }

    setState(() => _busy = true);
    try {
      final auth = Supabase.instance.client.auth;
      if (_mode == _AuthMode.signUp) {
        final response = await auth.signUp(email: email, password: password);
        final session = response.session ?? auth.currentSession;
        if (session == null) {
          if (!mounted) return;
          _showEmailConfirmationSheet(context);
        }
        return;
      }

      await auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      _showErrorSnackBar(messenger, _formatAuthError(l10n, e));
    } catch (e) {
      debugPrint('Auth error: $e');
      _showErrorSnackBar(messenger, l10n.loginErrorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showEmailConfirmationSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.authTroubleTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(l10n.authTroubleBody, style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }

  void _openTroubleOtpFlow() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return _TroubleOtpSheet(
          initialEmail: _email.text.trim().isEmpty
              ? (_lastEmailFromSettings ?? '')
              : _email.text.trim(),
          auth:
              widget.authOverride ??
              EmailOtpAuth.supabase(Supabase.instance.client),
          persistEmail: (email) async {
            _email.text = email;
            _email.selection = TextSelection.collapsed(offset: email.length);
            await _persistEmailAttempt();
          },
        );
      },
    );
  }

  InputDecoration _pillInputDecoration({required String label, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AppColors.glassFill,
      labelStyle: const TextStyle(color: AppColors.textPrimary),
      floatingLabelStyle: const TextStyle(color: AppColors.textPrimary),
      hintStyle: TextStyle(color: AppColors.textMuted),
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
                                    ?.copyWith(color: AppColors.textPrimary),
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
                                            color: AppColors.textPrimary,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              _AuthModeToggle(
                                mode: _mode,
                                onChanged: (m) => setState(() => _mode = m),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              TextField(
                                controller: _email,
                                focusNode: _emailFocus,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                                cursorColor: AppColors.textPrimary,
                                decoration: _pillInputDecoration(
                                  label: l10n.authEmailLabel,
                                  hint: l10n.authEmailHint,
                                ),
                                onSubmitted: (_) {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(_passwordFocus);
                                },
                              ),
                              const SizedBox(height: AppSpacing.md),
                              TextField(
                                controller: _password,
                                focusNode: _passwordFocus,
                                obscureText: true,
                                enableSuggestions: false,
                                autocorrect: false,
                                textInputAction: TextInputAction.done,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                                cursorColor: AppColors.textPrimary,
                                decoration: _pillInputDecoration(
                                  label: l10n.loginPasswordLabel,
                                ),
                                onSubmitted: (_) => _submitPasswordAuth(),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              _LoginPillButton(
                                label: _busy
                                    ? l10n.loginWorking
                                    : _mode == _AuthMode.signUp
                                    ? l10n.authCtaCreateAccount
                                    : l10n.authCtaSignIn,
                                tone: _LoginPillTone.primary,
                                onPressed: _busy
                                    ? null
                                    : () => _submitPasswordAuth(),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _LoginPillButton(
                                label: l10n.authTroubleLink,
                                tone: _LoginPillTone.glass,
                                onPressed: _busy ? null : _openTroubleOtpFlow,
                              ),
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

enum _AuthMode { signUp, signIn }

enum _LoginPillTone { primary, glass }

class _AuthModeToggle extends StatelessWidget {
  const _AuthModeToggle({required this.mode, required this.onChanged});

  final _AuthMode mode;
  final ValueChanged<_AuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selected = mode == _AuthMode.signUp ? 0 : 1;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        border: Border.all(color: AppColors.glassStroke),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeChip(
              label: l10n.authModeSignUp,
              selected: selected == 0,
              onTap: () => onChanged(_AuthMode.signUp),
            ),
          ),
          Expanded(
            child: _ModeChip(
              label: l10n.authModeSignIn,
              selected: selected == 1,
              onTap: () => onChanged(_AuthMode.signIn),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.curve,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryAction : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

enum _TroubleOtpStep { email, code }

class _TroubleOtpSheet extends StatefulWidget {
  const _TroubleOtpSheet({
    required this.initialEmail,
    required this.auth,
    required this.persistEmail,
  });

  final String initialEmail;
  final EmailOtpAuth auth;
  final Future<void> Function(String email) persistEmail;

  @override
  State<_TroubleOtpSheet> createState() => _TroubleOtpSheetState();
}

class _TroubleOtpSheetState extends State<_TroubleOtpSheet> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _codeFocus = FocusNode();
  bool _busy = false;
  _TroubleOtpStep _step = _TroubleOtpStep.email;

  @override
  void initState() {
    super.initState();
    _email.text = widget.initialEmail;
  }

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  void _focusCodeSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FocusScope.of(context).requestFocus(_codeFocus);
    });
  }

  Future<void> _sendCode() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    if (_busy) return;

    final email = _email.text.trim();
    if (email.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.loginErrorGeneric)));
      return;
    }

    setState(() => _busy = true);
    try {
      await widget.persistEmail(email);
      await widget.auth.sendOtp(email, shouldCreateUser: false);
      if (!mounted) return;
      setState(() {
        _step = _TroubleOtpStep.code;
        _code.clear();
      });
      _focusCodeSoon();
    } on AuthException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(_formatAuthError(l10n, e))),
      );
    } on EmailOtpAuthException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.loginErrorGeneric)));
    } catch (e) {
      debugPrint('Auth OTP send error: $e');
      messenger.showSnackBar(SnackBar(content: Text(l10n.loginErrorGeneric)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verifyCode() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    if (_busy) return;

    final email = _email.text.trim();
    final code = _code.text.trim();
    if (email.isEmpty || code.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.loginErrorGeneric)));
      return;
    }

    setState(() => _busy = true);
    try {
      await widget.persistEmail(email);
      await widget.auth.verifyOtp(email, code);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on AuthException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(_formatAuthError(l10n, e))),
      );
    } on EmailOtpAuthException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.loginErrorGeneric)));
    } catch (e) {
      debugPrint('Auth OTP verify error: $e');
      messenger.showSnackBar(SnackBar(content: Text(l10n.loginErrorGeneric)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  InputDecoration _pillInputDecoration({required String label, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AppColors.glassFill,
      labelStyle: const TextStyle(color: AppColors.textPrimary),
      floatingLabelStyle: const TextStyle(color: AppColors.textPrimary),
      hintStyle: TextStyle(color: AppColors.textMuted),
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
    final theme = Theme.of(context);
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg + bottomPad,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.authTroubleTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.authTroubleBody, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            readOnly: _step == _TroubleOtpStep.code,
            style: const TextStyle(color: AppColors.textPrimary),
            cursorColor: AppColors.textPrimary,
            decoration: _pillInputDecoration(
              label: l10n.authEmailLabel,
              hint: l10n.authEmailHint,
            ),
            onTap: _step == _TroubleOtpStep.code
                ? () => setState(() {
                    _step = _TroubleOtpStep.email;
                    _code.clear();
                  })
                : null,
            onSubmitted: (_) {
              if (_step == _TroubleOtpStep.email) _sendCode();
            },
          ),
          if (_step == _TroubleOtpStep.code) ...[
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _code,
              focusNode: _codeFocus,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.oneTimeCode],
              style: const TextStyle(color: AppColors.textPrimary),
              cursorColor: AppColors.textPrimary,
              decoration: _pillInputDecoration(label: l10n.authCodeLabel),
              onSubmitted: (_) => _verifyCode(),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          _LoginPillButton(
            label: _busy
                ? l10n.loginWorking
                : _step == _TroubleOtpStep.email
                ? l10n.loginSendCode
                : l10n.authVerify,
            tone: _LoginPillTone.primary,
            onPressed: _busy
                ? null
                : _step == _TroubleOtpStep.email
                ? _sendCode
                : _verifyCode,
          ),
          if (_step == _TroubleOtpStep.code) ...[
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: _busy ? null : _sendCode,
              child: Text(l10n.authResendCode),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

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

    final fg = widget.tone == _LoginPillTone.glass
        ? AppColors.textPrimary
        : AppColors.textOnPrimary;

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

    return GlassBackdrop(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      blurSigma: AppBlur.tileSigma,
      child: child,
    );
  }
}

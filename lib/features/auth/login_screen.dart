import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/tokens/app_tokens.dart';
import '../../shared/widgets/bento_card.dart';
import '../../shared/widgets/glass_button.dart';
import '../../shared/widgets/glass_overlay.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_busy) return;

    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) return;

    setState(() => _busy = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signUp() async {
    if (_busy) return;

    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) return;

    setState(() => _busy = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created. You can sign in now.')),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('Assets/unnamed.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(child: Container(color: AppColors.heroScrim)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Loppisfynd',
                    style: AppTypography.accentFrom(
                      Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: AppColors.textOnDark,
                          ) ??
                          const TextStyle(color: AppColors.textOnDark),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Scan. Decide. Flip.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textOnDark,
                    ),
                  ),
                  const Spacer(),
                  GlassOverlay(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Sign in',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textOnDark,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(labelText: 'Email'),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: _password,
                          obscureText: true,
                          onSubmitted: (_) => _signIn(),
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: GlassButton(
                                label: _busy ? 'Working…' : 'Sign in',
                                onPressed: _busy ? null : _signIn,
                                icon: const Icon(Icons.login_rounded),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: GlassButton(
                                label: 'Sign up',
                                tone: GlassButtonTone.neutral,
                                onPressed: _busy ? null : _signUp,
                                icon: const Icon(
                                  Icons.person_add_alt_1_rounded,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const BentoCard(
                    child: Text(
                      'Offline-first: scanning works without internet. Market data requires sync.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

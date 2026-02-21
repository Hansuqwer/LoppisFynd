import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app/providers.dart';
import '../auth/auth_gate.dart';
import 'onboarding_screen.dart';

class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = ref
        .watch(onboardingCompleteProvider)
        .maybeWhen(data: (v) => v, orElse: () => false);
    if (!done) {
      return const OnboardingScreen();
    }
    return const AuthGate();
  }
}

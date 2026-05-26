import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app/providers.dart';
import 'onboarding_gate.dart';

class DeepLinkGate extends ConsumerStatefulWidget {
  const DeepLinkGate({super.key, this.tabIndex, this.scanItemId});

  final int? tabIndex;
  final String? scanItemId;

  @override
  ConsumerState<DeepLinkGate> createState() => _DeepLinkGateState();
}

class _DeepLinkGateState extends ConsumerState<DeepLinkGate> {
  @override
  void initState() {
    super.initState();
    if (widget.tabIndex != null) {
      ref.read(deepLinkTabIndexProvider.notifier).state = widget.tabIndex;
    }
    if (widget.scanItemId != null) {
      ref.read(deepLinkScanItemIdProvider.notifier).state = widget.scanItemId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const OnboardingGate();
  }
}

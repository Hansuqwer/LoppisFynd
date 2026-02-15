import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/app/providers.dart';
import '../../core/navigation/spring_route.dart';
import '../../core/tokens/app_tokens.dart';
import '../../shared/widgets/bento_card.dart';
import '../../shared/widgets/glass_button.dart';
import '../../gen/app_localizations.dart';
import '../summary/haul_summary_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultHaulId = ref.watch(defaultHaulIdProvider);
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dashboardTitle,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(l10n.dashboardSubtitle),
              ],
            ),
          ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.08, end: 0),
          const SizedBox(height: AppSpacing.lg),
          GlassButton(
            label: l10n.dashboardQuickScan,
            icon: const Icon(Icons.camera_alt_rounded),
            onPressed: () {},
          ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.06, end: 0),
          const SizedBox(height: AppSpacing.sm),
          GlassButton(
            label: l10n.dashboardHaulSummary,
            tone: GlassButtonTone.neutral,
            icon: const Icon(Icons.assessment_rounded),
            onPressed: () {
              Navigator.of(context).push(
                SpringRoute(
                  builder: (_) => HaulSummaryScreen(haulId: defaultHaulId),
                ),
              );
            },
          ).animate().fadeIn(duration: 360.ms).slideY(begin: 0.06, end: 0),
        ],
      ),
    );
  }
}

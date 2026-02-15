import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app/providers.dart';
import '../../core/tokens/app_tokens.dart';
import '../../gen/app_localizations.dart';
import '../../shared/widgets/bento_card.dart';
import '../../shared/widgets/glass_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  var _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _setDone() async {
    final db = ref.read(appDatabaseProvider);
    await db.appSettingsDao.setInt('onboarding_complete', 1);
  }

  void _next() {
    _controller.nextPage(duration: AppMotion.normal, curve: AppMotion.curve);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final pages = <_OnboardingPageData>[
      _OnboardingPageData(
        title: l10n.onboardingWelcomeTitle,
        body: l10n.onboardingWelcomeBody,
        icon: Icons.auto_awesome_rounded,
      ),
      _OnboardingPageData(
        title: l10n.onboardingPermissionsTitle,
        body: l10n.onboardingPermissionsBody,
        icon: Icons.privacy_tip_rounded,
      ),
      _OnboardingPageData(
        title: l10n.onboardingOfflineTitle,
        body: l10n.onboardingOfflineBody,
        icon: Icons.offline_bolt_rounded,
      ),
    ];

    final isLast = _index == pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.appTitle,
                style: AppTypography.accentFrom(
                  Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                      ) ??
                      const TextStyle(color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final p = pages[i];
                    return BentoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.deepSapphire,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            alignment: Alignment.center,
                            child: Icon(p.icon, color: AppColors.textOnDark),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            p.title,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            p.body,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < pages.length; i++)
                    Container(
                      width: i == _index ? 18 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: i == _index
                            ? AppColors.atmosphericFog
                            : AppColors.borderSubtle,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              GlassButton(
                label: isLast ? l10n.onboardingStart : l10n.onboardingContinue,
                icon: Icon(
                  isLast
                      ? Icons.rocket_launch_rounded
                      : Icons.arrow_forward_rounded,
                ),
                onPressed: () async {
                  if (!isLast) {
                    _next();
                    return;
                  }
                  await _setDone();
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              if (!isLast)
                GlassButton(
                  label: l10n.onboardingSkip,
                  tone: GlassButtonTone.neutral,
                  onPressed: _setDone,
                  icon: const Icon(Icons.fast_forward_rounded),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;
}

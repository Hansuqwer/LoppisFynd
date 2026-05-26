import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app/providers.dart';
import '../../core/settings/app_settings_keys.dart';
import '../../core/tokens/app_tokens.dart';
import '../../gen/app_localizations.dart';
import '../../shared/widgets/bento_card.dart';
import '../../shared/widgets/cloud_identification_disclosure.dart';
import '../../shared/widgets/glass_button.dart';
import '../../shared/widgets/nature_background.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  PageController? _controller;
  var _index = 0;
  var _ready = false;

  static const _onboardingPageIndexKey = 'onboarding_page_index_v1';

  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() async {
      final db = ref.read(appDatabaseProvider);
      final savedIndex = await db.appSettingsDao.getInt(
        _onboardingPageIndexKey,
      );

      var initialIndex = savedIndex ?? 0;
      if (initialIndex < 0) initialIndex = 0;
      if (initialIndex > 2) initialIndex = 2;

      if (!mounted) return;
      setState(() {
        _index = initialIndex;
        _controller = PageController(initialPage: initialIndex);
        _ready = true;
      });

      if (!mounted) return;
      unawaited(_maybeShowCloudDisclosure());
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _setDone() async {
    final db = ref.read(appDatabaseProvider);
    await db.appSettingsDao.setInt('onboarding_complete', 1);
    await db.appSettingsDao.setInt(_onboardingPageIndexKey, 0);
  }

  Future<void> _setPageIndex(int index) async {
    final db = ref.read(appDatabaseProvider);
    await db.appSettingsDao.setInt(_onboardingPageIndexKey, index);
  }

  Future<void> _maybeShowCloudDisclosure() async {
    final db = ref.read(appDatabaseProvider);
    final existing =
        (await db.appSettingsDao.getInt(
          kCloudIdentificationDisclosureChoiceKeyV1,
        )) ??
        0;
    if (existing != 0) return;
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;

      final choice = await showCloudIdentificationDisclosure(
        context,
        l10n: l10n,
      );
      if (!mounted || choice == null) return;

      await db.appSettingsDao.setInt(
        kCloudIdentificationDisclosureChoiceKeyV1,
        choice,
      );
      if (choice == 1) {
        await db.appSettingsDao.setInt(
          kPrivacyCloudIdentificationEnabledKeyV1,
          1,
        );
      }
    });
  }

  void _next() {
    _controller?.nextPage(duration: AppMotion.normal, curve: AppMotion.curve);
  }

  void _previous() {
    _controller?.previousPage(
      duration: AppMotion.normal,
      curve: AppMotion.curve,
    );
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          const NatureBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.appTitle,
                    style: AppTypography.accentFrom(
                      Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: !_ready
                        ? const Center(child: CircularProgressIndicator())
                        : PageView.builder(
                            controller: _controller,
                            itemCount: pages.length,
                            onPageChanged: (i) {
                              setState(() => _index = i);
                              unawaited(_setPageIndex(i));
                            },
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
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.md,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        p.icon,
                                        color: AppColors.textOnDark,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Text(
                                      p.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      p.body,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ProgressDots(count: pages.length, index: _index),
                  const SizedBox(height: AppSpacing.md),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // On narrow portrait phones, the footer back button can
                      // become too tight for "Tillbaka" and ends up ellipsized.
                      // Give it a little more share of the row only in compact
                      // widths to preserve the reference density elsewhere.
                      final compactFooter = constraints.maxWidth < 340;
                      final backFlex = compactFooter ? 2 : 1;
                      final primaryFlex = compactFooter ? 3 : 2;

                      return Row(
                        children: [
                          if (_index > 0) ...[
                            Expanded(
                              flex: backFlex,
                              child: GlassButton(
                                label: l10n.onboardingBack,
                                tone: GlassButtonTone.neutral,
                                icon: const Icon(Icons.arrow_back_rounded),
                                onPressed: _previous,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          Expanded(
                            flex: primaryFlex,
                            child: GlassButton(
                              label: isLast
                                  ? l10n.onboardingStart
                                  : l10n.onboardingContinue,
                              icon: Icon(
                                isLast
                                    ? Icons.rocket_launch_rounded
                                    : Icons.arrow_forward_rounded,
                              ),
                              onPressed: !_ready
                                  ? null
                                  : (!isLast)
                                  ? _next
                                  : _setDone,
                            ),
                          ),
                        ],
                      );
                    },
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

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: AppMotion.fast,
            curve: AppMotion.curve,
            width: i == index ? 10 : 8,
            height: i == index ? 10 : 8,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == index
                  ? AppColors.atmosphericFog
                  : AppColors.borderSubtle,
            ),
          ),
      ],
    );
  }
}

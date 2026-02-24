import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/navigation/spring_route.dart';
import '../../core/tokens/app_tokens.dart';
import '../../gen/app_localizations.dart';
import '../../services/offline_detection/offline_model_catalog.dart';
import '../../shared/widgets/bento_card.dart';
import '../../shared/widgets/glass_button.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.legalTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            BentoCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.legalLicensesTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.legalLicensesSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GlassButton(
                    label: l10n.legalThirdPartyLicenses,
                    icon: const Icon(Icons.article_outlined),
                    onPressed: () {
                      showLicensePage(
                        context: context,
                        applicationName: l10n.appTitle,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GlassButton(
                    label: l10n.legalOfflineModelLicenses,
                    tone: GlassButtonTone.neutral,
                    icon: const Icon(Icons.memory_outlined),
                    onPressed: () {
                      Navigator.of(context).push(
                        SpringRoute(
                          builder: (_) => const OfflineModelLicensesScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OfflineModelLicensesScreen extends StatelessWidget {
  const OfflineModelLicensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spec = kOfflineDetectionModel;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.legalOfflineModelLicensesTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            BentoCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spec.displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.legalOfflineModelSize(spec.sizeLabel),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.settingsOfflineAttributionSummary,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _OfflineLicenseCard(
              title: l10n.legalOfflineLicenseRuntimeTitle,
              summary: l10n.legalOfflineLicenseRuntimeSummary,
              sourceUrl: spec.runtimeLicenseSourceUrl,
              onViewFullText: () {
                Navigator.of(context).push(
                  SpringRoute(
                    builder: (_) => LicenseTextScreen(
                      title: l10n.legalOfflineLicenseRuntimeTitle,
                      sourceUrl: spec.runtimeLicenseSourceUrl,
                      text: spec.runtimeLicenseFullText,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _OfflineLicenseCard(
              title: l10n.legalOfflineLicenseWeightsTitle,
              summary: l10n.legalOfflineLicenseWeightsSummary,
              sourceUrl: spec.weightsLicenseSourceUrl,
              onViewFullText: () {
                Navigator.of(context).push(
                  SpringRoute(
                    builder: (_) => LicenseTextScreen(
                      title: l10n.legalOfflineLicenseWeightsTitle,
                      sourceUrl: spec.weightsLicenseSourceUrl,
                      text: spec.weightsLicenseFullText,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _OfflineLicenseCard(
              title: l10n.legalOfflineLicenseDatasetTitle,
              summary: l10n.legalOfflineLicenseDatasetSummary,
              sourceUrl: spec.datasetAttributionSourceUrl,
              onViewFullText: () {
                Navigator.of(context).push(
                  SpringRoute(
                    builder: (_) => LicenseTextScreen(
                      title: l10n.legalOfflineLicenseDatasetTitle,
                      sourceUrl: spec.datasetAttributionSourceUrl,
                      text: spec.datasetAttributionFullText,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineLicenseCard extends StatelessWidget {
  const _OfflineLicenseCard({
    required this.title,
    required this.summary,
    required this.sourceUrl,
    required this.onViewFullText,
  });

  final String title;
  final String summary;
  final Uri sourceUrl;
  final VoidCallback onViewFullText;

  Future<void> _copy(BuildContext context, String text) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.commonCopied)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final source = sourceUrl.toString();

    return BentoCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(summary, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.legalSourceUrlLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    SelectableText(
                      source,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.legalCopySourceUrl,
                onPressed: () => _copy(context, source),
                icon: const Icon(Icons.copy_all_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          GlassButton(
            label: l10n.legalViewFullLicenseText,
            tone: GlassButtonTone.neutral,
            icon: const Icon(Icons.description_outlined),
            onPressed: onViewFullText,
          ),
        ],
      ),
    );
  }
}

class LicenseTextScreen extends StatelessWidget {
  const LicenseTextScreen({
    super.key,
    required this.title,
    required this.sourceUrl,
    required this.text,
  });

  final String title;
  final Uri sourceUrl;
  final String text;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              l10n.legalSourceUrlLabel,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.xxs),
            SelectableText(
              sourceUrl.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            SelectableText(text, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

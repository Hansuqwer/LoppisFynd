import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app/providers.dart';
import '../../core/navigation/spring_route.dart';
import '../../core/tokens/app_tokens.dart';
import '../../gen/app_localizations.dart';
import '../../shared/widgets/bento_card.dart';
import '../../shared/widgets/glass_button.dart';
import 'account_deletion_screen.dart';
import 'privacy_policy_screen.dart';
import 'settings_providers.dart';

class PrivacyScreen extends ConsumerStatefulWidget {
  const PrivacyScreen({super.key});

  @override
  ConsumerState<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends ConsumerState<PrivacyScreen> {
  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  void _exportJson() => ref.read(exportDataProvider.notifier).exportJson();

  void _exportCsv() => ref.read(exportDataProvider.notifier).exportCsv();

  Future<bool> _confirm({required String title, required String body}) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.commonDelete),
            ),
          ],
        );
      },
    );
    return ok == true;
  }

  Future<void> _deleteLocal() async {
    final ok = await _confirm(
      title: AppLocalizations.of(context)!.privacyDeleteLocalTitle,
      body: AppLocalizations.of(context)!.privacyDeleteLocalBody,
    );
    if (!ok) return;
    ref.read(deleteLocalDataProvider.notifier).run();
  }

  Future<void> _deleteCloud() async {
    final ok = await _confirm(
      title: AppLocalizations.of(context)!.privacyDeleteCloudTitle,
      body: AppLocalizations.of(context)!.privacyDeleteCloudBody,
    );
    if (!ok) return;
    ref.read(deleteCloudDataProvider.notifier).run();
  }

  void _clearScanCache() =>
      ref.read(clearScanCacheProvider.notifier).run();

  void _copyDiagnostics() =>
      ref.read(copyDiagnosticsProvider.notifier).run();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final config = ref.watch(appConfigProvider);
    final userId = ref.watch(activeUserIdProvider);
    final exportState = ref.watch(exportDataProvider);
    final deleteLocalState = ref.watch(deleteLocalDataProvider);
    final deleteCloudState = ref.watch(deleteCloudDataProvider);
    final clearCacheState = ref.watch(clearScanCacheProvider);
    final copyDiagState = ref.watch(copyDiagnosticsProvider);

    final exporting = exportState.isLoading;
    final deletingLocal = deleteLocalState.isLoading;
    final deletingCloud = deleteCloudState.isLoading;
    final clearingCache = clearCacheState.isLoading;
    final copyingDiagnostics = copyDiagState.isLoading;

    ref.listen(exportDataProvider, (prev, next) {
      if (prev?.isLoading ?? false) {
        next.whenOrNull(
          data: (path) {
            if (path.isNotEmpty) {
              _copy(path);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.privacyExportedPathCopied(path))),
            );
          },
          error: (e, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.privacyExportFailed('$e'))),
            );
          },
        );
      }
    });

    ref.listen(deleteLocalDataProvider, (prev, next) {
      if (prev?.isLoading ?? false) {
        next.whenOrNull(
          data: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.privacyDeleteLocalDone)),
            );
          },
          error: (e, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.privacyDeleteFailed('$e'))),
            );
          },
        );
      }
    });

    ref.listen(deleteCloudDataProvider, (prev, next) {
      if (prev?.isLoading ?? false) {
        next.whenOrNull(
          data: (outcome) {
            if (outcome != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.privacyDeleteCloudDone(
                      outcome.deletedScanItems,
                      outcome.deletedHauls,
                      outcome.deletedStorageObjects,
                    ),
                  ),
                ),
              );
            }
          },
          error: (e, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.privacyDeleteFailed('$e'))),
            );
          },
        );
      }
    });

    ref.listen(clearScanCacheProvider, (prev, next) {
      if (prev?.isLoading ?? false) {
        next.whenOrNull(
          data: (deleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.privacyCacheCleared(deleted))),
            );
          },
          error: (e, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.privacyCacheClearFailed('$e'))),
            );
          },
        );
      }
    });

    ref.listen(copyDiagnosticsProvider, (prev, next) {
      if (prev?.isLoading ?? false) {
        next.whenOrNull(
          data: (text) {
            if (text.isNotEmpty) {
              _copy(text);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.privacyDiagnosticsCopied)),
            );
          },
          error: (e, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.privacyDiagnosticsCopyFailed('$e'))),
            );
          },
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            BentoCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.privacyPolicyTitle,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.privacyPolicyCopy,
                        onPressed: () async {
                          await _copy(l10n.privacyPolicyBody);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.privacyPolicyCopied)),
                          );
                        },
                        icon: const Icon(Icons.copy_all_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.privacyPolicySubtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GlassButton(
                    label: l10n.privacyPolicyOpen,
                    tone: GlassButtonTone.neutral,
                    icon: const Icon(Icons.description_outlined),
                    onPressed: () {
                      Navigator.of(context).push(
                        SpringRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            BentoCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.privacyToolsTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.privacyToolsBody,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GlassButton(
                    label: clearingCache
                        ? l10n.privacyClearing
                        : l10n.privacyClearScanCache,
                    tone: GlassButtonTone.neutral,
                    icon: const Icon(Icons.delete_sweep_rounded),
                    onPressed: clearingCache ? null : _clearScanCache,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GlassButton(
                    label: copyingDiagnostics
                        ? l10n.privacyCopying
                        : l10n.privacyCopyDiagnostics,
                    tone: GlassButtonTone.neutral,
                    icon: const Icon(Icons.bug_report_outlined),
                    onPressed: copyingDiagnostics ? null : _copyDiagnostics,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            BentoCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.privacyStorageTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    config.hasSupabase
                        ? l10n.privacyStorageBodyCloud
                        : l10n.privacyStorageBodyLocalOnly,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            BentoCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.privacyExportTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.privacyExportBody,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: GlassButton(
                          label: exporting
                              ? l10n.privacyExporting
                              : l10n.privacyExportJson,
                          icon: const Icon(Icons.data_object_rounded),
                          onPressed: exporting ? null : _exportJson,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: GlassButton(
                          label: exporting
                              ? l10n.privacyExporting
                              : l10n.privacyExportCsv,
                          tone: GlassButtonTone.neutral,
                          icon: const Icon(Icons.table_rows_rounded),
                          onPressed: exporting ? null : _exportCsv,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            BentoCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.privacyDeleteTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.privacyDeleteBody,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GlassButton(
                    label: deletingLocal
                        ? l10n.privacyDeleting
                        : l10n.privacyDeleteLocalCta,
                    icon: const Icon(Icons.delete_forever_rounded),
                    onPressed: deletingLocal ? null : _deleteLocal,
                  ),
                  if (config.hasSupabase && userId != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    GlassButton(
                      label: deletingCloud
                          ? l10n.privacyDeleting
                          : l10n.privacyDeleteCloudCta,
                      tone: GlassButtonTone.neutral,
                      icon: const Icon(Icons.cloud_off_rounded),
                      onPressed: deletingCloud ? null : _deleteCloud,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    GlassButton(
                      label: l10n.privacyDeleteAccountCta,
                      tone: GlassButtonTone.neutral,
                      icon: const Icon(Icons.person_off_rounded),
                      onPressed: () {
                        Navigator.of(context).push(
                          SpringRoute(
                            builder: (_) => const AccountDeletionScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

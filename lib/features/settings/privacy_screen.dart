import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/app/providers.dart';
import '../../core/navigation/spring_route.dart';
import '../../core/tokens/app_tokens.dart';
import '../../gen/app_localizations.dart';
import '../../services/privacy/cloud_data_deletion_service.dart';
import '../../services/privacy/data_export_service.dart';
import '../../services/privacy/local_data_deletion_service.dart';
import '../../shared/widgets/bento_card.dart';
import '../../shared/widgets/glass_button.dart';
import 'account_deletion_screen.dart';
import 'privacy_policy_screen.dart';

class PrivacyScreen extends ConsumerStatefulWidget {
  const PrivacyScreen({super.key});

  @override
  ConsumerState<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends ConsumerState<PrivacyScreen> {
  bool _exporting = false;
  bool _deletingLocal = false;
  bool _deletingCloud = false;
  bool _clearingCache = false;
  bool _copyingDiagnostics = false;

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  Future<void> _exportJson() async {
    if (_exporting) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _exporting = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final userId = ref.read(activeUserIdProvider);
      final file = await DataExportService().exportJson(db: db, userId: userId);
      await _copy(file.path);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.privacyExportedPathCopied(file.path))),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.privacyExportFailed('$e'))),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportCsv() async {
    if (_exporting) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _exporting = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final userId = ref.read(activeUserIdProvider);
      final file = await DataExportService().exportCsv(db: db, userId: userId);
      await _copy(file.path);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.privacyExportedPathCopied(file.path))),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.privacyExportFailed('$e'))),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

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
    if (_deletingLocal) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    final ok = await _confirm(
      title: l10n.privacyDeleteLocalTitle,
      body: l10n.privacyDeleteLocalBody,
    );
    if (!ok) return;

    setState(() => _deletingLocal = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final userId = ref.read(activeUserIdProvider);
      final haulId = ref.read(defaultHaulIdProvider);
      await LocalDataDeletionService(db: db).deleteAllLocalData(userId: userId);
      await db.haulsDao.ensureCurrentHaul(
        id: haulId,
        title: l10n.haulTitle,
        userId: userId,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.privacyDeleteLocalDone)),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.privacyDeleteFailed('$e'))),
      );
    } finally {
      if (mounted) setState(() => _deletingLocal = false);
    }
  }

  Future<void> _deleteCloud() async {
    if (_deletingCloud) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final config = ref.read(appConfigProvider);

    final ok = await _confirm(
      title: l10n.privacyDeleteCloudTitle,
      body: l10n.privacyDeleteCloudBody,
    );
    if (!ok) return;

    setState(() => _deletingCloud = true);
    try {
      final outcome = await CloudDataDeletionService(
        config: config,
      ).deleteAllCloudData();
      if (!mounted) return;
      messenger.showSnackBar(
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
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.privacyDeleteFailed('$e'))),
      );
    } finally {
      if (mounted) setState(() => _deletingCloud = false);
    }
  }

  Future<void> _clearScanCache() async {
    if (_clearingCache) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final db = ref.read(appDatabaseProvider);
    final userId = ref.read(activeUserIdProvider);

    setState(() => _clearingCache = true);
    try {
      final items = await db.scanItemsDao.listAll(userId: userId);
      final itemIds = items.map((it) => it.id).toList(growable: false);

      final deleted = itemIds.length;
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.privacyCacheCleared(deleted))),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.privacyCacheClearFailed('$e'))),
      );
    } finally {
      if (mounted) setState(() => _clearingCache = false);
    }
  }

  Future<void> _copyDiagnostics() async {
    if (_copyingDiagnostics) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final config = ref.read(appConfigProvider);
    final userId = ref.read(activeUserIdProvider);

    setState(() => _copyingDiagnostics = true);
    try {
      final info = await PackageInfo.fromPlatform();
      final text = [
        'app=${info.appName}',
        'package=${info.packageName}',
        'version=${info.version}+${info.buildNumber}',
        'env=${config.appEnv}',
        'hasSupabase=${config.hasSupabase}',
        'hasTraderaProxy=${config.hasTraderaProxy}',
        'userScope=${userId ?? 'guest'}',
      ].join('\n');

      await _copy(text);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.privacyDiagnosticsCopied)),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.privacyDiagnosticsCopyFailed('$e'))),
      );
    } finally {
      if (mounted) setState(() => _copyingDiagnostics = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final config = ref.watch(appConfigProvider);
    final userId = ref.watch(activeUserIdProvider);

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
                    label: _clearingCache
                        ? l10n.privacyClearing
                        : l10n.privacyClearScanCache,
                    tone: GlassButtonTone.neutral,
                    icon: const Icon(Icons.delete_sweep_rounded),
                    onPressed: _clearingCache ? null : _clearScanCache,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GlassButton(
                    label: _copyingDiagnostics
                        ? l10n.privacyCopying
                        : l10n.privacyCopyDiagnostics,
                    tone: GlassButtonTone.neutral,
                    icon: const Icon(Icons.bug_report_outlined),
                    onPressed: _copyingDiagnostics ? null : _copyDiagnostics,
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
                          label: _exporting
                              ? l10n.privacyExporting
                              : l10n.privacyExportJson,
                          icon: const Icon(Icons.data_object_rounded),
                          onPressed: _exporting ? null : _exportJson,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: GlassButton(
                          label: _exporting
                              ? l10n.privacyExporting
                              : l10n.privacyExportCsv,
                          tone: GlassButtonTone.neutral,
                          icon: const Icon(Icons.table_rows_rounded),
                          onPressed: _exporting ? null : _exportCsv,
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
                    label: _deletingLocal
                        ? l10n.privacyDeleting
                        : l10n.privacyDeleteLocalCta,
                    icon: const Icon(Icons.delete_forever_rounded),
                    onPressed: _deletingLocal ? null : _deleteLocal,
                  ),
                  if (config.hasSupabase && userId != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    GlassButton(
                      label: _deletingCloud
                          ? l10n.privacyDeleting
                          : l10n.privacyDeleteCloudCta,
                      tone: GlassButtonTone.neutral,
                      icon: const Icon(Icons.cloud_off_rounded),
                      onPressed: _deletingCloud ? null : _deleteCloud,
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

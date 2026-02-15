import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app/providers.dart';
import '../../core/tokens/app_tokens.dart';
import '../../shared/widgets/bento_card.dart';
import '../../shared/widgets/glass_button.dart';
import '../../services/ai/model_manager.dart';
import '../../services/sync/cloud_photo_sync_service.dart';
import '../../services/sync/cloud_metadata_sync_service.dart';
import '../../services/sync/background/background_sync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../gen/app_localizations.dart';

class _ModelInfo {
  const _ModelInfo({required this.state, required this.file});

  final ModelInstallState state;
  final File file;
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _sourcePathController = TextEditingController();
  String? _installError;
  bool _syncing = false;
  bool _cloudSyncing = false;
  bool _cloudPhotoSyncing = false;
  bool _modelDownloading = false;

  static const _kSyncIntervalHours = 'market_sync_interval_hours';
  static const _kHighContrastEnabled = 'high_contrast_enabled';

  Future<_ModelInfo> _loadModelInfo(ModelManager modelManager) async {
    final state = await modelManager.state();
    final file = await modelManager.modelFile();
    return _ModelInfo(state: state, file: file);
  }

  @override
  void dispose() {
    _sourcePathController.dispose();
    super.dispose();
  }

  Future<void> _installFromPath() async {
    final modelManager = ref.read(modelManagerProvider);
    final sourcePath = _sourcePathController.text.trim();
    if (sourcePath.isEmpty) return;

    try {
      setState(() => _installError = null);
      await modelManager.installFromFile(source: File(sourcePath));
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() => _installError = '$e');
    }
  }

  Future<void> _downloadModel() async {
    if (_modelDownloading) return;
    final config = ref.read(appConfigProvider);
    final modelManager = ref.read(modelManagerProvider);
    if (!config.hasGemmaModelUrl) return;

    setState(() => _modelDownloading = true);
    try {
      setState(() => _installError = null);
      await modelManager.downloadFromUrl(url: Uri.parse(config.gemmaModelUrl));
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() => _installError = '$e');
    } finally {
      if (mounted) setState(() => _modelDownloading = false);
    }
  }

  Future<void> _syncNow() async {
    if (_syncing) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _syncing = true);
    try {
      final syncScheduler = ref.read(syncSchedulerProvider);
      await syncScheduler.syncOnce();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.settingsMarketSyncCompleted)));
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsMarketSyncFailed('$e'))),
      );
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _cloudSyncNow() async {
    if (_cloudSyncing) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _cloudSyncing = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final config = ref.read(appConfigProvider);
      final service = CloudMetadataSyncService(db: db, config: config);
      await service.syncBidirectional();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.settingsCloudSyncCompleted)));
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsCloudSyncFailed('$e'))),
      );
    } finally {
      if (mounted) setState(() => _cloudSyncing = false);
    }
  }

  Future<void> _cloudPhotoSyncNow() async {
    if (_cloudPhotoSyncing) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _cloudPhotoSyncing = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final config = ref.read(appConfigProvider);
      final imageStorage = ref.read(scanImageStorageProvider);
      final service = CloudPhotoSyncService(
        db: db,
        config: config,
        imageStorage: imageStorage,
      );
      await service.syncBidirectional();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.settingsPhotoSyncCompleted)));
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsPhotoSyncFailed('$e'))),
      );
    } finally {
      if (mounted) setState(() => _cloudPhotoSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final config = ref.watch(appConfigProvider);
    final modelManager = ref.watch(modelManagerProvider);
    final highContrast = ref
        .watch(highContrastEnabledProvider)
        .maybeWhen(data: (v) => v, orElse: () => false);
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
                  l10n.settingsAccessibility,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.settingsHighContrast),
                  value: highContrast,
                  onChanged: (v) async {
                    final messenger = ScaffoldMessenger.of(context);
                    await db.appSettingsDao.setInt(
                      _kHighContrastEnabled,
                      v ? 1 : 0,
                    );
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.settingsContrastUpdated)),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsMarketSyncTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  config.hasTraderaProxy
                      ? l10n.settingsTraderaProxyConfigured
                      : l10n.settingsTraderaProxyNotConfigured,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.settingsTraderaProxyRunWith(
                    '--dart-define=TRADERA_PROXY_URL=https://<project>.supabase.co/functions/v1/tradera-proxy',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                FutureBuilder<int?>(
                  future: db.appSettingsDao.getInt(_kSyncIntervalHours),
                  builder: (context, snapshot) {
                    final current = snapshot.data ?? 6;
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.settingsBackgroundInterval,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        DropdownButton<int>(
                          value: current,
                          items: [
                            DropdownMenuItem(
                              value: 0,
                              child: Text(l10n.commonOff),
                            ),
                            DropdownMenuItem(
                              value: 1,
                              child: Text(l10n.settingsInterval1h),
                            ),
                            DropdownMenuItem(
                              value: 6,
                              child: Text(l10n.settingsInterval6h),
                            ),
                            DropdownMenuItem(
                              value: 24,
                              child: Text(l10n.settingsInterval24h),
                            ),
                          ],
                          onChanged: !config.hasTraderaProxy
                              ? null
                              : (v) async {
                                  if (v == null) return;
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  await db.appSettingsDao.setInt(
                                    _kSyncIntervalHours,
                                    v,
                                  );
                                  await BackgroundSync.scheduleIfConfigured(
                                    db: db,
                                  );
                                  if (!mounted) return;
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l10n.settingsSavedSyncInterval,
                                      ),
                                    ),
                                  );
                                  setState(() {});
                                },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                FutureBuilder<int?>(
                  future: db.syncQuotasDao.getUsed(_todayKey()),
                  builder: (context, snapshot) {
                    final used = snapshot.data;
                    return Text(
                      used == null
                          ? l10n.settingsQuotaUnknown
                          : l10n.settingsQuotaUsedToday(used),
                      style: Theme.of(context).textTheme.bodyMedium,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                GlassButton(
                  label: _syncing ? l10n.settingsSyncing : l10n.settingsSyncNow,
                  onPressed: _syncing ? null : _syncNow,
                  icon: const Icon(Icons.sync_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsCloudSyncTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  config.hasSupabase
                      ? l10n.settingsSupabaseConfigured
                      : l10n.settingsSupabaseNotConfigured,
                ),
                const SizedBox(height: AppSpacing.xs),
                if (config.hasSupabase)
                  Text(
                    Supabase.instance.client.auth.currentUser?.email == null
                        ? l10n.settingsNotSignedIn
                        : l10n.settingsSignedInAs(
                            Supabase.instance.client.auth.currentUser!.email!,
                          ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                const SizedBox(height: AppSpacing.md),
                GlassButton(
                  label: _cloudSyncing
                      ? l10n.settingsSyncing
                      : l10n.settingsSyncMetadata,
                  onPressed: _cloudSyncing ? null : _cloudSyncNow,
                  icon: const Icon(Icons.cloud_done_rounded),
                ),
                const SizedBox(height: AppSpacing.sm),
                GlassButton(
                  label: _cloudPhotoSyncing
                      ? l10n.settingsSyncing
                      : l10n.settingsSyncPhotos,
                  onPressed: _cloudPhotoSyncing ? null : _cloudPhotoSyncNow,
                  tone: GlassButtonTone.neutral,
                  icon: const Icon(Icons.photo_library_outlined),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FutureBuilder(
            future: _loadModelInfo(modelManager),
            builder: (context, snapshot) {
              final info = snapshot.data;

              return BentoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsOnDeviceModelTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      info == null
                          ? l10n.settingsModelChecking
                          : info.state.installed
                          ? l10n.settingsModelInstalled(info.state.bytes ?? 0)
                          : l10n.settingsModelNotInstalled,
                    ),
                    if (info != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.settingsModelExpectedPath(info.file.path),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    if (config.hasGemmaModelUrl) ...[
                      GlassButton(
                        label: _modelDownloading
                            ? l10n.settingsDownloading
                            : l10n.settingsDownloadModel,
                        onPressed: _modelDownloading ? null : _downloadModel,
                        icon: const Icon(Icons.cloud_download_rounded),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    TextField(
                      controller: _sourcePathController,
                      decoration: InputDecoration(
                        labelText: l10n.settingsInstallFromFilePathLabel,
                        hintText: l10n.settingsInstallFromFilePathHint,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        GlassButton(
                          label: l10n.commonInstall,
                          onPressed: _installFromPath,
                          icon: const Icon(Icons.download_rounded),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        GlassButton(
                          label: l10n.commonDelete,
                          tone: GlassButtonTone.neutral,
                          onPressed: () async {
                            await modelManager.deleteInstalled();
                            if (!mounted) return;
                            setState(() {});
                          },
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
                    ),
                    if (_installError != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _installError!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primaryAction,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

String _todayKey() {
  final now = DateTime.now();
  final y = now.year.toString().padLeft(4, '0');
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

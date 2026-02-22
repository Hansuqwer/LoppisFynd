import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/app/providers.dart';
import '../../core/settings/app_settings_keys.dart';
import '../../core/tokens/app_tokens.dart';
import '../../shared/widgets/bento_card.dart';
import '../../shared/widgets/glass_board.dart';
import '../../shared/widgets/glass_button.dart';
import '../../services/sync/cloud_photo_sync_service.dart';
import '../../services/sync/cloud_metadata_sync_service.dart';
import '../../services/sync/background/background_sync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/navigation/spring_route.dart';
import 'account_deletion_screen.dart';
import 'privacy_screen.dart';
import 'sync_status_screen.dart';

import '../../gen/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _displayNameController = TextEditingController();
  bool _syncing = false;
  bool _cloudSyncing = false;
  bool _cloudPhotoSyncing = false;
  bool _signingOut = false;
  String? _lastDisplayName;

  static const _kDevModeEnabled = 'dev_mode_enabled_v1';
  bool _devModeEnabled = false;
  int _devModeTaps = 0;
  Timer? _devModeTapTimer;
  PackageInfo? _packageInfo;

  static const _kSyncIntervalHours = 'market_sync_interval_hours';
  static const _kHighContrastEnabled = 'high_contrast_enabled';

  static const _kDevModeTapTargetKey = Key('settings_dev_mode_tap_target');

  @override
  void initState() {
    super.initState();

    () async {
      final db = ref.read(appDatabaseProvider);
      final enabled = (await db.appSettingsDao.getInt(_kDevModeEnabled)) == 1;
      PackageInfo? info;
      try {
        info = await PackageInfo.fromPlatform();
      } catch (_) {
        // Platform channels may be unavailable in widget tests.
        info = null;
      }
      if (!mounted) return;
      setState(() {
        _devModeEnabled = enabled;
        _packageInfo = info;
      });
    }();
  }

  @override
  void dispose() {
    _devModeTapTimer?.cancel();
    _displayNameController.dispose();
    super.dispose();
  }

  void _handleVersionTap() {
    _devModeTapTimer?.cancel();
    _devModeTapTimer = Timer(const Duration(milliseconds: 1200), () {
      _devModeTaps = 0;
    });

    _devModeTaps++;
    if (_devModeTaps < 7) return;
    _devModeTaps = 0;

    () async {
      final db = ref.read(appDatabaseProvider);
      final next = !_devModeEnabled;
      await db.appSettingsDao.setInt(_kDevModeEnabled, next ? 1 : 0);
      if (!mounted) return;
      setState(() => _devModeEnabled = next);
      try {
        await HapticFeedback.heavyImpact();
      } catch (_) {
        // No-op when platform haptics are unavailable.
      }
    }();
  }

  String _displayNameKey(String userId) => 'profile_display_name_$userId';

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

  Future<void> _signOut() async {
    if (_signingOut) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _signingOut = true);
    try {
      await Supabase.instance.client.auth.signOut();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.settingsSignedOut)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.settingsSignOutFailed('$e'))));
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final config = ref.watch(appConfigProvider);
    final highContrast = ref
        .watch(highContrastEnabledProvider)
        .maybeWhen(data: (v) => v, orElse: () => false);
    final cloudIdentificationEnabled = ref
        .watch(cloudIdentificationEnabledProvider)
        .maybeWhen(data: (v) => v, orElse: () => true);
    final fetchSoldPriceCompsEnabled = ref
        .watch(fetchSoldPriceCompsEnabledProvider)
        .maybeWhen(data: (v) => v, orElse: () => true);
    final l10n = AppLocalizations.of(context)!;
    final session = ref
        .watch(authSessionProvider)
        .maybeWhen(data: (v) => v, orElse: () => null);
    final email = session?.user.email;
    final userId = session?.user.id;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          0,
        ),
        child: StackedBackplates(
          child: GlassBoard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileHeader(
                  title: l10n.settingsProfileTitle,
                  versionText: () {
                    final info = _packageInfo;
                    if (info == null) return l10n.settingsVersionUnknown;
                    return l10n.settingsVersionPill(
                      info.version,
                      info.buildNumber,
                    );
                  }(),
                  devModeEnabled: _devModeEnabled,
                  onVersionTap: _handleVersionTap,
                ),
                const SizedBox(height: AppSpacing.lg),
                _SettingsModuleCard(
                  icon: Icons.cloud_rounded,
                  title: l10n.settingsModuleSyncDataTitle,
                  child: _buildSyncModule(context, l10n, db, config, email),
                ),
                const SizedBox(height: AppSpacing.md),
                _SettingsModuleCard(
                  icon: Icons.psychology_alt_rounded,
                  title: l10n.settingsModuleAiModelTitle,
                  child: _buildAiModelModule(context, l10n, db, userId),
                ),
                const SizedBox(height: AppSpacing.md),
                _SettingsModuleCard(
                  icon: Icons.shield_outlined,
                  title: l10n.settingsModulePrivacyTitle,
                  child: _buildPrivacyModule(
                    context,
                    l10n,
                    db,
                    config,
                    highContrast,
                    cloudIdentificationEnabled,
                    fetchSoldPriceCompsEnabled,
                    email,
                    userId,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSyncModule(
    BuildContext context,
    AppLocalizations l10n,
    dynamic db,
    dynamic config,
    String? email,
  ) {
    if (!_devModeEnabled) {
      return Text(
        l10n.settingsModuleSyncDataDescription,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsMarketSyncTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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
                    DropdownMenuItem(value: 0, child: Text(l10n.commonOff)),
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
                          final messenger = ScaffoldMessenger.of(context);
                          await db.appSettingsDao.setInt(
                            _kSyncIntervalHours,
                            v,
                          );
                          await BackgroundSync.scheduleIfConfigured(db: db);
                          if (!mounted) return;
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(l10n.settingsSavedSyncInterval),
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
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.settingsCloudSyncTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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
            email == null
                ? l10n.settingsNotSignedIn
                : l10n.settingsSignedInAs(email),
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
        const SizedBox(height: AppSpacing.sm),
        if (config.hasSupabase)
          GlassButton(
            label: l10n.settingsOpenSyncStatus,
            icon: const Icon(Icons.cloud_rounded),
            onPressed: () {
              Navigator.of(
                context,
              ).push(SpringRoute(builder: (_) => const SyncStatusScreen()));
            },
          ),
      ],
    );
  }

  Widget _buildAiModelModule(
    BuildContext context,
    AppLocalizations l10n,
    dynamic db,
    String? userId,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<int?>(
          future: db.appSettingsDao.getInt(
            'ai_accuracy_mode_${userId ?? 'guest'}',
          ),
          builder: (context, snapshot) {
            final current = snapshot.data ?? 1;
            return Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.settingsAiModeLabel,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                DropdownButton<int>(
                  value: current,
                  items: [
                    DropdownMenuItem(value: 0, child: Text(l10n.settingsAiEco)),
                    DropdownMenuItem(
                      value: 1,
                      child: Text(l10n.settingsAiQuality),
                    ),
                  ],
                  onChanged: (v) async {
                    if (v == null) return;
                    final messenger = ScaffoldMessenger.of(context);
                    await db.appSettingsDao.setInt(
                      'ai_accuracy_mode_${userId ?? 'guest'}',
                      v,
                    );
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.settingsAiModeSaved)),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildPrivacyModule(
    BuildContext context,
    AppLocalizations l10n,
    dynamic db,
    dynamic config,
    bool highContrast,
    bool cloudIdentificationEnabled,
    bool fetchSoldPriceCompsEnabled,
    String? email,
    String? userId,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsAccessibility,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.xs),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.settingsHighContrast),
          value: highContrast,
          onChanged: (v) async {
            final messenger = ScaffoldMessenger.of(context);
            await db.appSettingsDao.setInt(_kHighContrastEnabled, v ? 1 : 0);
            if (!mounted) return;
            messenger.showSnackBar(
              SnackBar(content: Text(l10n.settingsContrastUpdated)),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.settingsPrivacyDataSectionTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.xs),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.settingsCloudIdentificationToggleTitle),
          subtitle: Text(l10n.settingsCloudIdentificationToggleSubtitle),
          value: cloudIdentificationEnabled,
          onChanged: (v) async {
            await db.appSettingsDao.setInt(
              kPrivacyCloudIdentificationEnabledKeyV1,
              v ? 1 : 0,
            );
          },
        ),
        const SizedBox(height: AppSpacing.xs),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.settingsFetchSoldPriceCompsToggleTitle),
          subtitle: Text(l10n.settingsFetchSoldPriceCompsToggleSubtitle),
          value: fetchSoldPriceCompsEnabled,
          onChanged: (v) async {
            await db.appSettingsDao.setInt(
              kPrivacyFetchSoldPriceCompsEnabledKeyV1,
              v ? 1 : 0,
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.settingsPrivacyTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.settingsPrivacySubtitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        GlassButton(
          label: l10n.settingsOpenPrivacy,
          icon: const Icon(Icons.privacy_tip_rounded),
          onPressed: () {
            Navigator.of(
              context,
            ).push(SpringRoute(builder: (_) => const PrivacyScreen()));
          },
        ),
        if (config.hasSupabase) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.settingsAccountTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            email == null
                ? l10n.settingsNotSignedIn
                : l10n.settingsSignedInAs(email),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (email != null && userId != null) ...[
            const SizedBox(height: AppSpacing.md),
            FutureBuilder<String?>(
              future: db.appSettingsDao.getString(_displayNameKey(userId)),
              builder: (context, snapshot) {
                final current = snapshot.data;
                if (current != _lastDisplayName) {
                  _lastDisplayName = current;
                  _displayNameController.text = current ?? '';
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _displayNameController,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: l10n.settingsDisplayNameLabel,
                        hintText: l10n.settingsDisplayNameHint,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    GlassButton(
                      label: l10n.settingsSaveProfile,
                      icon: const Icon(Icons.save_rounded),
                      onPressed: () async {
                        final name = _displayNameController.text.trim();
                        final messenger = ScaffoldMessenger.of(context);
                        await db.appSettingsDao.setString(
                          _displayNameKey(userId),
                          name.isEmpty ? null : name,
                        );
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(content: Text(l10n.settingsProfileSaved)),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: GlassButton(
                  label: _signingOut
                      ? l10n.settingsSigningOut
                      : l10n.settingsSignOut,
                  onPressed: email == null || _signingOut ? null : _signOut,
                  icon: const Icon(Icons.logout_rounded),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GlassButton(
                  label: l10n.settingsDeleteAccount,
                  tone: GlassButtonTone.neutral,
                  onPressed: () {
                    Navigator.of(context).push(
                      SpringRoute(
                        builder: (_) => const AccountDeletionScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_off_rounded),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.title,
    required this.versionText,
    required this.devModeEnabled,
    required this.onVersionTap,
  });

  final String title;
  final String versionText;
  final bool devModeEnabled;
  final VoidCallback onVersionTap;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(
      context,
    ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: AppShadows.bento,
          ),
          child: Icon(
            Icons.person,
            color: AppColors.inkDeep.withValues(alpha: 0.55),
            size: 30,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(title, style: titleStyle, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.xs),
        GestureDetector(
          key: _SettingsScreenState._kDevModeTapTargetKey,
          onTap: onVersionTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.inkDeep.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    versionText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.inkDeep.withValues(alpha: 0.70),
                    ),
                  ),
                ),
                if (devModeEnabled) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    Icons.code_rounded,
                    size: 16,
                    color: AppColors.inkDeep.withValues(alpha: 0.75),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsModuleCard extends StatelessWidget {
  const _SettingsModuleCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.deepSapphire.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Icon(
                  icon,
                  color: AppColors.deepSapphire.withValues(alpha: 0.75),
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
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

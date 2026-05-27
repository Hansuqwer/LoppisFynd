import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/app/providers.dart';
import '../../core/settings/app_settings_keys.dart';
import '../../core/tokens/app_tokens.dart';
import '../../shared/widgets/glass_board.dart';
import '../../shared/widgets/glass_button.dart';
import '../../services/sync/background/background_sync.dart';
import '../../core/navigation/spring_route.dart';
import 'account_deletion_screen.dart';
import 'legal_screen.dart';
import 'privacy_screen.dart';
import 'settings_providers.dart';
import 'sync_status_screen.dart';

import '../../gen/app_localizations.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_section.dart';
import 'widgets/settings_module_card.dart';
import 'widgets/settings_tile.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const _kDevModeEnabled = 'dev_mode_enabled_v1';
  bool _devModeEnabled = false;
  int _devModeTaps = 0;
  Timer? _devModeTapTimer;
  PackageInfo? _packageInfo;
  int _refreshTrigger = 0;

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

  void _syncNow() => ref.read(syncNowProvider.notifier).run();

  void _cloudSyncNow() => ref.read(cloudSyncNowProvider.notifier).run();

  void _signOut() => ref.read(signOutProvider.notifier).run();

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
    final syncing = ref.watch(syncNowProvider).isLoading;
    final cloudSyncing = ref.watch(cloudSyncNowProvider).isLoading;
    final signingOut = ref.watch(signOutProvider).isLoading;

    ref.listen(syncNowProvider, (prev, next) {
      if (prev?.isLoading ?? false) {
        next.whenOrNull(
          data: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.settingsMarketSyncCompleted)),
            );
          },
          error: (e, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.settingsMarketSyncFailed('$e'))),
            );
          },
        );
      }
    });

    ref.listen(cloudSyncNowProvider, (prev, next) {
      if (prev?.isLoading ?? false) {
        next.whenOrNull(
          data: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.settingsCloudSyncCompleted)),
            );
          },
          error: (e, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.settingsCloudSyncFailed('$e'))),
            );
          },
        );
      }
    });

    ref.listen(signOutProvider, (prev, next) {
      if (prev?.isLoading ?? false) {
        next.whenOrNull(
          data: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.settingsSignedOut)),
            );
          },
          error: (e, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.settingsSignOutFailed('$e'))),
            );
          },
        );
      }
    });

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
                ProfileHeader(
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
                  devModeTapTargetKey: _kDevModeTapTargetKey,
                ),
                const SizedBox(height: AppSpacing.lg),
                SettingsModuleCard(
                  icon: Icons.cloud_rounded,
                  title: l10n.settingsModuleSyncDataTitle,
                  child: _buildSyncModule(context, l10n, db, config, email, syncing, cloudSyncing),
                ),
                const SizedBox(height: AppSpacing.md),
                SettingsModuleCard(
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
                    signingOut,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SettingsModuleCard(
                  icon: Icons.gavel_rounded,
                  title: l10n.settingsModuleLegalTitle,
                  child: _buildLegalModule(context, l10n),
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
    bool syncing,
    bool cloudSyncing,
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
                          setState(() => _refreshTrigger++);
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
          label: syncing ? l10n.settingsSyncing : l10n.settingsSyncNow,
          onPressed: syncing ? null : _syncNow,
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
          label: cloudSyncing
              ? l10n.settingsSyncing
              : l10n.settingsSyncMetadata,
          onPressed: cloudSyncing ? null : _cloudSyncNow,
          icon: const Icon(Icons.cloud_done_rounded),
        ),
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

  Widget _buildLegalModule(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsLegalDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        GlassButton(
          label: l10n.settingsOpenLegal,
          icon: const Icon(Icons.gavel_rounded),
          onPressed: () {
            Navigator.of(
              context,
            ).push(SpringRoute(builder: (_) => const LegalScreen()));
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
    bool signingOut,
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
        SettingsTile(
          title: l10n.settingsHighContrast,
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
        SettingsTile(
          title: l10n.settingsCloudIdentificationToggleTitle,
          subtitle: l10n.settingsCloudIdentificationToggleSubtitle,
          value: cloudIdentificationEnabled,
          onChanged: (v) async {
            await db.appSettingsDao.setInt(
              kPrivacyCloudIdentificationEnabledKeyV1,
              v ? 1 : 0,
            );
          },
        ),
        const SizedBox(height: AppSpacing.xs),
        SettingsTile(
          title: l10n.settingsFetchSoldPriceCompsToggleTitle,
          subtitle: l10n.settingsFetchSoldPriceCompsToggleSubtitle,
          value: fetchSoldPriceCompsEnabled,
          onChanged: (v) async {
            await db.appSettingsDao.setInt(
              kPrivacyFetchSoldPriceCompsEnabledKeyV1,
              v ? 1 : 0,
            );
            await BackgroundSync.scheduleIfConfigured(db: db);
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
            ProfileSection(db: db, userId: userId),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: GlassButton(
                  label: signingOut
                      ? l10n.settingsSigningOut
                      : l10n.settingsSignOut,
                  onPressed: email == null || signingOut ? null : _signOut,
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

String _todayKey() {
  final now = DateTime.now();
  final y = now.year.toString().padLeft(4, '0');
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

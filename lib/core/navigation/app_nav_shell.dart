import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../gen/app_localizations.dart';

import '../../features/dashboard/dashboard_screen.dart';
import '../../features/hauls/haul_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/scanner/scanner_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../core/app/providers.dart';
import '../../shared/widgets/offline_banner.dart';
import '../../features/analyzer/item_detail_screen.dart';
import 'spring_route.dart';

enum AppTab { dashboard, scanner, haul, history, profile }

class AppNavShell extends ConsumerStatefulWidget {
  const AppNavShell({super.key});

  @override
  ConsumerState<AppNavShell> createState() => _AppNavShellState();
}

class _AppNavShellState extends ConsumerState<AppNavShell> {
  var _tab = AppTab.dashboard;

  late final ProviderSubscription<int?> _deepLinkTabSub;
  late final ProviderSubscription<String?> _deepLinkItemSub;
  late final ProviderSubscription<AsyncValue<bool>> _onlineSub;
  late final ProviderSubscription<AsyncValue<Session?>> _authSub;

  int get _index => AppTab.values.indexOf(_tab);

  void _setIndex(int index) {
    final nextTab = AppTab.values[index];
    if (nextTab == _tab) return;
    setState(() => _tab = nextTab);
  }

  String get _title => switch (_tab) {
    AppTab.dashboard => AppLocalizations.of(context)!.tabHome,
    AppTab.scanner => AppLocalizations.of(context)!.tabScan,
    AppTab.haul => AppLocalizations.of(context)!.tabHaul,
    AppTab.history => AppLocalizations.of(context)!.tabHistory,
    AppTab.profile => AppLocalizations.of(context)!.tabProfile,
  };

  @override
  void initState() {
    super.initState();

    _deepLinkTabSub = ref.listenManual<int?>(deepLinkTabIndexProvider, (
      prev,
      next,
    ) {
      if (next == null) return;
      if (next < 0 || next >= AppTab.values.length) return;
      if (!mounted) return;
      setState(() => _tab = AppTab.values[next]);
      ref.read(deepLinkTabIndexProvider.notifier).state = null;
    });

    _deepLinkItemSub = ref.listenManual<String?>(deepLinkScanItemIdProvider, (
      prev,
      next,
    ) {
      if (next == null) return;
      if (!mounted) return;

      // Defer push until after the current frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(
          context,
        ).push(SpringRoute(builder: (_) => ItemDetailScreen(scanItemId: next)));
        ref.read(deepLinkScanItemIdProvider.notifier).state = null;
      });
    });

    _onlineSub = ref.listenManual<AsyncValue<bool>>(isOnlineProvider, (
      prev,
      next,
    ) {
      final wasOnline = prev?.valueOrNull ?? true;
      final isOnline = next.valueOrNull ?? true;
      if (wasOnline || !isOnline) return;
      ref.read(cloudSyncCoordinatorProvider).syncIfNeeded(isOnline: true);
    });

    _authSub = ref.listenManual<AsyncValue<Session?>>(authSessionProvider, (
      prev,
      next,
    ) {
      final hadSession = prev?.valueOrNull != null;
      final hasSession = next.valueOrNull != null;
      if (hadSession || !hasSession) return;

      final online = ref.read(isOnlineProvider).valueOrNull ?? true;
      ref
          .read(cloudSyncCoordinatorProvider)
          .syncIfNeeded(isOnline: online, force: true);
    });
  }

  @override
  void dispose() {
    _deepLinkTabSub.close();
    _deepLinkItemSub.close();
    _onlineSub.close();
    _authSub.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref
        .watch(isOnlineProvider)
        .maybeWhen(data: (v) => v, orElse: () => true);
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: Column(
        children: [
          if (!isOnline)
            OfflineBanner(message: AppLocalizations.of(context)!.bannerOffline),
          Expanded(
            child: switch (_tab) {
              AppTab.dashboard => const DashboardScreen(),
              AppTab.scanner => const ScannerScreen(),
              AppTab.haul => const HaulScreen(),
              AppTab.history => const HistoryScreen(),
              AppTab.profile => const SettingsScreen(),
            },
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _setIndex,
        destinations: [
          NavigationDestination(
            icon: const Icon(LucideIcons.layoutGrid),
            label: AppLocalizations.of(context)!.tabHome,
          ),
          NavigationDestination(
            icon: const Icon(LucideIcons.camera),
            label: AppLocalizations.of(context)!.tabScan,
          ),
          NavigationDestination(
            icon: const Icon(LucideIcons.shoppingBag),
            label: AppLocalizations.of(context)!.tabHaul,
          ),
          NavigationDestination(
            icon: const Icon(LucideIcons.map),
            label: AppLocalizations.of(context)!.tabHistory,
          ),
          NavigationDestination(
            icon: const Icon(LucideIcons.userCog),
            label: AppLocalizations.of(context)!.tabProfile,
          ),
        ],
      ),
    );
  }
}

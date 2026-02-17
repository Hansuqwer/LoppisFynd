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
import '../../shared/widgets/atmospheric_background.dart';
import '../../shared/widgets/capsule_nav_bar.dart';

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
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AtmosphericBackground(),
          Column(
            children: [
              if (!isOnline)
                OfflineBanner(
                  message: AppLocalizations.of(context)!.bannerOffline,
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 108),
                  child: switch (_tab) {
                    AppTab.dashboard => const DashboardScreen(),
                    AppTab.scanner => const ScannerScreen(),
                    AppTab.haul => const HaulScreen(),
                    AppTab.history => const HistoryScreen(),
                    AppTab.profile => const SettingsScreen(),
                  },
                ),
              ),
            ],
          ),
          CapsuleNavBar(
            selectedIndex: _index,
            onSelected: _setIndex,
            destinations: [
              CapsuleNavDestination(
                key: const Key('nav_dashboard'),
                icon: LucideIcons.layoutGrid,
                label: AppLocalizations.of(context)!.tabHome,
              ),
              CapsuleNavDestination(
                key: const Key('nav_scanner'),
                icon: LucideIcons.camera,
                label: AppLocalizations.of(context)!.tabScan,
                isPrimary: true,
              ),
              CapsuleNavDestination(
                key: const Key('nav_haul'),
                icon: LucideIcons.shoppingBag,
                label: AppLocalizations.of(context)!.tabHaul,
              ),
              CapsuleNavDestination(
                key: const Key('nav_history'),
                icon: LucideIcons.map,
                label: AppLocalizations.of(context)!.tabHistory,
              ),
              CapsuleNavDestination(
                key: const Key('nav_profile'),
                icon: LucideIcons.userCog,
                label: AppLocalizations.of(context)!.tabProfile,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

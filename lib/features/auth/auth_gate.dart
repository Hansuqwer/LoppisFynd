import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app/providers.dart';
import '../auth/login_screen.dart';
import '../../core/navigation/app_nav_shell.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  Future<void> _ensureScopedData(WidgetRef ref, String? userId) async {
    final db = ref.read(appDatabaseProvider);
    final haulId = ref.read(defaultHaulIdProvider);

    await db.haulsDao.ensureCurrentHaul(
      id: haulId,
      title: 'Current haul',
      userId: userId,
    );

    if (userId == null) return;

    final claimedKey = 'claimed_guest_data_$userId';
    final claimed = await db.appSettingsDao.getInt(claimedKey);
    if (claimed == 1) return;

    await db.transaction(() async {
      await db.haulsDao.claimGuestDataForUser(userId);
      await db.scanItemsDao.claimGuestDataForUser(userId);
    });
    await db.appSettingsDao.setInt(claimedKey, 1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    if (!config.hasSupabase) {
      unawaited(_ensureScopedData(ref, null));
      return const AppNavShell();
    }

    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;
        unawaited(_ensureScopedData(ref, session?.user.id));
        if (session != null) {
          return const AppNavShell();
        }
        return const LoginScreen();
      },
    );
  }
}

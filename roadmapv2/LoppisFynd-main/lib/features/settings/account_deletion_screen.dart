import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app/providers.dart';
import '../../core/tokens/app_tokens.dart';
import '../../gen/app_localizations.dart';
import '../../services/privacy/cloud_data_deletion_service.dart';
import '../../services/privacy/local_data_deletion_service.dart';
import '../../shared/widgets/bento_card.dart';
import '../../shared/widgets/glass_button.dart';

class AccountDeletionScreen extends ConsumerStatefulWidget {
  const AccountDeletionScreen({super.key});

  @override
  ConsumerState<AccountDeletionScreen> createState() =>
      _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends ConsumerState<AccountDeletionScreen> {
  bool _deleting = false;
  bool _deletingCloud = false;

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
              child: Text(l10n.accountDeletionConfirm),
            ),
          ],
        );
      },
    );
    return ok == true;
  }

  Future<void> _deleteAccount() async {
    if (_deleting) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final db = ref.read(appDatabaseProvider);
    final userId = ref.read(activeUserIdProvider);
    final config = ref.read(appConfigProvider);

    if (!config.hasSupabase || userId == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.accountDeletionNoAuth)),
      );
      return;
    }

    final ok = await _confirm(
      title: l10n.accountDeletionDangerTitle,
      body: l10n.accountDeletionDangerBody,
    );
    if (!ok) return;

    setState(() => _deleting = true);
    try {
      await Supabase.instance.client.functions.invoke('account-delete');

      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}

      await LocalDataDeletionService(db: db).deleteAllLocalData(userId: userId);

      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.accountDeletionDone)));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.accountDeletionFailed('$e'))),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _deleteCloudData() async {
    if (_deletingCloud) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final config = ref.read(appConfigProvider);

    if (!config.hasSupabase) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.accountDeletionNoCloud)),
      );
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final config = ref.watch(appConfigProvider);
    final session = ref
        .watch(authSessionProvider)
        .maybeWhen(data: (v) => v, orElse: () => null);
    final email = session?.user.email;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountDeletionTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            BentoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.accountDeletionHeadline,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    config.hasSupabase
                        ? (email == null
                              ? l10n.settingsNotSignedIn
                              : l10n.settingsSignedInAs(email))
                        : l10n.settingsSupabaseNotConfigured,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.accountDeletionBody,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (config.hasSupabase)
              BentoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GlassButton(
                      label: _deletingCloud
                          ? l10n.privacyDeleting
                          : l10n.privacyDeleteCloudCta,
                      tone: GlassButtonTone.neutral,
                      icon: const Icon(Icons.cloud_off_rounded),
                      onPressed: _deletingCloud ? null : _deleteCloudData,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    GlassButton(
                      label: _deleting
                          ? l10n.privacyDeleting
                          : l10n.accountDeletionConfirmCta,
                      icon: const Icon(Icons.person_off_rounded),
                      onPressed: _deleting ? null : _deleteAccount,
                    ),
                  ],
                ),
              )
            else
              BentoCard(
                child: Text(
                  l10n.accountDeletionLocalOnlyHint,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

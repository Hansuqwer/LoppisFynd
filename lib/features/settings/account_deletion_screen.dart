import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app/providers.dart';
import '../../core/tokens/app_tokens.dart';
import '../../gen/app_localizations.dart';
import '../../shared/widgets/bento_card.dart';
import '../../shared/widgets/glass_button.dart';
import 'settings_providers.dart';

class AccountDeletionScreen extends ConsumerStatefulWidget {
  const AccountDeletionScreen({super.key});

  @override
  ConsumerState<AccountDeletionScreen> createState() =>
      _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends ConsumerState<AccountDeletionScreen> {
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
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final config = ref.read(appConfigProvider);
    final userId = ref.read(activeUserIdProvider);

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

    ref.read(deleteAccountProvider.notifier).run();
  }

  void _deleteCloudData() {
    final config = ref.read(appConfigProvider);
    if (!config.hasSupabase) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.accountDeletionNoCloud),
        ),
      );
      return;
    }
    ref.read(deleteCloudDataProvider.notifier).run();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final config = ref.watch(appConfigProvider);
    final session = ref
        .watch(authSessionProvider)
        .maybeWhen(data: (v) => v, orElse: () => null);
    final email = session?.user.email;
    final deleteState = ref.watch(deleteAccountProvider);
    final deleteCloudState = ref.watch(deleteCloudDataProvider);
    final deleting = deleteState.isLoading;
    final deletingCloud = deleteCloudState.isLoading;

    ref.listen(deleteAccountProvider, (prev, next) {
      if (prev?.isLoading ?? false) {
        next.whenOrNull(
          data: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.accountDeletionDone)),
            );
            Navigator.of(context).pop();
          },
          error: (e, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.accountDeletionFailed('$e'))),
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
                      label: deletingCloud
                          ? l10n.privacyDeleting
                          : l10n.privacyDeleteCloudCta,
                      tone: GlassButtonTone.neutral,
                      icon: const Icon(Icons.cloud_off_rounded),
                      onPressed: deletingCloud ? null : _deleteCloudData,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    GlassButton(
                      label: deleting
                          ? l10n.privacyDeleting
                          : l10n.accountDeletionConfirmCta,
                      icon: const Icon(Icons.person_off_rounded),
                      onPressed: deleting ? null : _deleteAccount,
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

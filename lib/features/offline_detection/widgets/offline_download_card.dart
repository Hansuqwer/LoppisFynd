import 'package:flutter/material.dart';

import '../../../core/tokens/app_tokens.dart';
import '../../../gen/app_localizations.dart';
import '../../../services/offline_detection/offline_model_download_controller.dart';

class OfflineDownloadCard extends StatelessWidget {
  const OfflineDownloadCard({super.key, required this.controller});

  final OfflineModelDownloadController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spec = controller.spec;

    return ValueListenableBuilder<OfflineModelDownloadState>(
      valueListenable: controller.state,
      builder: (context, state, _) {
        final title = Text(
          l10n.offlineModelCardTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        );

        Widget body;
        List<Widget> actions;

        if (state is OfflineModelIdle) {
          body = Text(
            l10n.offlineModelCardBody(spec.sizeLabel),
            style: Theme.of(context).textTheme.bodyMedium,
          );
          actions = [
            FilledButton.icon(
              onPressed: controller.startOrResume,
              icon: const Icon(Icons.download_rounded),
              label: Text(l10n.offlineModelDownloadCta),
            ),
          ];
        } else if (state is OfflineModelDownloading) {
          body = _ProgressBody(
            received: state.received,
            total: state.total,
            subtitle: l10n.offlineModelDownloadingLabel,
          );
          actions = [
            OutlinedButton.icon(
              onPressed: controller.pause,
              icon: const Icon(Icons.pause_rounded),
              label: Text(l10n.offlineModelPauseCta),
            ),
            const SizedBox(width: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: controller.cancel,
              icon: const Icon(Icons.close_rounded),
              label: Text(l10n.offlineModelCancelCta),
            ),
          ];
        } else if (state is OfflineModelPaused) {
          body = _ProgressBody(
            received: state.received,
            total: state.total,
            subtitle: l10n.offlineModelPausedLabel,
          );
          actions = [
            FilledButton.icon(
              onPressed: controller.startOrResume,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(l10n.offlineModelResumeCta),
            ),
            const SizedBox(width: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: controller.cancel,
              icon: const Icon(Icons.close_rounded),
              label: Text(l10n.offlineModelCancelCta),
            ),
          ];
        } else if (state is OfflineModelInstalled) {
          body = Text(
            l10n.offlineModelInstalledLabel,
            style: Theme.of(context).textTheme.bodyMedium,
          );
          actions = [
            FilledButton.icon(
              onPressed: null,
              icon: const Icon(Icons.check_rounded),
              label: Text(l10n.offlineModelInstalledCta),
            ),
          ];
        } else if (state is OfflineModelFailed) {
          body = Text(
            l10n.offlineModelFailedLabel(state.message),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.dopamineRed),
          );
          actions = [
            FilledButton.icon(
              onPressed: controller.startOrResume,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.offlineModelRetryCta),
            ),
            const SizedBox(width: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: controller.cancel,
              icon: const Icon(Icons.close_rounded),
              label: Text(l10n.offlineModelCancelCta),
            ),
          ];
        } else {
          body = Text(
            l10n.errorSomethingWentWrong,
            style: Theme.of(context).textTheme.bodyMedium,
          );
          actions = [
            FilledButton.icon(
              onPressed: controller.startOrResume,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.buttonRetry),
            ),
          ];
        }

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: AppSpacing.xs),
              body,
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: actions,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressBody extends StatelessWidget {
  const _ProgressBody({
    required this.received,
    required this.total,
    required this.subtitle,
  });

  final int received;
  final int? total;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final t = total;
    final progress = (t == null || t <= 0)
        ? null
        : (received / t).clamp(0.0, 1.0).toDouble();
    final label = t == null
        ? _formatBytes(received)
        : '${_formatBytes(received)} / ${_formatBytes(t)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xs),
        LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          backgroundColor: AppColors.borderSubtle,
          color: AppColors.primaryAction,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}

String _formatBytes(int bytes) {
  const kb = 1024;
  const mb = 1024 * 1024;
  if (bytes >= mb) {
    return '${(bytes / mb).toStringAsFixed(2)} MiB';
  }
  if (bytes >= kb) {
    return '${(bytes / kb).toStringAsFixed(1)} KiB';
  }
  return '$bytes B';
}

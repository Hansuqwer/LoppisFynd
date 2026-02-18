import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app/providers.dart';
import '../../core/tokens/app_tokens.dart';
import '../../gen/app_localizations.dart';
import '../../services/ai/model_install_controller.dart';

class ModelDownloadStatusChip extends ConsumerWidget {
  const ModelDownloadStatusChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    if (!config.hasGemmaModelUrl) return const SizedBox.shrink();

    final state = ref.watch(modelInstallControllerProvider);
    final notifier = ref.read(modelInstallControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    switch (state) {
      case ModelInstallControllerStateIdle():
      case ModelInstallControllerStateNotConsented():
        return const SizedBox.shrink();
      case ModelInstallControllerStateDownloading(
        :final received,
        :final total,
      ):
        final percent = (total != null && total > 0)
            ? ((received / total).clamp(0.0, 1.0) * 100).toInt()
            : null;
        final label = percent == null
            ? l10n.modelInstall_chipLabelDownloading
            : '${l10n.modelInstall_chipLabelDownloading} $percent%';
        return _StatusChip(label: label);
      case ModelInstallControllerStateInstalling():
        return _StatusChip(label: l10n.modelInstall_chipLabelInstalling);
      case ModelInstallControllerStateReady():
        return _StatusChip(
          label: l10n.modelInstall_chipLabelReady,
          tone: _ChipTone.good,
        );
      case ModelInstallControllerStateFailed():
        return _StatusChip(
          label: l10n.modelInstall_chipLabelFailed,
          tone: _ChipTone.bad,
          actionLabel: l10n.modelInstall_chipRetryCta,
          onActionPressed: () => notifier.retry(),
        );
    }
  }
}

enum _ChipTone { neutral, good, bad }

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    this.tone = _ChipTone.neutral,
    this.actionLabel,
    this.onActionPressed,
  });

  final String label;
  final _ChipTone tone;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (tone) {
      _ChipTone.neutral => (
        AppColors.inkDeep.withValues(alpha: 0.06),
        AppColors.inkDeep.withValues(alpha: 0.82),
        AppColors.borderSubtle,
      ),
      _ChipTone.good => (
        AppColors.success.withValues(alpha: 0.12),
        AppColors.inkDeep.withValues(alpha: 0.88),
        AppColors.success.withValues(alpha: 0.25),
      ),
      _ChipTone.bad => (
        AppColors.dopamineRed.withValues(alpha: 0.10),
        AppColors.inkDeep.withValues(alpha: 0.88),
        AppColors.dopamineRed.withValues(alpha: 0.22),
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(width: AppSpacing.sm),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: onActionPressed,
                child: Text(
                  actionLabel!,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: tone == _ChipTone.bad
                        ? AppColors.dopamineRed
                        : AppColors.primaryAction,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/tokens/app_tokens.dart';
import '../../../../shared/widgets/glass_overlay.dart';

/// A glassmorphic bento-style card for model downloads with liquid progress.
///
/// States:
/// - Idle: Download CTA.
/// - Downloading: Liquid fill progress using [AppColors.saturationRed].
/// - Completed: Ready state.
class ModelDownloadCard extends StatelessWidget {
  const ModelDownloadCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.statusText,
    this.progress = 0.0,
    this.isDownloading = false,
    this.isCompleted = false,
    this.errorText,
    this.onPressed,
  });

  final String title;
  final String subtitle;
  final String? statusText;
  final double progress;
  final bool isDownloading;
  final bool isCompleted;
  final String? errorText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    // Determine effective color based on state
    final Color progressColor = isCompleted
        ? AppColors.success
        : (errorText != null ? AppColors.dopamineRed : AppColors.saturationRed);

    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        children: [
          // 1. Base Glass Card
          GlassOverlay(
            blurSigma: 12,
            padding:
                EdgeInsets.zero, // We handle padding internally for the fill
            child: Container(
              height: 120, // Fixed height for Bento feel
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                // Subtle border is handled by GlassOverlay, but we ensure clipping
              ),
              child: Stack(
                children: [
                  // 2. Liquid Fill Background
                  if (isDownloading || isCompleted || errorText != null)
                    _LiquidFill(
                      progress: isCompleted ? 1.0 : progress,
                      color: progressColor.withValues(alpha: 0.2),
                    ),

                  // 3. Content
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        // Icon / Progress Indicator
                        _StatusIcon(
                          isDownloading: isDownloading,
                          isCompleted: isCompleted,
                          hasError: errorText != null,
                          progress: progress,
                          color: progressColor,
                        ),
                        const SizedBox(width: AppSpacing.md),

                        // Text Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                title,
                                style: AppTypography.textTheme.titleLarge
                                    ?.copyWith(color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                errorText ?? statusText ?? subtitle,
                                style: AppTypography.textTheme.bodyMedium
                                    ?.copyWith(
                                      color: errorText != null
                                          ? AppColors.dopamineRed
                                          : AppColors.textPrimary.withValues(
                                              alpha: 0.7,
                                            ),
                                      fontWeight: errorText != null
                                          ? FontWeight.bold
                                          : null,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Action Icon (if idle)
                        if (!isDownloading && !isCompleted && errorText == null)
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: AppColors.primaryAction.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.download_rounded,
                              color: AppColors.primaryAction,
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiquidFill extends StatelessWidget {
  const _LiquidFill({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Stack(
        children: [
          AnimatedFractionallySizedBox(
            duration: AppMotion.spring,
            curve: AppMotion.curve,
            widthFactor: progress.clamp(0.0, 1.0),
            heightFactor: 1.0,
            child: Container(color: color),
          ),
        ],
      ),
    );
  }
}

class AnimatedFractionallySizedBox extends ImplicitlyAnimatedWidget {
  const AnimatedFractionallySizedBox({
    super.key,
    required this.widthFactor,
    required this.heightFactor,
    required super.duration,
    required super.curve,
    required this.child,
  });

  final double widthFactor;
  final double heightFactor;
  final Widget child;

  @override
  AnimatedWidgetBaseState<AnimatedFractionallySizedBox> createState() =>
      _AnimatedFractionallySizedBoxState();
}

class _AnimatedFractionallySizedBoxState
    extends AnimatedWidgetBaseState<AnimatedFractionallySizedBox> {
  Tween<double>? _widthFactor;
  Tween<double>? _heightFactor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactor =
        visitor(
              _widthFactor,
              widget.widthFactor,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;

    _heightFactor =
        visitor(
              _heightFactor,
              widget.heightFactor,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: _widthFactor?.evaluate(animation),
      heightFactor: _heightFactor?.evaluate(animation),
      child: widget.child,
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({
    required this.isDownloading,
    required this.isCompleted,
    required this.hasError,
    required this.progress,
    required this.color,
  });

  final bool isDownloading;
  final bool isCompleted;
  final bool hasError;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.normal,
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: hasError
            ? AppColors.dopamineRed.withValues(alpha: 0.1)
            : (isCompleted
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.background.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: hasError
              ? AppColors.dopamineRed.withValues(alpha: 0.3)
              : (isCompleted
                    ? AppColors.success.withValues(alpha: 0.3)
                    : AppColors.borderSubtle),
        ),
      ),
      child: Center(
        child: hasError
            ? const Icon(Icons.error_outline, color: AppColors.dopamineRed)
            : isCompleted
            ? const Icon(Icons.check_circle_outline, color: AppColors.success)
            : isDownloading
            ? CircularProgressIndicator(
                value: progress,
                strokeWidth: 3,
                backgroundColor: AppColors.borderSubtle,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              )
            : const Icon(
                Icons.smart_toy_outlined,
                color: AppColors.textPrimary,
              ),
      ),
    );
  }
}

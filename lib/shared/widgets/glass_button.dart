import 'package:flutter/material.dart';

import '../../core/tokens/app_tokens.dart';

enum GlassButtonTone { primary, neutral }

class GlassButton extends StatefulWidget {
  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.tone = GlassButtonTone.primary,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final GlassButtonTone tone;
  final String? semanticLabel;

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    final bg = switch (widget.tone) {
      GlassButtonTone.primary => AppColors.primaryAction,
      GlassButtonTone.neutral => AppColors.deepSapphire,
    };

    final fg = switch (widget.tone) {
      GlassButtonTone.primary => AppColors.textOnPrimary,
      GlassButtonTone.neutral => AppColors.textOnDark,
    };

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel ?? widget.label,
      child: AnimatedScale(
        duration: AppMotion.fast,
        curve: AppMotion.curve,
        scale: _pressed ? 0.97 : 1,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.curve,
          transform: Matrix4.identity()
            ..translateByDouble(0.0, _pressed ? 1.5 : 0.0, 0.0, 1.0),
          decoration: BoxDecoration(
            color: enabled ? bg : bg.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: _pressed ? AppShadows.pressed : AppShadows.bento,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              onTap: widget.onPressed,
              onTapDown: enabled ? (_) => _setPressed(true) : null,
              onTapUp: enabled ? (_) => _setPressed(false) : null,
              onTapCancel: enabled ? () => _setPressed(false) : null,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        IconTheme(
                          data: IconThemeData(color: fg, size: 18),
                          child: widget.icon!,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      Text(
                        widget.label,
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: fg),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

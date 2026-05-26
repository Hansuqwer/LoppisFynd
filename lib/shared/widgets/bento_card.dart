import 'package:flutter/material.dart';

import '../../core/tokens/app_tokens.dart';

class BentoCard extends StatefulWidget {
  const BentoCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.backgroundColor = AppColors.surface,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final Color backgroundColor;

  @override
  State<BentoCard> createState() => _BentoCardState();
}

class _BentoCardState extends State<BentoCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final interactive = widget.onTap != null;

    return AnimatedScale(
      duration: AppMotion.fast,
      curve: AppMotion.curve,
      scale: _pressed ? 0.99 : 1,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.curve,
        transform: Matrix4.identity()
          ..translateByDouble(0.0, _pressed ? 1.5 : 0.0, 0.0, 1.0),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: _pressed ? AppShadows.pressed : AppShadows.bento,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: widget.onTap,
            onTapDown: interactive ? (_) => _setPressed(true) : null,
            onTapCancel: interactive ? () => _setPressed(false) : null,
            onTapUp: interactive ? (_) => _setPressed(false) : null,
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );
  }
}

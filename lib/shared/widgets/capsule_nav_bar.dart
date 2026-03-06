import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/tokens/app_tokens.dart';

class CapsuleNavDestination {
  const CapsuleNavDestination({
    required this.label,
    required this.icon,
    this.isPrimary = false,
    this.badgeCount,
    this.key,
  });

  final String label;
  final IconData icon;
  final bool isPrimary;
  final int? badgeCount;
  final Key? key;
}

class CapsuleNavBar extends StatelessWidget {
  const CapsuleNavBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.destinations,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<CapsuleNavDestination> destinations;

  static double marginBottom(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return 14.0 + (bottomInset > 0 ? 6.0 : 18.0);
  }

  static double obstructionHeight(BuildContext context) {
    return AppCapsuleNav.barHeight + marginBottom(context);
  }

  @override
  Widget build(BuildContext context) {
    final marginBottom = CapsuleNavBar.marginBottom(context);

    final barRadius = BorderRadius.circular(AppRadius.capsule);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        key: const Key('capsule_nav'),
        margin: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          marginBottom,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        height: AppCapsuleNav.barHeight,
        decoration: BoxDecoration(
          borderRadius: barRadius,
          boxShadow: AppShadows.capsuleNav,
        ),
        child: ClipRRect(
          borderRadius: barRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppBlur.navSigma,
              sigmaY: AppBlur.navSigma,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.cloudDancer.withValues(
                  alpha: AppOpacity.capsuleNavFill,
                ),
                border: Border.all(color: AppColors.glassStroke),
                borderRadius: barRadius,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var i = 0; i < destinations.length; i++)
                    _NavItem(
                      key: destinations[i].key,
                      destination: destinations[i],
                      selected: selectedIndex == i,
                      onTap: () => onSelected(i),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    super.key,
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final CapsuleNavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPrimary = destination.isPrimary;
    final iconColor = isPrimary
        ? AppColors.cloudDancer
        : (selected
              ? AppColors.inkDeep
              : AppColors.inkDeep.withValues(alpha: 0.42));

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: InkResponse(
        onTap: onTap,
        radius: AppCapsuleNav.inkRadius,
        highlightShape: BoxShape.circle,
        containedInkWell: false,
        child: SizedBox(
          width: isPrimary ? AppCapsuleNav.primaryItemWidth : AppSpacing.xxxl,
          height: AppSpacing.xxxl,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: AnimatedContainer(
                  duration: AppMotion.normal,
                  curve: AppMotion.curve,
                  padding: EdgeInsets.all(
                    isPrimary
                        ? AppCapsuleNav.primaryIconPadding
                        : AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? (selected
                              ? AppColors.accentEarth
                              : AppColors.accentEarth.withValues(
                                  alpha: AppOpacity.capsuleNavFill,
                                ))
                        : (selected ? AppColors.glassFill : Colors.transparent),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: isPrimary
                          ? (selected
                                ? AppColors.cloudDancer.withValues(
                                    alpha: AppOpacity.capsuleNavFill,
                                  )
                                : Colors.transparent)
                          : (selected
                                ? AppColors.glassStroke
                                : Colors.transparent),
                    ),
                  ),
                  child: Icon(destination.icon, color: iconColor, size: 24),
                ),
              ),
              if ((destination.badgeCount ?? 0) > 0)
                Positioned(
                  right: 0,
                  top: 2,
                  child: _NavBadge(count: destination.badgeCount!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBadge extends StatelessWidget {
  const _NavBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 9 ? '9+' : '$count';
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.dopamineRed,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: AppColors.textOnPrimary.withValues(alpha: 0.35),
        ),
        boxShadow: AppShadows.pressed,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textOnPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

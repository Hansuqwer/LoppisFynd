import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/tokens/app_tokens.dart';

class CapsuleNavDestination {
  const CapsuleNavDestination({
    required this.label,
    required this.icon,
    this.isPrimary = false,
    this.key,
  });

  final String label;
  final IconData icon;
  final bool isPrimary;
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

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final marginBottom = 14.0 + (bottomInset > 0 ? 6.0 : 18.0);

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
          child: Center(
            child: AnimatedContainer(
              duration: AppMotion.normal,
              curve: AppMotion.curve,
              padding: EdgeInsets.all(
                isPrimary ? AppCapsuleNav.primaryIconPadding : AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isPrimary
                    ? AppColors.accentEarth
                    : (selected ? AppColors.glassFill : Colors.transparent),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: isPrimary
                      ? Colors.transparent
                      : (selected ? AppColors.glassStroke : Colors.transparent),
                ),
              ),
              child: Icon(destination.icon, color: iconColor, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}

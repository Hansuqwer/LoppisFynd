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

/// Redesign capsule nav bar.
///
/// The primary (scan) item floats 26 px above the bar — matching the
/// redesign's lifted red FAB.  Non-primary items show icon + label.
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

  // How far the scan FAB is lifted above the bar surface.
  static const _fabLift = 26.0;
  // FAB diameter.
  static const _fabSize = 60.0;

  static double marginBottom(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return 14.0 + (bottomInset > 0 ? 6.0 : 18.0);
  }

  static double obstructionHeight(BuildContext context) {
    // Include the lifted FAB in the obstruction height.
    return AppCapsuleNav.barHeight + marginBottom(context) + _fabLift;
  }

  @override
  Widget build(BuildContext context) {
    final mb = marginBottom(context);
    final barRadius = BorderRadius.circular(AppRadius.capsule);

    // Split destinations into left / primary / right.
    final primaryIndex =
        destinations.indexWhere((d) => d.isPrimary);
    final hasPrimary = primaryIndex >= 0;

    final leftDests = hasPrimary
        ? destinations.sublist(0, primaryIndex)
        : destinations;
    final rightDests = hasPrimary && primaryIndex < destinations.length - 1
        ? destinations.sublist(primaryIndex + 1)
        : const <CapsuleNavDestination>[];
    final primaryDest = hasPrimary ? destinations[primaryIndex] : null;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, mb),
        child: Stack(
          key: const Key('capsule_nav'),
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            // ── Glass bar ──────────────────────────────────────
            Container(
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
                      border: Border.all(
                        color: AppColors.cloudDancer.withValues(alpha: 0.65),
                      ),
                      borderRadius: barRadius,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0DFFFFFF),
                          blurRadius: 0,
                          offset: Offset(0, -1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Left tabs.
                        ...leftDests.map((d) {
                          final i = destinations.indexOf(d);
                          return _NavTab(
                            key: d.key,
                            destination: d,
                            selected: selectedIndex == i,
                            onTap: () => onSelected(i),
                          );
                        }),
                        // Spacer where the primary FAB sits.
                        if (hasPrimary)
                          const SizedBox(width: _fabSize + AppSpacing.md * 2),
                        // Right tabs.
                        ...rightDests.map((d) {
                          final i = destinations.indexOf(d);
                          return _NavTab(
                            key: d.key,
                            destination: d,
                            selected: selectedIndex == i,
                            onTap: () => onSelected(i),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Lifted primary FAB ─────────────────────────────
            if (primaryDest != null)
              Positioned(
                bottom: (AppCapsuleNav.barHeight - _fabSize) / 2 + _fabLift,
                child: Semantics(
                  button: true,
                  selected: selectedIndex == primaryIndex,
                  label: primaryDest.label,
                  child: GestureDetector(
                    key: primaryDest.key,
                    onTap: () => onSelected(primaryIndex),
                    child: Container(
                      width: _fabSize,
                      height: _fabSize,
                      decoration: BoxDecoration(
                        color: AppColors.dopamineRed,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x471E2B3C),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                          BoxShadow(
                            color: Color(0x2E1E2B3C),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        primaryDest.icon,
                        color: AppColors.cloudDancer,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
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
    final iconColor = selected
        ? AppColors.inkDeep
        : AppColors.inkDeep.withValues(alpha: 0.38);

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: destination.label,
        child: InkResponse(
          onTap: onTap,
          radius: AppCapsuleNav.inkRadius,
          highlightShape: BoxShape.circle,
          containedInkWell: false,
          child: SizedBox(
            height: AppCapsuleNav.barHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  destination.icon,
                  size: 23,
                  color: iconColor,
                ),
                const SizedBox(height: 3),
                Text(
                  destination.label,
                  style: TextStyle(
                    fontFamily: AppTypography.uiFontFamily,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 10.5,
                    color: iconColor,
                    letterSpacing: 0.02,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

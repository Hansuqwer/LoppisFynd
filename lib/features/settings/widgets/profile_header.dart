import 'package:flutter/material.dart';

import '../../../core/tokens/app_tokens.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.title,
    required this.versionText,
    required this.devModeEnabled,
    required this.onVersionTap,
    this.devModeTapTargetKey,
  });

  final String title;
  final String versionText;
  final bool devModeEnabled;
  final VoidCallback onVersionTap;
  final Key? devModeTapTargetKey;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w900,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: AppShadows.bento,
          ),
          child: Icon(
            Icons.person,
            color: AppColors.inkDeep.withValues(alpha: 0.55),
            size: 30,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(title, style: titleStyle, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.xs),
        GestureDetector(
          key: devModeTapTargetKey,
          onTap: onVersionTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.inkDeep.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    versionText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.inkDeep.withValues(alpha: 0.70),
                    ),
                  ),
                ),
                if (devModeEnabled) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    Icons.code_rounded,
                    size: 16,
                    color: AppColors.inkDeep.withValues(alpha: 0.75),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

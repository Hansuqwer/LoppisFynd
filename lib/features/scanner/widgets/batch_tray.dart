import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/scan_items.dart';
import '../../../core/tokens/app_tokens.dart';
import '../../../shared/widgets/bento_card.dart';
import '../../../gen/app_localizations.dart';

class BatchTray extends StatefulWidget {
  const BatchTray({
    super.key,
    required this.items,
    this.maxItems = 12,
    this.onItemTap,
    this.onItemDelete,
  });

  final List<ScanItem> items;
  final int maxItems;
  final ValueChanged<String>? onItemTap;
  final ValueChanged<String>? onItemDelete;

  @override
  State<BatchTray> createState() => _BatchTrayState();
}

class _BatchTrayState extends State<BatchTray> {
  var _dragging = false;
  var _trashHover = false;

  void _setDragging(bool value) {
    if (_dragging == value) return;
    setState(() {
      _dragging = value;
      if (!_dragging) _trashHover = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (widget.items.isEmpty) {
      return BentoCard(child: Text(l10n.scannerNoScansYet));
    }

    final shown = widget.items.length > widget.maxItems
        ? widget.items.take(widget.maxItems).toList()
        : widget.items;

    final deleteEnabled = widget.onItemDelete != null;

    return BentoCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.scannerBatchTrayTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                widget.items.length.toString(),
                style: AppTypography.metricsFrom(
                  Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (deleteEnabled) ...[
                const SizedBox(width: AppSpacing.sm),
                AnimatedOpacity(
                  opacity: _dragging ? 1 : 0.18,
                  duration: const Duration(milliseconds: 150),
                  child: _TrashTarget(
                    tooltip: l10n.scannerDeleteDropHint,
                    hovered: _trashHover,
                    onHoverChanged: (value) {
                      if (_trashHover == value) return;
                      setState(() => _trashHover = value);
                    },
                    onAccept: (id) {
                      widget.onItemDelete?.call(id);
                      _setDragging(false);
                    },
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: shown.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
              itemBuilder: (context, index) {
                final item = shown[index];
                final tile = _TrayItem(
                  item: item,
                  onTap: widget.onItemTap == null
                      ? null
                      : () => widget.onItemTap!(item.id),
                );

                if (!deleteEnabled) return tile;

                return LongPressDraggable<String>(
                  data: item.id,
                  onDragStarted: () => _setDragging(true),
                  onDragEnd: (_) => _setDragging(false),
                  onDraggableCanceled: (_, _) => _setDragging(false),
                  feedback: _TrayItemFeedback(item: item),
                  childWhenDragging: Opacity(opacity: 0.35, child: tile),
                  child: tile,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TrashTarget extends StatelessWidget {
  const _TrashTarget({
    required this.tooltip,
    required this.hovered,
    required this.onHoverChanged,
    required this.onAccept,
  });

  final String tooltip;
  final bool hovered;
  final ValueChanged<bool> onHoverChanged;
  final ValueChanged<String> onAccept;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) {
        onHoverChanged(true);
        return true;
      },
      onLeave: (_) => onHoverChanged(false),
      onAcceptWithDetails: (details) {
        onHoverChanged(false);
        onAccept(details.data);
      },
      builder: (context, candidates, rejected) {
        return Tooltip(
          message: tooltip,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: hovered
                  ? AppColors.dopamineRed.withValues(alpha: 0.26)
                  : AppColors.surface.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: hovered
                    ? AppColors.dopamineRed.withValues(alpha: 0.6)
                    : AppColors.borderSubtle,
              ),
            ),
            child: Icon(
              Icons.delete_rounded,
              color: hovered ? AppColors.dopamineRed : AppColors.textSecondary,
            ),
          ),
        );
      },
    );
  }
}

class _TrayItemFeedback extends StatelessWidget {
  const _TrayItemFeedback({required this.item});

  final ScanItem item;

  @override
  Widget build(BuildContext context) {
    final thumbPath = item.thumbPath;
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: 76,
        height: 76,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: thumbPath == null
              ? Container(
                  color: AppColors.surface,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_rounded),
                )
              : Image.file(
                  File(thumbPath),
                  fit: BoxFit.cover,
                  cacheWidth: 152,
                  cacheHeight: 152,
                ),
        ),
      ),
    );
  }
}

class _TrayItem extends StatelessWidget {
  const _TrayItem({required this.item, this.onTap});

  final ScanItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final thumbPath = item.thumbPath;
    return SizedBox(
      width: 76,
      height: 76,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: thumbPath == null
                      ? Container(
                          color: AppColors.surface,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_rounded),
                        )
                      : Image.file(
                          File(thumbPath),
                          fit: BoxFit.cover,
                          cacheWidth: 152,
                          cacheHeight: 152,
                          errorBuilder: (context, _, _) {
                            return Container(
                              color: AppColors.surface,
                              alignment: Alignment.center,
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                ),
              ),
              Positioned(
                right: 6,
                bottom: 6,
                child: _StatusBadge(status: item.status),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ScanItemStatus status;

  @override
  Widget build(BuildContext context) {
    final (icon, bg, fg) = switch (status) {
      ScanItemStatus.pendingIdentify => (
        Icons.psychology_alt_rounded,
        AppColors.deepSapphire,
        AppColors.textOnDark,
      ),
      ScanItemStatus.pendingSync => (
        Icons.cloud_upload_rounded,
        AppColors.deepSapphire,
        AppColors.textOnDark,
      ),
      ScanItemStatus.syncing => (
        Icons.sync_rounded,
        AppColors.deepSapphire,
        AppColors.textOnDark,
      ),
      ScanItemStatus.complete => (
        Icons.check_rounded,
        AppColors.success,
        AppColors.textPrimary,
      ),
      ScanItemStatus.failed => (
        Icons.error_outline_rounded,
        AppColors.dopamineRed,
        AppColors.textOnPrimary,
      ),
    };

    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: AppShadows.pressed,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Icon(icon, size: 16, color: fg),
    );
  }
}

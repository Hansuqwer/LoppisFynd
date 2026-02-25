import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/navigation/spring_route.dart';
import '../../core/tokens/app_tokens.dart';
import '../../gen/app_localizations.dart';
import '../../shared/widgets/glass_board.dart';
import '../../shared/widgets/glass_surface.dart';
import '../../shared/widgets/nature_background.dart';
import '../analyzer/item_detail_screen.dart';

class DraftEditorScreen extends ConsumerStatefulWidget {
  const DraftEditorScreen({
    super.key,
    required this.scanItemId,
    this.prefillTitle,
    this.prefillCategory,
    this.prefillDescription,
  });

  final String scanItemId;
  final String? prefillTitle;
  final String? prefillCategory;
  final String? prefillDescription;

  @override
  ConsumerState<DraftEditorScreen> createState() => _DraftEditorScreenState();
}

class _DraftEditorScreenState extends ConsumerState<DraftEditorScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  String? _lastTitle;
  String? _lastDescription;
  double? _lastPrice;

  var _prefillApplied = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final userId = ref.watch(activeUserIdProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const NatureBackground(),
          SafeArea(
            child: StreamBuilder<ScanItem?>(
              stream: db.scanItemsDao.watchById(
                widget.scanItemId,
                userId: userId,
              ),
              builder: (context, itemSnapshot) {
                final item = itemSnapshot.data;

                return StreamBuilder<DraftListing?>(
                  stream: db.draftListingsDao.watchByScanItemId(
                    widget.scanItemId,
                  ),
                  builder: (context, snapshot) {
                    final draft = snapshot.data;

                    if (draft == null) {
                      if (!_prefillApplied) {
                        final preTitle = widget.prefillTitle?.trim();
                        final preDesc = widget.prefillDescription?.trim();
                        if (preTitle != null && preTitle.isNotEmpty) {
                          _titleController.text = preTitle;
                        }
                        final preCategory = widget.prefillCategory?.trim();
                        if (preCategory != null && preCategory.isNotEmpty) {
                          unawaited(
                            db.scanItemsDao.setCategory(
                              id: widget.scanItemId,
                              category: preCategory,
                            ),
                          );
                        }
                        if (preDesc != null && preDesc.isNotEmpty) {
                          _descriptionController.text = preDesc;
                        }
                        _prefillApplied = true;
                      }
                    } else {
                      final title = draft.title;
                      if (title != _lastTitle) {
                        _lastTitle = title;
                        _titleController.text = title ?? '';
                      }

                      final description = draft.description;
                      if (description != _lastDescription) {
                        _lastDescription = description;
                        _descriptionController.text = description ?? '';
                      }

                      final price = draft.askingPriceSek;
                      if (price != _lastPrice) {
                        _lastPrice = price;
                        _priceController.text = price == null
                            ? ''
                            : price.toStringAsFixed(price % 1 == 0 ? 0 : 2);
                      }
                    }

                    final tags = <String>{};
                    final category = item?.category?.trim();
                    if (category != null && category.isNotEmpty) {
                      tags.add(category);
                    }
                    final query = item?.query?.trim();
                    if (query != null && query.isNotEmpty) {
                      tags.addAll(
                        query
                            .split(RegExp(r'\s+'))
                            .where((t) => t.trim().isNotEmpty)
                            .take(3),
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.lg,
                        0,
                      ),
                      child: StackedBackplates(
                        child: GlassBoard(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    icon: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                    ),
                                    color: AppColors.inkDeep.withValues(
                                      alpha: 0.80,
                                    ),
                                    tooltip: l10n.commonCancel,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: Text(
                                      l10n.draftsTitle,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        SpringRoute(
                                          builder: (_) => ItemDetailScreen(
                                            scanItemId: widget.scanItemId,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.open_in_new_rounded),
                                    color: AppColors.inkDeep.withValues(
                                      alpha: 0.78,
                                    ),
                                    tooltip: l10n.draftEditorOpenAnalyzer,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              GlassSurface(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                blurSigma: AppBlur.cardSigma,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                                fillOpacity: AppOpacity.glassTile,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _Thumb(path: item?.thumbPath, size: 92),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (tags.isNotEmpty)
                                            Wrap(
                                              spacing: AppSpacing.xs,
                                              runSpacing: AppSpacing.xs,
                                              children: [
                                                for (final t in tags.take(6))
                                                  _TagPill(label: t),
                                              ],
                                            )
                                          else
                                            Text(
                                              l10n.draftEditorNoKeywordsYet,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: AppColors.textMuted,
                                                  ),
                                            ),
                                          const SizedBox(height: AppSpacing.sm),
                                          Text(
                                            (item?.desc?.trim().isNotEmpty ??
                                                    false)
                                                ? item!.desc!.trim()
                                                : (item?.query
                                                          ?.trim()
                                                          .isNotEmpty ??
                                                      false)
                                                ? item!.query!.trim()
                                                : l10n.draftsItemFallback,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              GlassSurface(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                blurSigma: AppBlur.cardSigma,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                                fillOpacity: AppOpacity.glassTile,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _DraftField(
                                      label: l10n.draftTitleLabel,
                                      controller: _titleController,
                                      hintText: l10n.draftEditorTitleHint,
                                      textInputAction: TextInputAction.next,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    _DraftField(
                                      label: l10n.draftDescriptionLabel,
                                      controller: _descriptionController,
                                      hintText: l10n.draftEditorDescriptionHint,
                                      maxLines: 5,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    _DraftField(
                                      label: l10n.draftPriceLabel,
                                      controller: _priceController,
                                      hintText: '100',
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Row(
                                children: [
                                  Expanded(
                                    child: _PrimaryActionButton(
                                      label: l10n.save,
                                      onPressed: () async {
                                        final messenger = ScaffoldMessenger.of(
                                          context,
                                        );
                                        final priceText = _priceController.text
                                            .trim();
                                        final priceValue = priceText.isEmpty
                                            ? null
                                            : double.tryParse(priceText);

                                        await db.draftListingsDao.upsert(
                                          scanItemId: widget.scanItemId,
                                          title: _titleController.text,
                                          description:
                                              _descriptionController.text,
                                          askingPriceSek: priceValue,
                                        );

                                        ref
                                            .read(analyticsProvider)
                                            .event(
                                              'draft_created',
                                              data: {
                                                'has_title': _titleController
                                                    .text
                                                    .trim()
                                                    .isNotEmpty,
                                                'has_description':
                                                    _descriptionController.text
                                                        .trim()
                                                        .isNotEmpty,
                                                'has_price': priceValue != null,
                                              },
                                            );

                                        if (!mounted) return;
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              l10n.draftEditorSaved,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  _SecondaryActionButton(
                                    label: l10n.delete,
                                    icon: Icons.delete_outline_rounded,
                                    onPressed: draft == null
                                        ? null
                                        : () async {
                                            final messenger =
                                                ScaffoldMessenger.of(context);
                                            await db.draftListingsDao
                                                .deleteByScanItemId(
                                                  widget.scanItemId,
                                                );
                                            if (!mounted) return;
                                            messenger.showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  l10n.draftEditorDeleted,
                                                ),
                                              ),
                                            );
                                          },
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.lg),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.path, this.size = 56});

  final String? path;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = path;
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: p == null
            ? Container(
                color: AppColors.surface,
                alignment: Alignment.center,
                child: const Icon(Icons.image_rounded),
              )
            : Image.file(
                File(p),
                fit: BoxFit.cover,
                cacheWidth: (size * 2).round(),
                cacheHeight: (size * 2).round(),
                errorBuilder: (context, _, _) {
                  return Container(
                    color: AppColors.surface,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.textOnPrimary.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.inkDeep.withValues(alpha: 0.84),
        ),
      ),
    );
  }
}

class _DraftField extends StatelessWidget {
  const _DraftField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.borderSubtle),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: AppColors.textOnPrimary.withValues(alpha: 0.34),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(
                color: AppColors.eucalyptus.withValues(alpha: 0.70),
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Material(
        color: AppColors.dopamineRed,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final fg = enabled
        ? AppColors.inkDeep.withValues(alpha: 0.84)
        : AppColors.inkDeep.withValues(alpha: 0.40);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.textOnPrimary.withValues(
              alpha: enabled ? 0.30 : 0.18,
            ),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

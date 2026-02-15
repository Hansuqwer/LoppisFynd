import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/navigation/spring_route.dart';
import '../../core/tokens/app_tokens.dart';
import '../../gen/app_localizations.dart';
import '../../shared/widgets/bento_card.dart';
import '../../shared/widgets/glass_button.dart';
import '../analyzer/item_detail_screen.dart';

class DraftEditorScreen extends ConsumerStatefulWidget {
  const DraftEditorScreen({super.key, required this.scanItemId});

  final String scanItemId;

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
      appBar: AppBar(title: Text(l10n.draftEditorTitle)),
      body: SafeArea(
        child: StreamBuilder<ScanItem?>(
          stream: db.scanItemsDao.watchById(widget.scanItemId, userId: userId),
          builder: (context, itemSnapshot) {
            final item = itemSnapshot.data;

            return StreamBuilder<DraftListing?>(
              stream: db.draftListingsDao.watchByScanItemId(widget.scanItemId),
              builder: (context, snapshot) {
                final draft = snapshot.data;

                final title = draft?.title;
                if (title != _lastTitle) {
                  _lastTitle = title;
                  _titleController.text = title ?? '';
                }

                final description = draft?.description;
                if (description != _lastDescription) {
                  _lastDescription = description;
                  _descriptionController.text = description ?? '';
                }

                final price = draft?.askingPriceSek;
                if (price != _lastPrice) {
                  _lastPrice = price;
                  _priceController.text = price == null
                      ? ''
                      : price.toStringAsFixed(price % 1 == 0 ? 0 : 2);
                }

                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    if (item != null) ...[
                      BentoCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.draftEditorItemTitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      SpringRoute(
                                        builder: (_) => ItemDetailScreen(
                                          scanItemId: widget.scanItemId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(l10n.draftEditorOpenAnalyzer),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Thumb(path: item.thumbPath),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if ((item.desc?.trim().isNotEmpty ??
                                          false))
                                        Text(
                                          item.desc!.trim(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        )
                                      else
                                        Text(
                                          (item.query?.trim().isNotEmpty ??
                                                  false)
                                              ? item.query!.trim()
                                              : l10n.draftEditorNoKeywordsYet,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                      const SizedBox(height: AppSpacing.xs),
                                      StreamBuilder<List<ScanItemPhoto>>(
                                        stream: db.scanItemPhotosDao
                                            .watchByScanItemId(
                                              widget.scanItemId,
                                            ),
                                        builder: (context, photoSnapshot) {
                                          final photos =
                                              photoSnapshot.data ?? const [];
                                          if (photos.isEmpty) {
                                            return Text(
                                              l10n.draftEditorNoPhotosYet,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                            );
                                          }

                                          return SizedBox(
                                            height: 54,
                                            child: ListView.separated(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: photos.length,
                                              separatorBuilder: (_, _) =>
                                                  const SizedBox(
                                                    width: AppSpacing.xs,
                                                  ),
                                              itemBuilder: (context, index) {
                                                final p = photos[index];
                                                return _Thumb(
                                                  path:
                                                      p.thumbPath ??
                                                      p.localPath,
                                                  size: 54,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    BentoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.draftEditorFieldsTitle,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: l10n.draftEditorTitleLabel,
                              hintText: l10n.draftEditorTitleHint,
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextField(
                            controller: _descriptionController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              labelText: l10n.draftEditorDescriptionLabel,
                              hintText: l10n.draftEditorDescriptionHint,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextField(
                            controller: _priceController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: l10n.draftEditorAskingPriceLabel,
                              hintText: l10n.draftEditorAskingPriceHint,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: GlassButton(
                                  label: l10n.draftEditorSave,
                                  icon: const Icon(Icons.save_rounded),
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
                                      description: _descriptionController.text,
                                      askingPriceSek: priceValue,
                                    );

                                    ref
                                        .read(analyticsProvider)
                                        .event(
                                          'draft_created',
                                          data: {
                                            'has_title': _titleController.text
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
                                        content: Text(l10n.draftEditorSaved),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              GlassButton(
                                label: l10n.draftEditorDelete,
                                tone: GlassButtonTone.neutral,
                                icon: const Icon(Icons.delete_outline_rounded),
                                onPressed: draft == null
                                    ? null
                                    : () async {
                                        final messenger = ScaffoldMessenger.of(
                                          context,
                                        );
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
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
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

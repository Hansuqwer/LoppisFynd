import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/navigation/spring_route.dart';
import '../../core/tokens/app_tokens.dart';
import '../../gen/app_localizations.dart';
import '../../services/offline_detection/offline_detection_types.dart';
import '../../services/offline_detection/offline_model_download_controller.dart';
import '../drafts/draft_editor_screen.dart';
import '../settings/settings_screen.dart';
import 'widgets/offline_detection_overlay.dart';
import 'widgets/offline_download_card.dart';

class OfflineDetectionScreen extends ConsumerStatefulWidget {
  const OfflineDetectionScreen({super.key, required this.scanItemId});

  final String scanItemId;

  @override
  ConsumerState<OfflineDetectionScreen> createState() =>
      _OfflineDetectionScreenState();
}

class _OfflineDetectionScreenState
    extends ConsumerState<OfflineDetectionScreen> {
  late final OfflineModelDownloadController _downloadController;

  var _detecting = false;
  String? _error;

  List<OfflineDetection> _detections = const [];
  int? _selectedIndex;

  var _showDownloadCard = false;
  var _autoRunAfterDownload = false;

  @override
  void initState() {
    super.initState();
    _downloadController = OfflineModelDownloadController();
    _downloadController.state.addListener(_handleDownloadState);
    unawaited(_maybeAutoRunOnOpen());
  }

  @override
  void dispose() {
    _downloadController.state.removeListener(_handleDownloadState);
    _downloadController.dispose();
    super.dispose();
  }

  void _handleDownloadState() {
    final s = _downloadController.state.value;
    if (s is! OfflineModelInstalled) return;
    if (!_autoRunAfterDownload) return;

    _autoRunAfterDownload = false;
    _showDownloadCard = false;

    unawaited(() async {
      final db = ref.read(appDatabaseProvider);
      final userId = ref.read(activeUserIdProvider);
      final item = await db.scanItemsDao.getById(
        widget.scanItemId,
        userId: userId,
      );
      if (item == null) return;
      if (!mounted) return;
      await _runDetection(item);
    }());
  }

  Future<void> _maybeAutoRunOnOpen() async {
    try {
      final enabled = await ref.read(
        offlineIdentificationEnabledProvider.future,
      );
      if (!enabled) return;

      final detector = ref.read(offlineDetectorProvider);
      final install = await detector.installState();
      if (!install.installed) return;

      final db = ref.read(appDatabaseProvider);
      final userId = ref.read(activeUserIdProvider);
      final item = await db.scanItemsDao.getById(
        widget.scanItemId,
        userId: userId,
      );
      if (item == null) return;
      if (!mounted) return;
      await _runDetection(item);
    } catch (_) {
      // Best-effort only.
    }
  }

  Future<void> _runDetection(ScanItem item) async {
    if (_detecting) return;

    final path = item.imagePath;
    if (path == null || path.trim().isEmpty) {
      setState(() => _error = 'No image.');
      return;
    }

    final file = File(path);
    if (!await file.exists()) {
      setState(() => _error = 'No image.');
      return;
    }

    final detector = ref.read(offlineDetectorProvider);
    final install = await detector.installState();
    if (!install.installed) {
      if (!mounted) return;
      setState(() {
        _showDownloadCard = true;
        _autoRunAfterDownload = true;
      });
      return;
    }

    setState(() {
      _detecting = true;
      _error = null;
      _showDownloadCard = false;
    });

    try {
      final bytes = await file.readAsBytes();
      final detections = await detector.detectImageBytes(bytes);
      if (!mounted) return;
      setState(() {
        _detections = detections;
        _selectedIndex = detections.isEmpty ? null : 0;
      });
    } on StateError catch (e) {
      if (!mounted) return;
      final msg = e.message;
      if (msg.contains('not installed')) {
        setState(() {
          _showDownloadCard = true;
          _autoRunAfterDownload = true;
        });
      } else {
        setState(() => _error = '$e');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _detecting = false);
    }
  }

  void _handleApply(ScanItem item) {
    final i = _selectedIndex;
    if (i == null || i < 0 || i >= _detections.length) return;
    final d = _detections[i];
    final title = d.label.trim();
    Navigator.of(context).push(
      SpringRoute(
        builder: (_) => DraftEditorScreen(
          scanItemId: item.id,
          prefillTitle: title.isEmpty ? null : title,
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(
      context,
    ).push(SpringRoute(builder: (_) => const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final userId = ref.watch(activeUserIdProvider);
    final enabledAsync = ref.watch(offlineIdentificationEnabledProvider);
    final enabled = enabledAsync.maybeWhen(data: (v) => v, orElse: () => false);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.offlineIdentifyTitle)),
      body: SafeArea(
        child: StreamBuilder<ScanItem?>(
          stream: db.scanItemsDao.watchById(widget.scanItemId, userId: userId),
          builder: (context, snapshot) {
            final item = snapshot.data;
            if (item == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final imagePath = item.imagePath;
            final imageFile = (imagePath == null || imagePath.trim().isEmpty)
                ? null
                : File(imagePath);

            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 860;
                  final left = _EvidencePanel(
                    imageFile: imageFile,
                    detections: _detections,
                    selectedIndex: _selectedIndex,
                    detecting: _detecting,
                    error: _error,
                    enabled: enabled,
                    showDownloadCard: _showDownloadCard,
                    downloadController: _downloadController,
                    onRun: () => _runDetection(item),
                    onOpenSettings: _openSettings,
                    onSelected: (i) => setState(() => _selectedIndex = i),
                  );

                  final right = _ResultsPanel(
                    detections: _detections,
                    selectedIndex: _selectedIndex,
                    onSelected: (i) => setState(() => _selectedIndex = i),
                    onApply: () => _handleApply(item),
                  );

                  if (!wide) {
                    return Column(
                      children: [
                        SizedBox(height: 360, child: left),
                        const SizedBox(height: AppSpacing.lg),
                        Expanded(child: right),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: left),
                      const SizedBox(width: AppSpacing.lg),
                      SizedBox(width: 420, child: right),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EvidencePanel extends StatelessWidget {
  const _EvidencePanel({
    required this.imageFile,
    required this.detections,
    required this.selectedIndex,
    required this.detecting,
    required this.error,
    required this.enabled,
    required this.showDownloadCard,
    required this.downloadController,
    required this.onRun,
    required this.onOpenSettings,
    required this.onSelected,
  });

  final File? imageFile;
  final List<OfflineDetection> detections;
  final int? selectedIndex;
  final bool detecting;
  final String? error;
  final bool enabled;
  final bool showDownloadCard;
  final OfflineModelDownloadController downloadController;
  final VoidCallback onRun;
  final VoidCallback onOpenSettings;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.offlineIdentifyEvidenceTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: !enabled || detecting ? null : onRun,
                icon: detecting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(
                  detecting
                      ? l10n.offlineIdentifyRunningLabel
                      : l10n.offlineIdentifyRunCta,
                ),
              ),
            ],
          ),
          if (!enabled) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.offlineIdentifyDisabledHint,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.xs),
            OutlinedButton.icon(
              onPressed: onOpenSettings,
              icon: const Icon(Icons.settings_rounded),
              label: Text(l10n.commonOpenSettings),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageFile == null)
                    Container(
                      color: AppColors.background,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported),
                    )
                  else
                    Image.file(
                      imageFile!,
                      fit: BoxFit.fill,
                      errorBuilder: (context, _, _) {
                        return Container(
                          color: AppColors.background,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  if (detections.isNotEmpty)
                    OfflineDetectionOverlay(
                      detections: detections,
                      selectedIndex: selectedIndex,
                      onSelected: onSelected,
                    ),
                  if (detecting)
                    Container(
                      color: AppColors.scrim.withValues(alpha: 0.14),
                      alignment: Alignment.center,
                      child: Text(
                        l10n.offlineIdentifyWorkingOverlay,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textOnDark,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (error != null && error!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              error!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.dopamineRed),
            ),
          ],
          if (showDownloadCard) ...[
            const SizedBox(height: AppSpacing.md),
            OfflineDownloadCard(controller: downloadController),
          ],
        ],
      ),
    );
  }
}

class _ResultsPanel extends StatefulWidget {
  const _ResultsPanel({
    required this.detections,
    required this.selectedIndex,
    required this.onSelected,
    required this.onApply,
  });

  final List<OfflineDetection> detections;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onApply;

  @override
  State<_ResultsPanel> createState() => _ResultsPanelState();
}

class _ResultsPanelState extends State<_ResultsPanel> {
  @override
  void didUpdateWidget(covariant _ResultsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep best-effort: if results just arrived, select the first detection.
    if (oldWidget.detections.isEmpty &&
        widget.detections.isNotEmpty &&
        widget.selectedIndex == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onSelected(0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final detections = widget.detections;
    final selected = widget.selectedIndex;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.offlineIdentifyResultsTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: (selected == null || detections.isEmpty)
                    ? null
                    : widget.onApply,
                icon: const Icon(Icons.playlist_add_check_rounded),
                label: Text(l10n.offlineIdentifyApplyCta),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (detections.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  l10n.offlineIdentifyNoResults,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: detections.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final d = detections[index];
                  final info = confidenceInfoForScore(d.score);
                  final isSelected = selected == index;
                  return ListTile(
                    selected: isSelected,
                    selectedColor: AppColors.inkDeep,
                    selectedTileColor: AppColors.primaryAction.withValues(
                      alpha: 0.10,
                    ),
                    title: Text(
                      d.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    subtitle: Text(
                      '${info.percentLabel} · ${info.label}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded)
                        : const Icon(Icons.radio_button_unchecked_rounded),
                    onTap: () => widget.onSelected(index),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

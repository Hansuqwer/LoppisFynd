import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/app/providers.dart';
import '../../core/tokens/app_tokens.dart';
import '../../shared/widgets/bento_card.dart';
import '../../shared/widgets/error_banner.dart';
import '../../shared/widgets/glass_button.dart';
import '../../shared/widgets/glass_overlay.dart';
import '../../core/navigation/spring_route.dart';
import '../analyzer/item_detail_screen.dart';
import '../../gen/app_localizations.dart';
import '../../services/sync/cloud/entity_keys.dart';
import 'widgets/barcode_ar_overlay.dart';
import 'widgets/batch_tray.dart';
import 'widgets/scanner_overlay.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({
    super.key,
    this.active = true,
    this.barcodeOverlayListenable,
    this.onBarcodeTap,
    this.bookDraftScanItemId,
  });

  final bool active;
  final ValueListenable<BarcodeDetectionFrame?>? barcodeOverlayListenable;
  final ValueChanged<String>? onBarcodeTap;
  final String? bookDraftScanItemId;

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with WidgetsBindingObserver {
  static const _overlayUpdateInterval = Duration(milliseconds: 80);

  String? _error;
  var _cameraPermissionPermanentlyDenied = false;
  var _cameraPermissionDenied = false;
  var _capturing = false;

  ValueListenable<BarcodeDetectionFrame?>? _overlayListenable;
  final _internalOverlay = ValueNotifier<BarcodeDetectionFrame?>(null);
  BarcodeDetectionFrame? _pendingOverlayFrame;
  BarcodeDetectionFrame? _overlayFrame;
  Timer? _overlayTimer;

  dynamic _barcodeScanner;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncOverlayListenable();
  }

  @override
  void didUpdateWidget(covariant ScannerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) {
      if (!widget.active) {
        _deactivateCamera();
      } else {
        _initCameraIfNeeded();
      }
    }
    _syncOverlayListenable();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.active) {
      _initCameraIfNeeded();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _overlayListenable?.removeListener(_handleOverlayInput);
    _overlayTimer?.cancel();
    _internalOverlay.dispose();
    super.dispose();
  }

  void _syncOverlayListenable() {
    final next = widget.barcodeOverlayListenable ?? _internalOverlay;
    if (identical(_overlayListenable, next)) {
      return;
    }

    _overlayListenable?.removeListener(_handleOverlayInput);
    _overlayListenable = next;
    _overlayListenable?.addListener(_handleOverlayInput);

    _pendingOverlayFrame = _overlayListenable?.value;
    _scheduleOverlayRepaint();
  }

  void _handleOverlayInput() {
    _pendingOverlayFrame = _overlayListenable?.value;
    _scheduleOverlayRepaint();
  }

  void _scheduleOverlayRepaint() {
    if (_overlayTimer != null) {
      return;
    }

    _overlayTimer = Timer(_overlayUpdateInterval, () {
      _overlayTimer = null;
      if (!mounted) {
        return;
      }

      final next = _pendingOverlayFrame;
      if (next?.revision == _overlayFrame?.revision) {
        return;
      }

      setState(() => _overlayFrame = next);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initCameraIfNeeded();
    }
  }

  void _deactivateCamera() {
    if (mounted) {
      setState(() {
        _error = null;
        _cameraPermissionDenied = false;
        _cameraPermissionPermanentlyDenied = false;
        _overlayFrame = null;
        _pendingOverlayFrame = null;
      });
    }
  }

  Future<void> _initCameraIfNeeded() async {
    if (!widget.active) return;

    final l10n = AppLocalizations.of(context)!;

    final hasPermission = await _ensureCameraPermission();
    if (!hasPermission) return;
    if (!mounted || !widget.active) return;

    try {
      _barcodeScanner ??= _StubBarcodeScanner();
      if (!mounted || !widget.active) return;

      setState(() {
        _error = null;
        _cameraPermissionDenied = false;
        _cameraPermissionPermanentlyDenied = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = l10n.scannerCameraInitFailed('$e'));
    }
  }

  Future<bool> _ensureCameraPermission() async {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.read(appDatabaseProvider);

    try {
      final status = await Permission.camera.status;
      if (status.isGranted) return true;

      if (status.isPermanentlyDenied || status.isRestricted) {
        if (!mounted) return false;
        setState(() {
          _cameraPermissionPermanentlyDenied = true;
          _cameraPermissionDenied = false;
          _error = l10n.scannerCameraPermissionPermanentlyDenied;
        });
        return false;
      }

      const educatedKey = 'camera_permission_educated_v1';
      final educated = (await db.appSettingsDao.getInt(educatedKey)) == 1;
      if (!educated && mounted) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog.adaptive(
              title: Text(l10n.scannerCameraPermissionTitle),
              content: Text(l10n.scannerCameraPermissionBody),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.scannerCameraPermissionNotNow),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(l10n.scannerCameraPermissionContinue),
                ),
              ],
            );
          },
        );

        await db.appSettingsDao.setInt(educatedKey, 1);

        if (proceed != true) {
          if (!mounted) return false;
          setState(() {
            _cameraPermissionDenied = true;
            _cameraPermissionPermanentlyDenied = false;
            _error = l10n.scannerCameraPermissionDenied;
          });
          return false;
        }
      }

      final requested = await Permission.camera.request();
      if (requested.isGranted) return true;

      if (!mounted) return false;
      setState(() {
        _cameraPermissionPermanentlyDenied =
            requested.isPermanentlyDenied || requested.isRestricted;
        _cameraPermissionDenied = !_cameraPermissionPermanentlyDenied;
        _error = _cameraPermissionPermanentlyDenied
            ? l10n.scannerCameraPermissionPermanentlyDenied
            : l10n.scannerCameraPermissionDenied;
      });
      return false;
    } catch (e) {
      if (!mounted) return false;
      setState(() {
        _cameraPermissionDenied = true;
        _cameraPermissionPermanentlyDenied = false;
        _error = l10n.scannerCameraInitFailed('$e');
      });
      return false;
    }
  }

  Future<void> _capture() async {
    final analytics = ref.read(analyticsProvider);

    if (_capturing) return;

    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    setState(() => _capturing = true);
    try {
      analytics.event('scan_started');

      await HapticFeedback.lightImpact();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.snackbarSavedScan(
              'scan_${DateTime.now().millisecondsSinceEpoch}',
            ),
          ),
        ),
      );
    } catch (e) {
      await HapticFeedback.mediumImpact();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.snackbarCaptureFailed('$e'))),
      );
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _handleBarcodeTap(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    await HapticFeedback.selectionClick();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.snackbarCopiedBarcode)));
  }

  Future<void> _doneScanning() async {
    final db = ref.read(appDatabaseProvider);
    final haulId = ref.read(defaultHaulIdProvider);
    final userId = ref.read(activeUserIdProvider);
    final l10n = AppLocalizations.of(context)!;

    try {
      final queued = await db.scanItemsDao.queueReadyToSyncInHaul(
        haulId: haulId,
        userId: userId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.scannerQueuedItems(queued))));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.scannerQueueFailed('$e'))));
    }
  }

  Future<void> _deleteScanItem(String scanItemId) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    final db = ref.read(appDatabaseProvider);
    final userId = ref.read(activeUserIdProvider);

    try {
      final item = await db.scanItemsDao.getById(scanItemId, userId: userId);
      if (item == null) return;

      final photos = await db.scanItemPhotosDao.listByScanItemId(scanItemId);

      final paths = <String>{};
      final imagePath = item.imagePath;
      final thumbPath = item.thumbPath;
      if (imagePath != null && imagePath.isNotEmpty) paths.add(imagePath);
      if (thumbPath != null && thumbPath.isNotEmpty) paths.add(thumbPath);
      for (final p in photos) {
        if (p.localPath.isNotEmpty) paths.add(p.localPath);
        final tp = p.thumbPath;
        if (tp != null && tp.isNotEmpty) paths.add(tp);
      }

      final keys = [
        scanItemEntityKey(scanItemId),
        scanPhotoEntityKey(scanItemId),
      ];

      await db.transaction(() async {
        await db.pendingCloudSyncEntitiesDao.deleteByKeys(keys);
        await db.entitySyncStatusesDao.deleteByKeys(keys);
        await db.scanItemsDao.deleteById(id: scanItemId, userId: userId);
      });

      for (final path in paths) {
        try {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {
          // Best-effort cleanup.
        }
      }

      await HapticFeedback.lightImpact();
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.scannerDeletedScan)));
    } catch (e) {
      await HapticFeedback.mediumImpact();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.scannerDeleteFailed('$e'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final haulId = ref.watch(defaultHaulIdProvider);
    final userId = ref.watch(activeUserIdProvider);
    final l10n = AppLocalizations.of(context)!;
    final cameraHeight = (MediaQuery.sizeOf(context).height * 0.42)
        .clamp(240.0, 360.0)
        .toDouble();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.scannerTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(l10n.scannerSubtitle),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GlassOverlay(
            child: SizedBox(
              height: cameraHeight,
              child: _error != null
                  ? Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: ErrorBanner(
                        title: AppLocalizations.of(context)!.errorCameraTitle,
                        message: _error!,
                        onRetry: _cameraPermissionPermanentlyDenied
                            ? () async {
                                await openAppSettings();
                              }
                            : _initCameraIfNeeded,
                        retryLabel: _cameraPermissionPermanentlyDenied
                            ? l10n.scannerCameraPermissionOpenSettings
                            : _cameraPermissionDenied
                            ? l10n.scannerCameraPermissionContinue
                            : AppLocalizations.of(context)!.buttonRetry,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            color: AppColors.inkDeep,
                            child: const Center(
                              child: Icon(
                                Icons.camera_alt_rounded,
                                color: AppColors.textOnDark,
                                size: 64,
                              ),
                            ),
                          ),
                          BarcodeArOverlay(
                            frame: _overlayFrame,
                            onBarcodeTap:
                                widget.onBarcodeTap ?? _handleBarcodeTap,
                          ),
                          const ScannerOverlay(),
                          Positioned(
                            top: 14,
                            left: 14,
                            right: 14,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.inkDeep.withValues(
                                    alpha: 0.58,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.pill,
                                  ),
                                  border: Border.all(
                                    color: AppColors.textOnDark.withValues(
                                      alpha: 0.12,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  l10n.scannerBarcodeAimHint,
                                  style: TextStyle(
                                    color: AppColors.textOnDark,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Align(
            alignment: Alignment.center,
            child: GlassButton(
              label: _capturing ? l10n.scannerSaving : l10n.scannerCapture,
              icon: const Icon(Icons.camera_alt_rounded),
              onPressed: _capturing ? null : _capture,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.center,
            child: GlassButton(
              label: l10n.scannerDoneScanning,
              tone: GlassButtonTone.neutral,
              icon: const Icon(Icons.done_all_rounded),
              onPressed: _doneScanning,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          StreamBuilder(
            stream: db.scanItemsDao.watchByHaulId(haulId, userId: userId),
            builder: (context, snapshot) {
              final items = snapshot.data ?? const [];
              return BatchTray(
                items: items,
                onItemDelete: _deleteScanItem,
                onItemTap: (id) {
                  Navigator.of(context).push(
                    SpringRoute(
                      builder: (_) => ItemDetailScreen(scanItemId: id),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StubBarcodeScanner {
  void close() {}
}

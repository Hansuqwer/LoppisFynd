import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
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
import 'barcode/mlkit_input_image.dart';
import 'scan_capture_service.dart';
import 'widgets/barcode_ar_overlay.dart';
import 'widgets/batch_tray.dart';
import 'widgets/scanner_overlay.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({
    super.key,
    this.active = true,
    this.barcodeOverlayListenable,
    this.onBarcodeTap,
  });

  final bool active;
  final ValueListenable<BarcodeDetectionFrame?>? barcodeOverlayListenable;
  final ValueChanged<String>? onBarcodeTap;

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with WidgetsBindingObserver {
  static const _overlayUpdateInterval = Duration(milliseconds: 80);
  static const _barcodeMinInterval = Duration(milliseconds: 250);
  static const _autoCaptureDebounce = Duration(milliseconds: 550);
  static const _autoCaptureCooldown = Duration(seconds: 3);
  static const _autoCaptureFreshnessWindow = Duration(milliseconds: 450);

  CameraController? _controller;
  String? _error;
  var _cameraPermissionPermanentlyDenied = false;
  var _cameraPermissionDenied = false;
  var _capturing = false;

  ScanCaptureService? _captureService;
  ValueListenable<BarcodeDetectionFrame?>? _overlayListenable;
  final _internalOverlay = ValueNotifier<BarcodeDetectionFrame?>(null);
  BarcodeDetectionFrame? _pendingOverlayFrame;
  BarcodeDetectionFrame? _overlayFrame;
  Timer? _overlayTimer;

  var _aiWarmUpStarted = false;

  BarcodeScanner? _barcodeScanner;
  DateTime _lastBarcodeScanAt = DateTime.fromMillisecondsSinceEpoch(0);
  var _barcodeBusy = false;
  var _barcodeRevision = 0;

  Timer? _autoCaptureTimer;
  String? _autoCaptureCandidate;
  DateTime? _autoCaptureCandidateSince;
  DateTime? _autoCaptureCandidateLastSeen;
  final Map<String, DateTime> _autoCaptureRecent = {};
  var _autoCaptureFiring = false;

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

        if (!_aiWarmUpStarted) {
          _aiWarmUpStarted = true;
          unawaited(ref.read(aiInferenceProvider).warmUp());
        }
      }
    }
    _syncOverlayListenable();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.active) {
      _initCameraIfNeeded();

      if (!_aiWarmUpStarted) {
        _aiWarmUpStarted = true;
        unawaited(ref.read(aiInferenceProvider).warmUp());
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _overlayListenable?.removeListener(_handleOverlayInput);
    _overlayTimer?.cancel();
    _autoCaptureTimer?.cancel();
    _controller?.dispose();
    _internalOverlay.dispose();
    _barcodeScanner?.close();
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
    final controller = _controller;
    if (controller == null) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
      return;
    }
    if (state == AppLifecycleState.resumed) {
      _initCameraIfNeeded();
    }
  }

  void _deactivateCamera() {
    final controller = _controller;
    if (controller == null) return;

    _controller = null;
    try {
      unawaited(controller.dispose());
    } catch (_) {
      // Ignore dispose failures on unsupported camera backends.
    }

    if (mounted) {
      setState(() {
        _error = null;
        _cameraPermissionDenied = false;
        _cameraPermissionPermanentlyDenied = false;
        _overlayFrame = null;
        _pendingOverlayFrame = null;
      });
    }

    _autoCaptureTimer?.cancel();
    _autoCaptureTimer = null;
    _autoCaptureCandidate = null;
    _autoCaptureCandidateSince = null;
    _autoCaptureCandidateLastSeen = null;
    _autoCaptureFiring = false;
  }

  void _handleBarcodeDetectionsForAutoCapture(
    List<BarcodeDetection> detections,
  ) {
    if (!widget.active) return;
    if (_capturing) return;

    if (detections.isEmpty) {
      _autoCaptureTimer?.cancel();
      _autoCaptureTimer = null;
      _autoCaptureCandidate = null;
      _autoCaptureCandidateSince = null;
      _autoCaptureCandidateLastSeen = null;
      return;
    }

    final now = DateTime.now();
    final value = detections.first.value;

    // Prune stale cooldown entries.
    _autoCaptureRecent.removeWhere(
      (_, t) => now.difference(t) >= _autoCaptureCooldown,
    );

    if (_autoCaptureCandidate != value) {
      _autoCaptureCandidate = value;
      _autoCaptureCandidateSince = now;
      _autoCaptureCandidateLastSeen = now;
      _autoCaptureTimer?.cancel();
      _autoCaptureTimer = Timer(_autoCaptureDebounce, _maybeFireAutoCapture);
      return;
    }

    _autoCaptureCandidateLastSeen = now;
    _autoCaptureTimer ??= Timer(_autoCaptureDebounce, _maybeFireAutoCapture);
  }

  void _maybeFireAutoCapture() {
    _autoCaptureTimer = null;

    if (!mounted) return;
    if (!widget.active) return;
    if (_capturing) return;
    if (_autoCaptureFiring) return;

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final now = DateTime.now();
    final value = _autoCaptureCandidate;
    if (value == null || value.isEmpty) return;

    final lastSeen = _autoCaptureCandidateLastSeen;
    if (lastSeen == null) return;
    if (now.difference(lastSeen) > _autoCaptureFreshnessWindow) return;

    final since = _autoCaptureCandidateSince;
    if (since == null || now.difference(since) < _autoCaptureDebounce) {
      _autoCaptureTimer = Timer(_autoCaptureDebounce, _maybeFireAutoCapture);
      return;
    }

    final recentAt = _autoCaptureRecent[value];
    if (recentAt != null && now.difference(recentAt) < _autoCaptureCooldown) {
      return;
    }

    _autoCaptureFiring = true;
    _autoCaptureRecent[value] = now;
    _autoCaptureCandidate = null;
    _autoCaptureCandidateSince = null;
    _autoCaptureCandidateLastSeen = null;

    // Avoid stopping the image stream from within the image-stream callback.
    unawaited(
      Future<void>.delayed(
        Duration.zero,
      ).then((_) => _capture()).whenComplete(() => _autoCaptureFiring = false),
    );
  }

  Future<void> _initCameraIfNeeded() async {
    if (!widget.active) return;
    if (_controller != null) return;

    final l10n = AppLocalizations.of(context)!;

    final hasPermission = await _ensureCameraPermission();
    if (!hasPermission) return;
    if (!mounted || !widget.active) return;

    try {
      final cameras = await availableCameras();
      if (!mounted || !widget.active) return;

      if (cameras.isEmpty) {
        setState(() => _error = l10n.scannerNoCamerasAvailable);
        return;
      }

      final controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller.initialize();
      if (!mounted || !widget.active) {
        await controller.dispose();
        return;
      }

      if (widget.barcodeOverlayListenable == null) {
        _barcodeScanner ??= BarcodeScanner();
        await _startBarcodeStreamIfPossible(controller);
      }
      if (!mounted || !widget.active) {
        await controller.dispose();
        return;
      }

      setState(() {
        _error = null;
        _cameraPermissionDenied = false;
        _cameraPermissionPermanentlyDenied = false;
        _controller = controller;
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
    final db = ref.read(appDatabaseProvider);
    final config = ref.read(appConfigProvider);
    final imageStorage = ref.read(scanImageStorageProvider);
    final haulId = ref.read(defaultHaulIdProvider);
    final userId = ref.read(activeUserIdProvider);
    final aiInference = ref.read(aiInferenceProvider);
    final analytics = ref.read(analyticsProvider);

    final controller = _controller;
    final captureService = _captureService;
    if (controller == null || !controller.value.isInitialized) return;
    if (_capturing) return;

    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    final service =
        captureService ??
        ScanCaptureService(
          config: config,
          db: db,
          imageStorage: imageStorage,
          aiInference: aiInference,
          analytics: analytics,
        );
    _captureService ??= service;

    setState(() => _capturing = true);
    try {
      analytics.event('scan_started');
      final resumeBarcodeStream =
          widget.barcodeOverlayListenable == null &&
          (controller.value.isStreamingImages);
      if (resumeBarcodeStream) {
        await controller.stopImageStream();
      }

      final file = await controller.takePicture();
      final captured = await service.persistCapturedImage(
        haulId: haulId,
        userId: userId,
        sourceImage: File(file.path),
      );
      if (!mounted) return;

      await HapticFeedback.lightImpact();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.snackbarSavedScan(captured.id))),
      );

      if (resumeBarcodeStream && mounted) {
        await _startBarcodeStreamIfPossible(controller);
      }
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

  Future<void> _startBarcodeStreamIfPossible(
    CameraController controller,
  ) async {
    if (controller.value.isStreamingImages) return;

    try {
      await controller.startImageStream((image) async {
        if (!mounted) return;
        if (_capturing) return;
        if (_barcodeBusy) return;

        final now = DateTime.now();
        if (now.difference(_lastBarcodeScanAt) < _barcodeMinInterval) return;
        _lastBarcodeScanAt = now;

        final scanner = _barcodeScanner;
        if (scanner == null) return;

        _barcodeBusy = true;
        try {
          final input = inputImageFromCameraImage(
            image: image,
            sensorOrientation: controller.description.sensorOrientation,
          );
          if (input == null) return;

          final barcodes = await scanner.processImage(input);
          final detections = <BarcodeDetection>[];
          for (final b in barcodes) {
            final value = (b.rawValue ?? b.displayValue)?.trim();
            if (value == null || value.isEmpty) continue;
            if (b.boundingBox == Rect.zero) continue;
            detections.add(
              BarcodeDetection(value: value, boundingBox: b.boundingBox),
            );
          }

          _handleBarcodeDetectionsForAutoCapture(detections);
          _internalOverlay.value = BarcodeDetectionFrame(
            imageSize: Size(image.width.toDouble(), image.height.toDouble()),
            detections: detections,
            revision: _barcodeRevision++,
          );
        } catch (_) {
          // Ignore barcode errors; scanner is a fallback.
        } finally {
          _barcodeBusy = false;
        }
      });
    } catch (_) {
      // Image streaming isn't available on all camera backends.
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

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final haulId = ref.watch(defaultHaulIdProvider);
    final userId = ref.watch(activeUserIdProvider);
    final l10n = AppLocalizations.of(context)!;
    final controller = _controller;
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
                  : controller == null || !controller.value.isInitialized
                  ? const Center(child: CircularProgressIndicator())
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CameraPreview(controller),
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

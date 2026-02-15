import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

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

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({
    super.key,
    this.barcodeOverlayListenable,
    this.onBarcodeTap,
  });

  final ValueListenable<BarcodeDetectionFrame?>? barcodeOverlayListenable;
  final ValueChanged<String>? onBarcodeTap;

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with WidgetsBindingObserver {
  static const _overlayUpdateInterval = Duration(milliseconds: 80);
  static const _barcodeMinInterval = Duration(milliseconds: 250);

  CameraController? _controller;
  String? _error;
  var _capturing = false;

  ScanCaptureService? _captureService;
  ValueListenable<BarcodeDetectionFrame?>? _overlayListenable;
  final _internalOverlay = ValueNotifier<BarcodeDetectionFrame?>(null);
  BarcodeDetectionFrame? _pendingOverlayFrame;
  BarcodeDetectionFrame? _overlayFrame;
  Timer? _overlayTimer;

  BarcodeScanner? _barcodeScanner;
  DateTime _lastBarcodeScanAt = DateTime.fromMillisecondsSinceEpoch(0);
  var _barcodeBusy = false;
  var _barcodeRevision = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncOverlayListenable();
  }

  @override
  void didUpdateWidget(covariant ScannerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncOverlayListenable();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initCameraIfNeeded();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _overlayListenable?.removeListener(_handleOverlayInput);
    _overlayTimer?.cancel();
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

  Future<void> _initCameraIfNeeded() async {
    if (_controller != null) return;

    final l10n = AppLocalizations.of(context)!;

    try {
      final cameras = await availableCameras();
      if (!mounted) return;

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
      if (!mounted) return;

      if (widget.barcodeOverlayListenable == null) {
        _barcodeScanner ??= BarcodeScanner();
        await _startBarcodeStreamIfPossible(controller);
      }
      if (!mounted) return;

      setState(() {
        _error = null;
        _controller = controller;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = l10n.scannerCameraInitFailed('$e'));
    }
  }

  Future<void> _capture() async {
    final db = ref.read(appDatabaseProvider);
    final imageStorage = ref.read(scanImageStorageProvider);
    final haulId = ref.read(defaultHaulIdProvider);
    final aiInference = ref.read(aiInferenceProvider);

    final controller = _controller;
    final captureService = _captureService;
    if (controller == null || !controller.value.isInitialized) return;
    if (_capturing) return;

    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    final service =
        captureService ??
        ScanCaptureService(
          db: db,
          imageStorage: imageStorage,
          aiInference: aiInference,
        );
    _captureService ??= service;

    setState(() => _capturing = true);
    try {
      final resumeBarcodeStream =
          widget.barcodeOverlayListenable == null &&
          (controller.value.isStreamingImages);
      if (resumeBarcodeStream) {
        await controller.stopImageStream();
      }

      final file = await controller.takePicture();
      final captured = await service.persistCapturedImage(
        haulId: haulId,
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
    final l10n = AppLocalizations.of(context)!;

    try {
      final queued = await db.scanItemsDao.queueReadyToSyncInHaul(
        haulId: haulId,
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
                  style: const TextStyle(fontWeight: FontWeight.w700),
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
                        onRetry: _initCameraIfNeeded,
                        retryLabel: AppLocalizations.of(context)!.buttonRetry,
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
            stream: db.scanItemsDao.watchByHaulId(haulId),
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

import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../ai/model_manager.dart';
import 'offline_detection_types.dart';
import 'offline_detector_parser.dart';
import 'offline_model_catalog.dart';

class OfflineDetector {
  OfflineDetector({
    OfflineModelSpec? spec,
    Future<Directory> Function()? baseDirProvider,
    List<String>? labels,
  }) : spec = spec ?? kOfflineDetectionModel,
       _labels = List<String>.unmodifiable(labels ?? kCocoLabels),
       _manager = ModelManager(
         spec: ModelSpec(
           id: (spec ?? kOfflineDetectionModel).id,
           fileName: (spec ?? kOfflineDetectionModel).fileName,
         ),
         baseDirProvider: baseDirProvider,
       );

  final OfflineModelSpec spec;
  final ModelManager _manager;
  final List<String> _labels;

  Future<ModelInstallState> installState() => _manager.state();

  Future<List<OfflineDetection>> detectImageBytes(Uint8List imageBytes) async {
    final modelFile = await _requireInstalledModelFile();

    final raw = await Isolate.run(() {
      return _runDetectionInIsolate(
        modelPath: modelFile.path,
        imageBytes: imageBytes,
      );
    });

    final boxes = (raw['boxes'] as List<List<double>>);
    final scores = (raw['scores'] as List<double>);
    final classes = (raw['classes'] as List<int>);
    final count = (raw['count'] as int);

    return parseDetections(
      boxes: boxes,
      scores: scores,
      classes: classes,
      count: count,
      resolveLabel: _resolveLabel,
    );
  }

  String _resolveLabel(int classIndex) {
    if (classIndex >= 0 && classIndex < _labels.length) {
      return _labels[classIndex];
    }
    return 'class_$classIndex';
  }

  Future<File> _requireInstalledModelFile() async {
    final state = await _manager.state();
    if (!state.installed || state.file == null) {
      throw StateError('Offline model is not installed: ${spec.id}');
    }
    return state.file!;
  }
}

Map<String, Object> _runDetectionInIsolate({
  required String modelPath,
  required Uint8List imageBytes,
}) {
  final image = img.decodeImage(imageBytes);
  if (image == null) {
    throw const FormatException('Failed to decode image bytes');
  }

  final upright = img.bakeOrientation(image);
  final interpreter = Interpreter.fromFile(File(modelPath));
  try {
    final inputTensor = interpreter.getInputTensor(0);
    final inputShape = inputTensor.shape;
    if (inputShape.length != 4 || inputShape[0] != 1 || inputShape[3] != 3) {
      throw StateError('Unexpected model input shape: $inputShape');
    }

    final inputH = inputShape[1];
    final inputW = inputShape[2];

    final resized = img.copyResize(
      upright,
      width: inputW,
      height: inputH,
      interpolation: img.Interpolation.linear,
    );

    final input = _imageToModelInput(
      resized,
      inputTensor.type,
    ).reshape(<int>[1, inputH, inputW, 3]);

    final outputTensors = interpreter.getOutputTensors();
    if (outputTensors.length < 4) {
      throw StateError(
        'Unexpected model output count: ${outputTensors.length} (expected >= 4)',
      );
    }

    final indices = _guessOutputIndices(outputTensors);
    final boxesIndex = indices.boxes;
    final classesIndex = indices.classes;
    final scoresIndex = indices.scores;
    final countIndex = indices.count;

    final boxesShape = outputTensors[boxesIndex].shape;
    final classesShape = outputTensors[classesIndex].shape;
    final scoresShape = outputTensors[scoresIndex].shape;
    final countShape = outputTensors[countIndex].shape;

    final boxesBuf = List<double>.filled(
      _prod(boxesShape),
      0,
    ).reshape(boxesShape);
    final classesBuf = List<double>.filled(
      _prod(classesShape),
      0,
    ).reshape(classesShape);
    final scoresBuf = List<double>.filled(
      _prod(scoresShape),
      0,
    ).reshape(scoresShape);
    final countBuf = List<double>.filled(
      _prod(countShape),
      0,
    ).reshape(countShape);

    final outputs = <int, Object>{
      boxesIndex: boxesBuf,
      classesIndex: classesBuf,
      scoresIndex: scoresBuf,
      countIndex: countBuf,
    };

    interpreter.runForMultipleInputs(<Object>[input], outputs);

    final boxes = _extractBoxes(outputs[boxesIndex]!);
    final scores = _extractVector(outputs[scoresIndex]!);
    final classes = _extractVector(
      outputs[classesIndex]!,
    ).map((v) => v.toInt()).toList(growable: false);
    final countRaw = _extractVector(outputs[countIndex]!).isEmpty
        ? 0
        : _extractVector(outputs[countIndex]!).first;

    final count = countRaw.toInt();

    return <String, Object>{
      'boxes': boxes,
      'scores': scores,
      'classes': classes,
      'count': count,
    };
  } finally {
    interpreter.close();
  }
}

List<num> _imageToModelInput(img.Image image, TensorType type) {
  if (type == TensorType.uint8) {
    final out = Uint8List(image.width * image.height * 3);
    var o = 0;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final p = image.getPixel(x, y);
        out[o++] = p.r.toInt();
        out[o++] = p.g.toInt();
        out[o++] = p.b.toInt();
      }
    }
    return out;
  }

  if (type == TensorType.float32) {
    final out = Float32List(image.width * image.height * 3);
    var o = 0;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final p = image.getPixel(x, y);
        out[o++] = p.r / 255.0;
        out[o++] = p.g / 255.0;
        out[o++] = p.b / 255.0;
      }
    }
    return out;
  }

  throw StateError('Unsupported model input tensor type: $type');
}

List<List<double>> _extractBoxes(Object raw) {
  // Typical shape: [1, N, 4].
  final asList = raw as List;
  if (asList.isEmpty) return const <List<double>>[];
  final inner = asList.first as List;
  return inner
      .map(
        (row) => (row as List)
            .map((v) => (v as num).toDouble())
            .toList(growable: false),
      )
      .toList(growable: false);
}

List<double> _extractVector(Object raw) {
  // Typical shape: [1, N] or [N].
  if (raw is List && raw.isNotEmpty && raw.first is List) {
    final inner = raw.first as List;
    return inner.map((v) => (v as num).toDouble()).toList(growable: false);
  }
  if (raw is List) {
    return raw.map((v) => (v as num).toDouble()).toList(growable: false);
  }
  return const <double>[];
}

int _prod(List<int> shape) {
  var p = 1;
  for (final v in shape) {
    p *= v;
  }
  return p;
}

({int boxes, int classes, int scores, int count}) _guessOutputIndices(
  List<Tensor> tensors,
) {
  int? boxes;
  int? classes;
  int? scores;
  int? count;

  for (var i = 0; i < tensors.length; i++) {
    final t = tensors[i];
    final name = t.name.toLowerCase();
    final shape = t.shape;

    final looksLikeBoxes = shape.length == 3 && shape.last == 4;
    final looksLikeCount =
        shape.length == 1 || (shape.length == 2 && shape.last == 1);

    if (looksLikeBoxes && boxes == null) {
      boxes = i;
      continue;
    }

    if (looksLikeCount && count == null) {
      count = i;
      continue;
    }

    if (shape.length == 2) {
      if ((name.contains('class') || name.contains('classes')) &&
          classes == null) {
        classes = i;
        continue;
      }
      if (name.contains('score') && scores == null) {
        scores = i;
        continue;
      }
    }
  }

  // Fallback to canonical TF Lite object detection ordering.
  return (
    boxes: boxes ?? 0,
    classes: classes ?? 1,
    scores: scores ?? 2,
    count: count ?? 3,
  );
}

// COCO label map (80 classes). Index 0 corresponds to 'person'.
const List<String> kCocoLabels = <String>[
  'person',
  'bicycle',
  'car',
  'motorcycle',
  'airplane',
  'bus',
  'train',
  'truck',
  'boat',
  'traffic light',
  'fire hydrant',
  'stop sign',
  'parking meter',
  'bench',
  'bird',
  'cat',
  'dog',
  'horse',
  'sheep',
  'cow',
  'elephant',
  'bear',
  'zebra',
  'giraffe',
  'backpack',
  'umbrella',
  'handbag',
  'tie',
  'suitcase',
  'frisbee',
  'skis',
  'snowboard',
  'sports ball',
  'kite',
  'baseball bat',
  'baseball glove',
  'skateboard',
  'surfboard',
  'tennis racket',
  'bottle',
  'wine glass',
  'cup',
  'fork',
  'knife',
  'spoon',
  'bowl',
  'banana',
  'apple',
  'sandwich',
  'orange',
  'broccoli',
  'carrot',
  'hot dog',
  'pizza',
  'donut',
  'cake',
  'chair',
  'couch',
  'potted plant',
  'bed',
  'dining table',
  'toilet',
  'tv',
  'laptop',
  'mouse',
  'remote',
  'keyboard',
  'cell phone',
  'microwave',
  'oven',
  'toaster',
  'sink',
  'refrigerator',
  'book',
  'clock',
  'vase',
  'scissors',
  'teddy bear',
  'hair drier',
  'toothbrush',
];

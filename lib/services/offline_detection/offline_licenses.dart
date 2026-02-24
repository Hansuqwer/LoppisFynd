import 'dart:async';

import 'package:flutter/foundation.dart';

import 'offline_model_catalog.dart';

void registerOfflineLicenses() {
  for (final spec in kOfflineModels) {
    _addOfflineLicense(
      packages: ['Offline ML runtime (${spec.id})'],
      sourceUrl: spec.runtimeLicenseSourceUrl,
      fullText: spec.runtimeLicenseFullText,
      header: 'Offline ML runtime / inference stack',
    );

    _addOfflineLicense(
      packages: ['Offline model weights (${spec.displayName})'],
      sourceUrl: spec.weightsLicenseSourceUrl,
      fullText: spec.weightsLicenseFullText,
      header: 'Offline model weights artifact',
      extraLines: [
        'Weights source: ${spec.weightsSourceUrl}',
        'Model fileName: ${spec.fileName}',
        'Model version: ${spec.version}',
      ],
    );

    _addOfflineLicense(
      packages: ['Offline dataset attribution (${spec.displayName})'],
      sourceUrl: spec.datasetAttributionSourceUrl,
      fullText: spec.datasetAttributionFullText,
      header: 'Offline model dataset / training attribution',
    );
  }
}

void _addOfflineLicense({
  required List<String> packages,
  required Uri sourceUrl,
  required String fullText,
  required String header,
  List<String> extraLines = const [],
}) {
  final text = StringBuffer()
    ..writeln(header)
    ..writeln()
    ..writeln('Source: $sourceUrl');

  if (extraLines.isNotEmpty) {
    text.writeln();
    for (final line in extraLines) {
      text.writeln(line);
    }
  }

  text
    ..writeln()
    ..writeln('---')
    ..writeln()
    ..write(fullText.trim());

  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(packages, text.toString());
  });
}

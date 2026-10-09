import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const String _featuresPrefix = 'package:kid_matix/features/';
const String _corePrefix = 'package:kid_matix/core/';

/// Parts of `core/` that are pure Dart and may be imported by a domain layer.
const List<String> _pureCoreFolders = <String>[
  'constants',
  'entities',
  'error',
  'services',
  'usecases',
];

/// Parts of `core/` that must not import Flutter at all.
const List<String> _flutterFreeCoreFolders = <String>[
  'entities',
  'error',
  'usecases',
];

/// Parts of `core/` that assemble the app and may import features.
const List<String> _compositionCoreFolders = <String>['di', 'router'];

final RegExp _importPattern = RegExp(
  r'''^\s*import\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

/// A Dart source file of `lib/` with the libraries it imports.
final class _SourceFile {
  _SourceFile(File file)
    : path = file.path.replaceAll(r'\', '/'),
      importedUris = _importPattern
          .allMatches(file.readAsStringSync())
          .map((RegExpMatch match) => match.group(1)!)
          .toList();

  final String path;
  final List<String> importedUris;

  List<String> get _segments => path.split('/');

  bool get isInFeature => path.startsWith('lib/features/');

  bool get isInCore => path.startsWith('lib/core/');

  /// Name of the owning feature, e.g. `profile`.
  String get feature => _segments[2];

  /// Layer inside the feature: `data`, `domain` or `presentation`.
  String get layer => _segments.length > 4 ? _segments[3] : '';

  /// Folder inside `core/`, e.g. `storage`.
  String get coreFolder => _segments[2];

  /// Describes a rule violation caused by [uris].
  String describe(Iterable<String> uris) => '$path imports ${uris.join(', ')}';
}

List<_SourceFile> _readSourceFiles() {
  return Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((File file) => file.path.endsWith('.dart'))
      .map(_SourceFile.new)
      .toList();
}

bool _isAllowedInDomain(String uri, String feature) {
  if (uri.startsWith('dart:')) return uri != 'dart:ui';
  if (uri.startsWith('package:meta/')) return true;
  if (uri.startsWith('$_featuresPrefix$feature/domain/')) return true;
  return _pureCoreFolders.any(
    (String folder) => uri.startsWith('$_corePrefix$folder/'),
  );
}

bool _isOtherFeature(String uri, String feature) {
  if (!uri.startsWith(_featuresPrefix)) return false;
  return !uri.startsWith('$_featuresPrefix$feature/');
}

bool _isFeatureDataLayer(String uri) {
  return uri.startsWith(_featuresPrefix) && uri.contains('/data/');
}

bool _isFlutter(String uri) {
  return uri.startsWith('package:flutter') || uri == 'dart:ui';
}

void main() {
  final List<_SourceFile> sourceFiles = _readSourceFiles();
  final List<_SourceFile> featureFiles = sourceFiles
      .where((_SourceFile file) => file.isInFeature)
      .toList();
  group('architecture', () {
    test('the source tree is scanned', () {
      // Arrange
      const String expectedPath = 'lib/main.dart';
      // Act
      final Iterable<String> actualPaths = sourceFiles.map(
        (_SourceFile file) => file.path,
      );
      // Assert
      expect(actualPaths, contains(expectedPath));
    });
    test('domain layers import only pure Dart code', () {
      // Arrange
      final List<String> actualViolations = <String>[];
      final Iterable<_SourceFile> domainFiles = featureFiles.where(
        (_SourceFile file) => file.layer == 'domain',
      );
      // Act
      for (final _SourceFile file in domainFiles) {
        final Iterable<String> forbiddenUris = file.importedUris.where(
          (String uri) => !_isAllowedInDomain(uri, file.feature),
        );
        if (forbiddenUris.isNotEmpty) {
          actualViolations.add(file.describe(forbiddenUris));
        }
      }
      // Assert
      expect(actualViolations, isEmpty);
    });
    test('a feature never imports another feature', () {
      // Arrange
      final List<String> actualViolations = <String>[];
      // Act
      for (final _SourceFile file in featureFiles) {
        final Iterable<String> foreignUris = file.importedUris.where(
          (String uri) => _isOtherFeature(uri, file.feature),
        );
        if (foreignUris.isNotEmpty) {
          actualViolations.add(file.describe(foreignUris));
        }
      }
      // Assert
      expect(actualViolations, isEmpty);
    });
    test('presentation layers never import a data layer', () {
      // Arrange
      final List<String> actualViolations = <String>[];
      final Iterable<_SourceFile> presentationFiles = featureFiles.where(
        (_SourceFile file) => file.layer == 'presentation',
      );
      // Act
      for (final _SourceFile file in presentationFiles) {
        final Iterable<String> dataUris = file.importedUris.where(
          _isFeatureDataLayer,
        );
        if (dataUris.isNotEmpty) {
          actualViolations.add(file.describe(dataUris));
        }
      }
      // Assert
      expect(actualViolations, isEmpty);
    });
    test('core imports features only from di and router', () {
      // Arrange
      final List<String> actualViolations = <String>[];
      final Iterable<_SourceFile> guardedCoreFiles = sourceFiles.where(
        (_SourceFile file) =>
            file.isInCore &&
            !_compositionCoreFolders.contains(file.coreFolder),
      );
      // Act
      for (final _SourceFile file in guardedCoreFiles) {
        final Iterable<String> featureUris = file.importedUris.where(
          (String uri) => uri.startsWith(_featuresPrefix),
        );
        if (featureUris.isNotEmpty) {
          actualViolations.add(file.describe(featureUris));
        }
      }
      // Assert
      expect(actualViolations, isEmpty);
    });
    test('pure core folders never import Flutter', () {
      // Arrange
      final List<String> actualViolations = <String>[];
      final Iterable<_SourceFile> pureCoreFiles = sourceFiles.where(
        (_SourceFile file) =>
            file.isInCore &&
            _flutterFreeCoreFolders.contains(file.coreFolder),
      );
      // Act
      for (final _SourceFile file in pureCoreFiles) {
        final Iterable<String> flutterUris = file.importedUris.where(
          _isFlutter,
        );
        if (flutterUris.isNotEmpty) {
          actualViolations.add(file.describe(flutterUris));
        }
      }
      // Assert
      expect(actualViolations, isEmpty);
    });
  });
}

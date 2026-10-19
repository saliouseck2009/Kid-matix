import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/math_word/data/datasources/math_word_asset_source.dart';
import 'package:kid_matix/features/math_word/domain/entities/math_word.dart';
import 'package:kid_matix/features/math_word/domain/entities/math_word_catalog.dart';
import 'package:kid_matix/features/math_word/domain/entities/operation_statement.dart';

/// The data asset follows the content table of the owner: when the table
/// changes, `python3 tool/build_math_words.py` rebuilds the asset.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<String> tableLines = File(
    'docs/product/math-words.md',
  ).readAsLinesSync();

  test('is read from the bundle', () async {
    // Act
    final MathWordCatalog actualCatalog = await MathWordAssetSource(
      bundle: rootBundle,
    ).load();
    // Assert
    expect(actualCatalog.words, hasLength(40));
    expect(actualCatalog.statements, hasLength(20));
  });

  test('holds the words of the table, in its order', () async {
    // Arrange
    final RegExp row = RegExp(r'^\| `([a-z_]+)` \| ([^|]+) \|');
    final List<String> tableKeys = <String>[
      for (final String line in tableLines.takeWhile(
        (String line) => !line.startsWith('## 2.'),
      ))
        if (row.firstMatch(line) case final RegExpMatch match) match.group(1)!,
    ];
    // Act
    final MathWordCatalog actualCatalog = await MathWordAssetSource(
      bundle: rootBundle,
    ).load();
    // Assert
    expect(
      actualCatalog.words.map((MathWord word) => word.wordKey).toList(),
      tableKeys,
    );
  });

  test('holds the statements of the table, in its order', () async {
    // Arrange
    final List<String> tableIds = <String>[
      for (final String line in tableLines)
        if (line.startsWith('| OP-')) line.split('|')[1].trim(),
    ];
    // Act
    final MathWordCatalog actualCatalog = await MathWordAssetSource(
      bundle: rootBundle,
    ).load();
    // Assert
    expect(
      actualCatalog.statements
          .map((OperationStatement statement) => statement.id)
          .toList(),
      tableIds,
    );
  });

  test('refuses a bundle whose asset is not a catalog', () async {
    // Act & Assert
    await expectLater(
      MathWordAssetSource(bundle: _BadBundle()).load(),
      throwsFormatException,
    );
  });
}

final class _BadBundle extends CachingAssetBundle {
  _BadBundle();

  @override
  Future<ByteData> load(String key) async {
    return ByteData.sublistView(Uint8List.fromList('[]'.codeUnits));
  }
}

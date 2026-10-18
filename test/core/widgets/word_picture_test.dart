import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/widgets/word_picture/word_picture_view.dart';
import 'package:kid_matix/core/widgets/word_picture/word_scene.dart';
import 'package:kid_matix/core/widgets/word_picture/word_scenes.dart';

import '../../features/math_word/helpers/math_word_fixtures.dart';

/// Guard of the provisional drawings: every math word has one, and every
/// scene can be painted.
void main() {
  final List<String> wordKeys = loadMathWordCatalog().words
      .map((word) => word.wordKey)
      .toList();

  test('draws a scene for every math word and for no other key', () {
    // Assert
    expect(WordScenes.wordKeys.toSet(), wordKeys.toSet());
  });

  test('falls back to a question mark for a word without scene', () {
    // Assert
    expect(WordScenes.has('inconnu'), isFalse);
    expect(WordScenes.of('inconnu'), WordScenes.fallback);
    expect(WordScenes.fallback.single, isA<SceneMystery>());
  });

  testWidgets('paints every scene without error, labeled for a screen reader', (
    WidgetTester tester,
  ) async {
    for (final String key in <String>[...wordKeys, 'inconnu']) {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: 160,
              child: WordPictureView(wordKey: key, label: 'mot $key'),
            ),
          ),
        ),
      );
      // Assert
      expect(tester.takeException(), isNull, reason: key);
      expect(find.bySemanticsLabel('mot $key'), findsOneWidget, reason: key);
    }
  });
}

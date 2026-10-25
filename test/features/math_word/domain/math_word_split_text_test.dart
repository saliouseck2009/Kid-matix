import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/sentence_part.dart';
import 'package:kid_matix/features/math_word/domain/entities/math_word_catalog.dart';
import 'package:kid_matix/features/math_word/domain/services/catalog_sentence_splitter.dart';

import '../helpers/math_word_fixtures.dart';

/// The math words found in the statements of the word problems (F30-05):
/// the first whole-word match of each word or form, the longest wins.
void main() {
  final MathWordCatalog catalog = loadMathWordCatalog();

  Set<String> keysOf(String text) {
    return catalog
        .splitText(text)
        .map((SentencePart part) => part.wordKey)
        .nonNulls
        .toSet();
  }

  test('keeps the whole text, piece by piece', () {
    // Arrange
    const String text =
        'Awa a 12 mangues. Elle en donne 5. Combien reste-t-il ?';
    // Assert
    expect(
      catalog.splitText(text).map((SentencePart p) => p.text).join(),
      text,
    );
  });

  test('finds a word by its form and by its own text', () {
    // Assert
    expect(keysOf('Elle en donne 5 mangues.'), contains('donner'));
    expect(keysOf('Il veut les partager avec ses amis.'), contains('partager'));
    expect(keysOf('Il partage ses 12 mangues.'), contains('partager'));
  });

  test('prefers the longest expression where two overlap', () {
    // Assert
    expect(
      keysOf('Elle les partage également entre 3 amis.'),
      containsAll(<String>['partager_egalement']),
    );
    expect(
      keysOf('Elle les partage également entre 3 amis.'),
      isNot(contains('partager')),
    );
    expect(
      keysOf('Combien de fois peut-elle faire un tas ?'),
      allOf(contains('combien_de_fois'), isNot(contains('combien'))),
    );
  });

  test('touches a word once and never inside a longer word', () {
    // Act
    final List<SentencePart> actual = catalog.splitText(
      'Il reçoit 4 billes. Elle reçoit 3 billes.',
    );
    // Assert
    expect(
      actual.where((SentencePart p) => p.wordKey == 'recevoir'),
      hasLength(1),
    );
    expect(keysOf('Un arbre est ensemblier.'), isNot(contains('ensemble')));
  });

  test('gives the pieces through the SentenceSplitter of the core', () {
    // Act
    final List<SentencePart> actual = CatalogSentenceSplitter(
      catalog: catalog,
    ).split('Il en reste 7.');
    // Assert
    expect(actual.map((SentencePart p) => p.wordKey).nonNulls, <String>[
      'il_reste',
    ]);
  });
}

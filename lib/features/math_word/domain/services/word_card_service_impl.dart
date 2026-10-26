import 'package:kid_matix/core/entities/word_card.dart';
import 'package:kid_matix/core/services/word_card_service.dart';
import 'package:kid_matix/features/math_word/domain/entities/math_word.dart';
import 'package:kid_matix/features/math_word/domain/entities/math_word_catalog.dart';

/// [WordCardService] over the catalog of the math words.
final class WordCardServiceImpl implements WordCardService {
  /// Creates the service over [catalog].
  const WordCardServiceImpl({required this._catalog});

  final MathWordCatalog _catalog;

  @override
  List<WordCard> readCards() {
    return <WordCard>[
      for (final MathWord word in _catalog.words)
        WordCard(
          wordKey: word.wordKey,
          text: word.text,
          meaning: word.meaning,
          example: word.example,
          helpExplanations: _catalog.helpExplanationsOf(word.wordKey),
          helpExamples: _catalog.helpExamplesOf(word.wordKey),
        ),
    ];
  }
}

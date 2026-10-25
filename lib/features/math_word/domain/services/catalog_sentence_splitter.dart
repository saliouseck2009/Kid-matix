import 'package:kid_matix/core/quiz/sentence_part.dart';
import 'package:kid_matix/core/services/sentence_splitter.dart';
import 'package:kid_matix/features/math_word/domain/entities/math_word_catalog.dart';

/// [SentenceSplitter] over the words of the math word catalog.
final class CatalogSentenceSplitter implements SentenceSplitter {
  /// Creates the splitter of [catalog].
  const CatalogSentenceSplitter({required this.catalog});

  /// The words that can be touched.
  final MathWordCatalog catalog;

  @override
  List<SentencePart> split(String text) => catalog.splitText(text);
}

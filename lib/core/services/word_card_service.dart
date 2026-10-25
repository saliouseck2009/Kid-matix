import 'package:kid_matix/core/entities/word_card.dart';

/// The math words as the printable cards of the teacher show them
/// (F31-07).
///
/// Implemented by the math word feature, from its content asset.
abstract interface class WordCardService {
  /// Every math word, in the order of the content table.
  List<WordCard> readCards();
}

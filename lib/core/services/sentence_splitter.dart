import 'package:kid_matix/core/quiz/sentence_part.dart';

/// Cuts a French statement into pieces, the math words of lot F28 being
/// the pieces a child can touch.
///
/// Implemented by the math word feature, which owns the words; the problem
/// feature only asks for the pieces.
abstract interface class SentenceSplitter {
  /// The pieces of [text]: each math word it contains (the first whole-word
  /// match of each) is a piece with its key, the rest is plain text.
  List<SentencePart> split(String text);
}

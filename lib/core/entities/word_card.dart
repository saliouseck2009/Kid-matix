import 'package:meta/meta.dart';

/// One math word as a printed card shows it (F31-07): the word, its
/// simple meaning and its example in French, and the texts the owner
/// wrote in a help language, when there are some.
@immutable
final class WordCard {
  /// Creates the card of [wordKey].
  WordCard({
    required this.wordKey,
    required this.text,
    required this.meaning,
    required this.example,
    Map<String, String> helpExplanations = const <String, String>{},
    Map<String, String> helpExamples = const <String, String>{},
  }) : helpExplanations = Map<String, String>.unmodifiable(helpExplanations),
       helpExamples = Map<String, String>.unmodifiable(helpExamples);

  /// Key of the word, such as `il_reste`.
  final String wordKey;

  /// The word, such as « il reste ».
  final String text;

  /// What it means, in simple French.
  final String meaning;

  /// An everyday sentence using it.
  final String example;

  /// Its explanation written in each help language, by language code;
  /// a language is missing until the owner writes it (never invented).
  final Map<String, String> helpExplanations;

  /// Its example written in each help language, by language code.
  final Map<String, String> helpExamples;

  @override
  String toString() => 'WordCard($wordKey)';
}

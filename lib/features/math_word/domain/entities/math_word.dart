import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:meta/meta.dart';

/// One word or expression of the problems, such as "il reste": the thing
/// to master with the math words domain.
///
/// Its key never changes once released, since the stored progress and the
/// recordings refer to it: `word:<wordKey>`, such as `word:il_reste`.
@immutable
final class MathWord implements LearningItem {
  /// Creates the word.
  const MathWord({
    required this.wordKey,
    required this.familySlug,
    required this.notion,
    required this.text,
    required this.meaning,
    required this.example,
    required this.surface,
  });

  /// Prefix of every key of the domain.
  static const String keyPrefix = 'word';

  /// Short stable name of the word, the name of its recordings, such as
  /// `il_reste`.
  final String wordKey;

  /// Slug of the family (unit) of the word, such as `remove`.
  final String familySlug;

  /// The notion of the glossary the word belongs to; two words of the same
  /// notion mean the same thing, so their drawings are never offered as
  /// wrong answers to each other.
  final String notion;

  /// The word as written in French, such as "il reste".
  final String text;

  /// What it means, in simple French.
  final String meaning;

  /// A short everyday sentence that uses it.
  final String example;

  /// The form of the word inside [example], such as "reste".
  final String surface;

  @override
  String get key => '$keyPrefix:$wordKey';

  /// Two words are the same when they have the same key: the progress
  /// stored under a key belongs to one word only.
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MathWord && other.wordKey == wordKey;

  @override
  int get hashCode => wordKey.hashCode;

  @override
  String toString() => key;
}

import 'package:meta/meta.dart';

/// One piece of a sentence the child reads and touches: plain words, or a
/// math word to touch (lot F28).
@immutable
final class SentencePart {
  /// Creates the piece [text]; [wordKey] is the key of the math word it
  /// shows when the child can touch it, such as `il_reste`.
  const SentencePart(this.text, {this.wordKey});

  /// Words shown, with their spaces.
  final String text;

  /// Key of the math word, or `null` for plain words.
  final String? wordKey;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SentencePart && other.text == text && other.wordKey == wordKey;

  @override
  int get hashCode => Object.hash(text, wordKey);

  @override
  String toString() => wordKey == null ? text : '[$text]';
}

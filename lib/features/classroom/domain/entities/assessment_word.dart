import 'package:meta/meta.dart';

/// One word of the word check of an assessment, understood or not.
@immutable
final class AssessmentWord {
  /// Creates the word [itemKey].
  const AssessmentWord({required this.itemKey, required this.isUnderstood});

  /// Item of the math words, such as `word:il_reste`.
  final String itemKey;

  /// Whether the pupil's first answer about it was right.
  final bool isUnderstood;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AssessmentWord &&
            other.itemKey == itemKey &&
            other.isUnderstood == isUnderstood;
  }

  @override
  int get hashCode => Object.hash(itemKey, isUnderstood);
}

import 'package:meta/meta.dart';

/// One answer of a pupil, as the class mode keeps it.
@immutable
final class PracticeAnswer {
  /// Creates the answer at [position] about [itemKey].
  const PracticeAnswer({
    required this.position,
    required this.itemKey,
    required this.isCorrect,
    this.isRetry = false,
  });

  /// Order of the answer in its session, from 1.
  final int position;

  /// Item asked, such as `add:7+8`.
  final String itemKey;

  /// Whether the answer was right.
  final bool isCorrect;

  /// Whether it was a second chance, asked again after a mistake; the
  /// rules of the dashboard leave those out.
  final bool isRetry;

  /// Returns a copy with the given fields replaced.
  PracticeAnswer copyWith({
    int? position,
    String? itemKey,
    bool? isCorrect,
    bool? isRetry,
  }) {
    return PracticeAnswer(
      position: position ?? this.position,
      itemKey: itemKey ?? this.itemKey,
      isCorrect: isCorrect ?? this.isCorrect,
      isRetry: isRetry ?? this.isRetry,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PracticeAnswer &&
            other.position == position &&
            other.itemKey == itemKey &&
            other.isCorrect == isCorrect &&
            other.isRetry == isRetry;
  }

  @override
  int get hashCode => Object.hash(position, itemKey, isCorrect, isRetry);

  @override
  String toString() => 'PracticeAnswer($position, $itemKey, $isCorrect)';
}

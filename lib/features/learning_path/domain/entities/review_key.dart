import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:meta/meta.dart';

/// The unit key of a review stage of the path, stored with its stars.
///
/// `review:2` is the second review of the multiplication, released so in
/// version 1.0; the domains after it name themselves, `review:numbers:2`,
/// so a review key always tells its domain.
@immutable
final class ReviewKey {
  /// Creates the key of the [number]th review of [domainId].
  const ReviewKey({required this.domainId, required this.number});

  /// First part of every review key.
  static const String prefix = 'review';

  static const String _separator = ':';

  /// Learning domain of the review.
  final String domainId;

  /// Position of the review on the path, from 1.
  final int number;

  /// Reads [key]; `null` when it is not a review key.
  static ReviewKey? tryParse(String key) {
    final List<String> parts = key.split(_separator);
    if (parts.first != prefix) return null;
    final int? number = int.tryParse(parts.last);
    if (number == null) return null;
    return switch (parts.length) {
      2 => ReviewKey(
        domainId: LearningDomainIds.multiplication,
        number: number,
      ),
      3 => ReviewKey(domainId: parts[1], number: number),
      _ => null,
    };
  }

  /// The key, such as `review:2` or `review:numbers:2`.
  String toKey() {
    if (domainId == LearningDomainIds.multiplication) {
      return '$prefix$_separator$number';
    }
    return '$prefix$_separator$domainId$_separator$number';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ReviewKey &&
            other.domainId == domainId &&
            other.number == number;
  }

  @override
  int get hashCode => Object.hash(domainId, number);

  @override
  String toString() => toKey();
}

import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:meta/meta.dart';

/// The unit key of a review stage of the path, stored with its stars.
///
/// `review:2` is the second review of the multiplication, released so in
/// version 1.0; the domains after it name themselves, `review:numbers:2`,
/// so a review key always tells its domain.
@immutable
final class ReviewKey {
  /// Creates the key of the [number]th review of [domainId], a domain id
  /// without `:` that is not a number, so the key reads back one way.
  const ReviewKey({required this.domainId, required this.number})
    : assert(number > 0, 'reviews count from 1');

  /// Whether [domainId] can name a review: not empty, without the
  /// separator, and not a number, which a key would read as the review.
  static bool isValidDomainId(String domainId) {
    return domainId.isNotEmpty &&
        !domainId.contains(_separator) &&
        int.tryParse(domainId) == null;
  }

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
    if (number == null || number <= 0) return null;
    return switch (parts.length) {
      2 => ReviewKey(
        domainId: LearningDomainIds.multiplication,
        number: number,
      ),
      3 when _namesAnotherDomain(parts[1]) => ReviewKey(
        domainId: parts[1],
        number: number,
      ),
      _ => null,
    };
  }

  /// Whether [domainId], read from a key of three parts, is a domain after
  /// the multiplication: `review:multiplication:2` is never written.
  static bool _namesAnotherDomain(String domainId) {
    return isValidDomainId(domainId) &&
        domainId != LearningDomainIds.multiplication;
  }

  /// The key, such as `review:2` or `review:numbers:2`.
  String toKey() {
    assert(isValidDomainId(domainId), 'domain id $domainId cannot be keyed');
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

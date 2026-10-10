import 'package:meta/meta.dart';

/// The streak of a player as shown today.
@immutable
final class StreakSummary {
  /// Creates the summary.
  const StreakSummary({
    required this.current,
    required this.best,
    required this.isJokerAvailable,
  });

  /// Days in a row, 0 once the streak is lost.
  final int current;

  /// Longest streak ever.
  final int best;

  /// Whether this week's joker can still save the streak.
  final bool isJokerAvailable;
}

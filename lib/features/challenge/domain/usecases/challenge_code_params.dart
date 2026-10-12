import 'package:meta/meta.dart';

/// A game to turn into a challenge code: what it was played for and its
/// score.
@immutable
final class ChallengeCodeParams {
  /// Creates the parameters.
  const ChallengeCodeParams({required this.sourceKey, required this.score});

  /// Source key of the game: a free training, a time attack or a game
  /// replayed from a code.
  final String sourceKey;

  /// Right answers of the game: the score to beat.
  final int score;
}

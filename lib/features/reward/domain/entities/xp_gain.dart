import 'package:meta/meta.dart';

/// XP earned by one quiz, part by part.
@immutable
final class XpGain {
  /// Creates the gain.
  const XpGain({
    required this.answers,
    required this.lightning,
    required this.completion,
    required this.perfect,
  });

  /// No XP: an abandoned quiz.
  const XpGain.none() : answers = 0, lightning = 0, completion = 0, perfect = 0;

  /// XP of the right answers.
  final int answers;

  /// Extra XP of the lightning answers.
  final int lightning;

  /// XP for completing the quiz.
  final int completion;

  /// Extra XP for a perfect score.
  final int perfect;

  /// Every part added up.
  int get total => answers + lightning + completion + perfect;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is XpGain &&
            other.answers == answers &&
            other.lightning == lightning &&
            other.completion == completion &&
            other.perfect == perfect;
  }

  @override
  int get hashCode => Object.hash(answers, lightning, completion, perfect);
}

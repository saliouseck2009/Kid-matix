import 'package:kid_matix/features/challenge/domain/entities/challenge_code_mode.dart';
import 'package:meta/meta.dart';

/// What a challenge code carries: the game to replay, the draw of its
/// questions and the score to beat.
@immutable
final class ChallengeCode {
  /// Creates the challenge; [tables] are sorted and kept once each.
  ChallengeCode({
    required Iterable<int> tables,
    required this.mode,
    required this.questionCount,
    required this.seed,
    required this.scoreToBeat,
    required this.generatorVersion,
  }) : tables = List<int>.unmodifiable(tables.toSet().toList()..sort());

  /// Numbers of the tables played, such as 2 and 5, in increasing order.
  final List<int> tables;

  /// The game replayed.
  final ChallengeCodeMode mode;

  /// Scored questions of a free training; questions prepared for a time
  /// attack.
  final int questionCount;

  /// Seed of the draw of the questions.
  final int seed;

  /// Right answers of the player who sent the code.
  final int scoreToBeat;

  /// Version of the frozen question generator that turns [seed] into the
  /// questions.
  final int generatorVersion;

  /// Returns a copy with the given fields replaced.
  ChallengeCode copyWith({int? scoreToBeat}) {
    return ChallengeCode(
      tables: tables,
      mode: mode,
      questionCount: questionCount,
      seed: seed,
      scoreToBeat: scoreToBeat ?? this.scoreToBeat,
      generatorVersion: generatorVersion,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ChallengeCode &&
            other.mode == mode &&
            other.questionCount == questionCount &&
            other.seed == seed &&
            other.scoreToBeat == scoreToBeat &&
            other.generatorVersion == generatorVersion &&
            other.tables.join(',') == tables.join(',');
  }

  @override
  int get hashCode => Object.hash(
    mode,
    questionCount,
    seed,
    scoreToBeat,
    generatorVersion,
    Object.hashAll(tables),
  );

  @override
  String toString() {
    return 'ChallengeCode(${mode.name}, $tables, $questionCount, '
        'seed $seed, score $scoreToBeat, v$generatorVersion)';
  }
}

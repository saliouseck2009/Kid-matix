import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_source.dart';
import 'package:kid_matix/features/challenge/domain/entities/record_entity.dart';
import 'package:meta/meta.dart';

/// What the challenges screen shows.
@immutable
sealed class ChallengesState {
  const ChallengesState();
}

/// The challenges are being read.
final class ChallengesLoading extends ChallengesState {
  /// Creates the state.
  const ChallengesLoading();
}

/// The challenges of the player and their records.
final class ChallengesLoaded extends ChallengesState {
  /// Creates the state.
  const ChallengesLoaded({required this.timeAttack, required this.records});

  /// The time attack to play.
  final TimeAttackSource timeAttack;

  /// Best score by mode; a mode never played has none.
  final Map<QuizMode, RecordEntity> records;
}

/// The challenges could not be read.
final class ChallengesFailure extends ChallengesState {
  /// Creates the state.
  const ChallengesFailure({required this.errorCode});

  /// Why it failed.
  final AppErrorCode errorCode;
}

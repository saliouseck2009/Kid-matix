import 'package:kid_matix/features/challenge/domain/usecases/get_records_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/get_session_record_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/get_time_attack_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/get_training_choice_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/save_training_choice_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/watch_record_changes_use_case.dart';

/// The use cases the Cubits of the challenges call.
final class ChallengeUseCases {
  /// Groups the use cases.
  const ChallengeUseCases({
    required this.getTrainingChoice,
    required this.saveTrainingChoice,
    required this.getTimeAttack,
    required this.getRecords,
    required this.getSessionRecord,
    required this.watchRecordChanges,
  });

  /// The free training to offer.
  final GetTrainingChoiceUseCase getTrainingChoice;

  /// Keeps the free training launched.
  final SaveTrainingChoiceUseCase saveTrainingChoice;

  /// The time attack of the player.
  final GetTimeAttackUseCase getTimeAttack;

  /// The records of the player.
  final GetRecordsUseCase getRecords;

  /// The record a session set.
  final GetSessionRecordUseCase getSessionRecord;

  /// Changes of the records.
  final WatchRecordChangesUseCase watchRecordChanges;
}

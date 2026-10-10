import 'package:kid_matix/core/entities/timer_mode.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/services/open_units_service.dart';
import 'package:kid_matix/features/challenge/data/datasources/training_choice_local_data_source_impl.dart';
import 'package:kid_matix/features/challenge/data/repositories/training_choice_repository_impl.dart';
import 'package:kid_matix/features/challenge/domain/repositories/record_repository.dart';
import 'package:kid_matix/features/challenge/domain/usecases/get_records_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/get_session_record_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/get_time_attack_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/get_training_choice_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/save_training_choice_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/watch_record_changes_use_case.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/challenge_use_cases.dart';
import 'package:kid_matix/features/challenge/presentation/challenge_pages.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';

import '../features/challenge/helpers/challenge_fakes.dart';
import 'in_memory_local_storage.dart';
import 'test_quiz_pages.dart';

/// Use cases of the challenges over in-memory doubles.
ChallengeUseCases buildTestChallengeUseCases({
  RecordRepository? records,
  OpenUnitsService openUnits = const FixedOpenUnits(),
  TimerMode timerMode = TimerMode.normal,
}) {
  final RecordRepository recordRepository =
      records ?? InMemoryRecordRepository();
  final TrainingChoiceRepositoryImpl choices = TrainingChoiceRepositoryImpl(
    choices: TrainingChoiceLocalDataSourceImpl(
      storage: InMemoryLocalStorage(),
    ),
  );
  return ChallengeUseCases(
    getTrainingChoice: GetTrainingChoiceUseCase(
      repository: choices,
      openUnits: openUnits,
      settings: FixedPlayerSettings(timerMode),
    ),
    saveTrainingChoice: SaveTrainingChoiceUseCase(repository: choices),
    getTimeAttack: GetTimeAttackUseCase(openUnits: openUnits),
    getRecords: GetRecordsUseCase(repository: recordRepository),
    getSessionRecord: GetSessionRecordUseCase(repository: recordRepository),
    watchRecordChanges: WatchRecordChangesUseCase(
      repository: recordRepository,
    ),
  );
}

/// Challenge pages over in-memory doubles and the multiplication domain.
ChallengePages buildTestChallengePages({ChallengeUseCases? useCases}) {
  return ChallengePages(
    useCases: useCases ?? buildTestChallengeUseCases(),
    domains: DomainRegistry()..register(MultiplicationDomain()),
  );
}

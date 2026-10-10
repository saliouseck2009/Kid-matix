import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/challenge/domain/entities/record_entity.dart';
import 'package:kid_matix/features/challenge/domain/repositories/record_repository.dart';

/// The records of a player, by mode; a mode never played has none.
class GetRecordsUseCase
    implements UseCase<DataState<Map<QuizMode, RecordEntity>>, String> {
  /// Creates the use case.
  const GetRecordsUseCase({required this._repository});

  final RecordRepository _repository;

  /// Returns the records of the player [params].
  @override
  Future<DataState<Map<QuizMode, RecordEntity>>> call({
    required String params,
  }) async {
    final DataState<List<RecordEntity>> records = await _repository.getRecords(
      profileId: params,
    );
    return switch (records) {
      DataSuccess<List<RecordEntity>>(:final data) =>
        DataSuccess<Map<QuizMode, RecordEntity>>(<QuizMode, RecordEntity>{
          for (final RecordEntity record in data) record.mode: record,
        }),
      DataFailed<List<RecordEntity>>(:final exception) =>
        DataFailed<Map<QuizMode, RecordEntity>>(exception),
    };
  }
}

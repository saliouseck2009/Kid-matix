import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/challenge/domain/entities/record_entity.dart';
import 'package:kid_matix/features/challenge/domain/repositories/record_repository.dart';

/// The record a session set, for "Nouveau record" on its results; `null`
/// when it set none.
class GetSessionRecordUseCase
    implements UseCase<DataState<RecordEntity?>, String> {
  /// Creates the use case.
  const GetSessionRecordUseCase({required this._repository});

  final RecordRepository _repository;

  /// Returns the record set by the session [params].
  @override
  Future<DataState<RecordEntity?>> call({required String params}) {
    return _repository.getRecordOfSession(sessionId: params);
  }
}

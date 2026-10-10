import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/challenge/domain/entities/record_entity.dart';
import 'package:kid_matix/features/challenge/domain/usecases/get_session_record_use_case.dart';

/// Reads the record a session set, for its results: `null` while reading
/// and when it set none.
final class SessionRecordCubit extends Cubit<RecordEntity?> {
  /// Creates the Cubit of the session [sessionId].
  SessionRecordCubit({
    required this._sessionId,
    required this._getSessionRecord,
  }) : super(null);

  final String _sessionId;
  final GetSessionRecordUseCase _getSessionRecord;

  /// Reads the record; a failure shows nothing.
  Future<void> load() async {
    final DataState<RecordEntity?> read = await _getSessionRecord(
      params: _sessionId,
    );
    if (isClosed) return;
    if (read case DataSuccess<RecordEntity?>(:final RecordEntity data)) {
      emit(data);
    }
  }
}

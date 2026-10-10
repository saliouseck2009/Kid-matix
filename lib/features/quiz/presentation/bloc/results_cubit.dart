import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_result_entity.dart';
import 'package:kid_matix/features/quiz/domain/usecases/get_quiz_result_use_case.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/results_state.dart';

/// Loads the results of one saved session from its identifier.
final class ResultsCubit extends Cubit<ResultsState> {
  /// Creates the Cubit of the session [sessionId].
  ResultsCubit({required this._sessionId, required this._getResult})
    : super(const ResultsLoading());

  final String _sessionId;
  final GetQuizResultUseCase _getResult;

  /// Reads the session.
  Future<void> load() async {
    if (state is! ResultsLoading) emit(const ResultsLoading());
    final DataState<QuizResultEntity> loaded = await _getResult(
      params: _sessionId,
    );
    emit(switch (loaded) {
      DataSuccess<QuizResultEntity>(:final data) => ResultsLoaded(
        result: data,
      ),
      DataFailed<QuizResultEntity>(:final exception) => ResultsFailure(
        errorCode: exception.code,
      ),
    });
  }
}

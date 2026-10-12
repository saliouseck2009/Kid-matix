import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_test_entity.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/learning_path_params.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/placement_answer_params.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_event.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_state.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_use_cases.dart';

/// Drives the placement test of a new player: the offer, one question per
/// table on the keypad, then the tables found.
///
/// Each answer is recorded as soon as it is given, so a test left midway
/// keeps the tables already found. No timer and no feedback per question:
/// the result screen tells what was found.
final class PlacementBloc extends Bloc<PlacementEvent, PlacementState> {
  /// Creates the Bloc for the player and domain of [params]; [clock]
  /// measures the time taken by each answer.
  PlacementBloc({
    required this._params,
    required this._useCases,
    required this._clock,
  }) : super(const PlacementOffered()) {
    on<PlacementStarted>(_onStarted);
    on<PlacementDigitTyped>(_onDigitTyped);
    on<PlacementDigitErased>(_onDigitErased);
    on<PlacementAnswerValidated>(_onAnswerValidated);
    on<PlacementAnswerUnknown>(_onAnswerUnknown);
  }

  final LearningPathParams _params;
  final PlacementUseCases _useCases;
  final Clock _clock;

  Future<void> _onStarted(
    PlacementStarted event,
    Emitter<PlacementState> emit,
  ) async {
    if (state is! PlacementOffered) return;
    emit(const PlacementLoading());
    final DataState<PlacementTestEntity> test = await _useCases.runTest(
      params: _params.domainId,
    );
    emit(switch (test) {
      DataSuccess<PlacementTestEntity>(:final data) => PlacementAsking(
        test: data,
        index: 0,
        askedAt: _clock.now(),
      ),
      DataFailed<PlacementTestEntity>(:final exception) => PlacementFailure(
        errorCode: exception.code,
      ),
    });
  }

  void _onDigitTyped(
    PlacementDigitTyped event,
    Emitter<PlacementState> emit,
  ) {
    final PlacementState current = state;
    if (current is! PlacementAsking || current.isSubmitting) return;
    emit(current.withDigit(event.digit));
  }

  void _onDigitErased(
    PlacementDigitErased event,
    Emitter<PlacementState> emit,
  ) {
    final PlacementState current = state;
    if (current is! PlacementAsking || current.isSubmitting) return;
    emit(current.withoutLastDigit());
  }

  Future<void> _onAnswerValidated(
    PlacementAnswerValidated event,
    Emitter<PlacementState> emit,
  ) async {
    final PlacementState current = state;
    if (current is! PlacementAsking || current.typedDigits.isEmpty) return;
    await _submit(current, NumberAnswer(int.parse(current.typedDigits)), emit);
  }

  Future<void> _onAnswerUnknown(
    PlacementAnswerUnknown event,
    Emitter<PlacementState> emit,
  ) async {
    final PlacementState current = state;
    if (current is! PlacementAsking) return;
    await _submit(current, null, emit);
  }

  Future<void> _submit(
    PlacementAsking current,
    Answer? answer,
    Emitter<PlacementState> emit,
  ) async {
    if (current.isSubmitting) return;
    emit(current.copyWith(isSubmitting: true));
    final DataState<bool> recorded = await _useCases.answerQuestion(
      params: PlacementAnswerParams(
        profileId: _params.profileId,
        domainId: _params.domainId,
        question: current.question.question,
        answer: answer,
        answerTime: _clock.now().difference(current.askedAt),
      ),
    );
    switch (recorded) {
      case DataSuccess<bool>(:final data):
        emit(_next(current, isCorrect: data));
      case DataFailed<bool>(:final exception):
        emit(PlacementFailure(errorCode: exception.code));
    }
  }

  PlacementState _next(PlacementAsking current, {required bool isCorrect}) {
    final Set<String> known = <String>{
      ...current.knownUnitKeys,
      if (isCorrect) current.question.unitKey,
    };
    if (current.isLast) {
      return PlacementFinished(test: current.test, knownUnitKeys: known);
    }
    return PlacementAsking(
      test: current.test,
      index: current.index + 1,
      askedAt: _clock.now(),
      knownUnitKeys: known,
    );
  }
}

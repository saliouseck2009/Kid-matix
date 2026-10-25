import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/entities/shared_file.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_exercise_sheet_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_word_cards_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/share_files_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/printables_state.dart';

/// The use cases of the printable sheets.
typedef PrintableUseCases = ({
  GetExerciseSheetUseCase exercises,
  GetWordCardsUseCase words,
  ShareFilesUseCase share,
});

/// Makes the PDF of [sheet] made on [day].
typedef ExerciseRenderer = Future<SharedFile> Function(
  ExerciseSheet sheet,
  DateTime day,
);

/// Makes the PDF of the word cards [sheet] made on [day].
typedef WordCardsRenderer = Future<SharedFile> Function(
  WordCardSheet sheet,
  DateTime day,
);

/// Prints exercises of a unit and the word cards (F31-07).
final class PrintablesCubit extends Cubit<PrintablesState> {
  /// Creates the Cubit on the unit [unitKey] of [domainId].
  PrintablesCubit({
    required String domainId,
    required String unitKey,
    required this._useCases,
    required this._clock,
  }) : super(PrintablesState(domainId: domainId, unitKey: unitKey));

  final PrintableUseCases _useCases;
  final Clock _clock;

  /// Chooses the unit [unitKey] of [domainId].
  void choose({required String domainId, required String unitKey}) {
    emit(PrintablesState(domainId: domainId, unitKey: unitKey));
  }

  /// Prints the exercises of the unit chosen with [render].
  Future<void> printExercises(ExerciseRenderer render) async {
    if (state.isBusy) return;
    _start();
    final DataState<ExerciseSheet> sheet = await _useCases.exercises(
      params: (domainId: state.domainId, unitKey: state.unitKey),
    );
    if (sheet case DataFailed<ExerciseSheet>(:final exception)) {
      _finish(null, exception.code);
      return;
    }
    await _share(
      () => render((sheet as DataSuccess<ExerciseSheet>).data, _clock.now()),
    );
  }

  /// Prints the word cards with [render].
  Future<void> printWords(WordCardsRenderer render) async {
    if (state.isBusy) return;
    _start();
    await _share(() => render(_useCases.words(), _clock.now()));
  }

  Future<void> _share(Future<SharedFile> Function() make) async {
    final SharedFile file;
    try {
      file = await make();
    } on Exception catch (error, stackTrace) {
      log(
        'Sheet not made',
        name: 'classroom',
        error: error,
        stackTrace: stackTrace,
      );
      _finish(null, AppErrorCode.unknown);
      return;
    }
    final DataState<bool> shared = await _useCases.share(
      params: <SharedFile>[file],
    );
    switch (shared) {
      case DataSuccess<bool>(:final data):
        _finish(data, null);
      case DataFailed<bool>(:final exception):
        _finish(null, exception.code);
    }
  }

  void _start() {
    emit(
      PrintablesState(
        domainId: state.domainId,
        unitKey: state.unitKey,
        isBusy: true,
      ),
    );
  }

  void _finish(bool? isShared, AppErrorCode? errorCode) {
    if (isClosed) return;
    emit(
      PrintablesState(
        domainId: state.domainId,
        unitKey: state.unitKey,
        isShared: isShared ?? false,
        errorCode: errorCode,
      ),
    );
  }
}

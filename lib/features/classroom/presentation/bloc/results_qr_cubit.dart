import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_merge_report.dart';
import 'package:kid_matix/features/classroom/domain/usecases/confirm_results_qr_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/make_results_qr_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/receive_results_qr_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/results_qr_state.dart';

/// The use cases of the QR codes of results.
typedef ResultsQrUseCases = ({
  MakeResultsQrUseCase make,
  ConfirmResultsQrUseCase confirm,
  ReceiveResultsQrUseCase receive,
});

/// Shows the QR code of the new results of a class, or reads one with the
/// camera and merges it (F31-05).
final class ResultsQrCubit extends Cubit<ResultsQrState> {
  /// Creates the Cubit, scanning until [show] is called.
  ResultsQrCubit({required this._useCases}) : super(const ResultsQrScanning());

  final ResultsQrUseCases _useCases;

  /// Makes and shows the code of the class [classroomId].
  Future<void> show(String classroomId) async {
    emit(const ResultsQrBusy());
    final DataState<ResultsQr> made = await _useCases.make(
      params: classroomId,
    );
    if (isClosed) return;
    emit(switch (made) {
      DataSuccess<ResultsQr>(:final data) => ResultsQrShown(
        text: data.text,
        sequence: data.sequence,
        sessionCount: data.sessionCount,
      ),
      DataFailed<ResultsQr>(:final exception) => ResultsQrFailed(
        errorCode: exception.code,
      ),
    });
  }

  /// Remembers that the code of [classroomId] shown was read.
  Future<void> confirm(String classroomId) async {
    final ResultsQrState current = state;
    if (current is! ResultsQrShown) return;
    final DataState<void> saved = await _useCases.confirm(
      params: (classroomId: classroomId, sequence: current.sequence),
    );
    if (isClosed) return;
    emit(switch (saved) {
      DataSuccess<void>() => const ResultsQrSent(),
      DataFailed<void>(:final exception) => ResultsQrFailed(
        errorCode: exception.code,
      ),
    });
  }

  /// Merges the code [text] the camera read; codes read while one is
  /// being merged are ignored.
  Future<void> receive(String text) async {
    if (state is! ResultsQrScanning) return;
    emit(const ResultsQrBusy());
    final DataState<ClassroomMergeReport> merged = await _useCases.receive(
      params: text,
    );
    if (isClosed) return;
    emit(switch (merged) {
      DataSuccess<ClassroomMergeReport>(:final data) => ResultsQrMerged(
        report: data,
      ),
      DataFailed<ClassroomMergeReport>(:final exception) => ResultsQrFailed(
        errorCode: exception.code,
      ),
    });
  }

  /// Scans again after a failure.
  void scanAgain() => emit(const ResultsQrScanning());
}

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_result.dart';
import 'package:kid_matix/features/classroom/domain/entities/export_mark.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';
import 'package:kid_matix/features/classroom/domain/entities/qr_results.dart';
import 'package:kid_matix/features/classroom/domain/repositories/assessment_repository.dart';
import 'package:kid_matix/features/classroom/domain/repositories/class_journal_repository.dart';
import 'package:kid_matix/features/classroom/domain/repositories/classroom_transfer_repository.dart';
import 'package:kid_matix/features/classroom/domain/repositories/qr_results_codec.dart';

/// The QR code of the new results of a class, and the local sequence it
/// reaches, to remember once the teacher's tablet has read it.
typedef ResultsQr = ({String text, int sequence, int sessionCount});

/// Makes the QR code of the results of a class played on this tablet
/// since its last file or QR code: the new sessions (no overlap, unlike
/// the files) and the assessment results taken since.
///
/// Fails with a `LimitReachedException` when the code would be too long
/// for a camera ([QrResults.maxTextLength]): the class file is then used;
/// with a `ValidationException` when there is nothing new.
class MakeResultsQrUseCase implements UseCase<DataState<ResultsQr>, String> {
  /// Creates the use case.
  const MakeResultsQrUseCase({
    required this._journal,
    required this._assessments,
    required this._transfers,
    required this._codec,
  });

  // A date no session starts after: only the local sequence selects.
  static final DateTime _never = DateTime.utc(9999);

  final ClassJournalRepository _journal;
  final AssessmentRepository _assessments;
  final ClassroomTransferRepository _transfers;
  final QrResultsCodec _codec;

  @override
  Future<DataState<ResultsQr>> call({required String params}) async {
    final DataState<ExportMark?> mark = await _transfers.readExportMark(
      classroomId: params,
    );
    final DataState<int> latest = await _journal.getLatestSequence(
      classroomId: params,
    );
    final ExportMark? since = mark is DataSuccess<ExportMark?>
        ? mark.data
        : null;
    final DataState<List<PracticeSession>> sessions = await _journal
        .getSessions(
          classroomId: params,
          afterSequence: since?.sequence ?? -1,
          startedFrom: _never,
        );
    final DataState<List<AssessmentResult>> results = await _assessments
        .getResults(classroomId: params);
    return switch ((latest, sessions, results)) {
      (
        DataSuccess<int>(data: final int l),
        DataSuccess<List<PracticeSession>>(data: final List<PracticeSession> s),
        DataSuccess<List<AssessmentResult>>(
          data: final List<AssessmentResult> r,
        ),
      ) =>
        _qrOf(
          QrResults(
            classroomId: params,
            sessions: s,
            results: r
                .where(
                  (AssessmentResult x) =>
                      since == null || x.takenAt.isAfter(since.exportedAt),
                )
                .toList(),
          ),
          l,
        ),
      (DataFailed<int>(:final exception), _, _) ||
      (_, DataFailed<List<PracticeSession>>(:final exception), _) ||
      (
        _,
        _,
        DataFailed<List<AssessmentResult>>(:final exception),
      ) => DataFailed<ResultsQr>(exception),
    };
  }

  DataState<ResultsQr> _qrOf(QrResults results, int sequence) {
    if (results.isEmpty) {
      return const DataFailed<ResultsQr>(
        ValidationException(message: 'No new results.'),
      );
    }
    final String text = _codec.encode(results);
    if (text.length > QrResults.maxTextLength) {
      return const DataFailed<ResultsQr>(
        LimitReachedException(message: 'Too many results for a QR code.'),
      );
    }
    return DataSuccess<ResultsQr>((
      text: text,
      sequence: sequence,
      sessionCount: results.sessions.length,
    ));
  }
}

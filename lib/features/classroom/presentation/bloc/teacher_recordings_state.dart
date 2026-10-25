import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/classroom/domain/entities/teacher_recordings.dart';
import 'package:meta/meta.dart';

/// What the last action on the recordings gave, for a snack bar.
enum RecordingNotice {
  /// A recording was kept.
  saved,

  /// The pack file went to the share sheet.
  exported,

  /// A pack file was imported.
  imported,
}

/// The page of the teacher's recordings.
@immutable
final class TeacherRecordingsState {
  /// Creates the state.
  const TeacherRecordingsState({
    this.page,
    this.recordingWordKey,
    this.isBusy = false,
    this.notice,
    this.importedCount = 0,
    this.errorCode,
  });

  /// What the page shows, or `null` while reading.
  final TeacherRecordings? page;

  /// The word being recorded, or `null`.
  final String? recordingWordKey;

  /// Whether an action is going on.
  final bool isBusy;

  /// What the last action gave, or `null`.
  final RecordingNotice? notice;

  /// Recordings the last imported pack held.
  final int importedCount;

  /// Why the last action failed, or `null`.
  final AppErrorCode? errorCode;

  /// Returns a copy with [page] and no notice.
  TeacherRecordingsState showing(TeacherRecordings page) {
    return TeacherRecordingsState(page: page);
  }

  /// Returns a copy recording [wordKey], or none.
  TeacherRecordingsState recording(String? wordKey) {
    return TeacherRecordingsState(page: page, recordingWordKey: wordKey);
  }

  /// Returns a copy while an action goes on.
  TeacherRecordingsState get busy => TeacherRecordingsState(
    page: page,
    recordingWordKey: recordingWordKey,
    isBusy: true,
  );

  /// Returns a copy after an action: [notice] or [errorCode].
  TeacherRecordingsState after({
    RecordingNotice? notice,
    AppErrorCode? errorCode,
    int importedCount = 0,
  }) {
    return TeacherRecordingsState(
      page: page,
      notice: notice,
      errorCode: errorCode,
      importedCount: importedCount,
    );
  }
}

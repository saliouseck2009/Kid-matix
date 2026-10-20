import 'package:kid_matix/core/error/data_state.dart';

/// The code of the teacher area of the device: 4 digits chosen by the
/// teacher, no account.
abstract interface class TeacherCodeRepository {
  /// Returns the code, or `null` when none was chosen yet.
  Future<DataState<String?>> readCode();

  /// Stores [code] chosen at [savedAt]; when it replaces a forgotten
  /// code, [savedAt] becomes the date the code changed.
  Future<DataState<void>> saveCode({
    required String code,
    required DateTime savedAt,
  });

  /// Forgets the code: the next visit chooses a new one.
  Future<DataState<void>> clearCode();

  /// Returns when the code was last replaced after « Code oublié ? », or
  /// `null` when it never was.
  Future<DataState<DateTime?>> readCodeChangedAt();

  /// Returns until when the door refuses every code, or `null`.
  Future<DataState<DateTime?>> readLockedUntil();

  /// Closes the door until [until]; `null` opens it again.
  Future<DataState<void>> saveLockedUntil({required DateTime? until});
}

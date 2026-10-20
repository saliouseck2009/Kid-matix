import 'package:kid_matix/core/error/data_state.dart';

/// The code of the teacher area of the device: 4 digits chosen by the
/// teacher, no account.
abstract interface class TeacherCodeRepository {
  /// Returns the code, or `null` when none was chosen yet.
  Future<DataState<String?>> readCode();

  /// Stores [code], replacing any previous one.
  Future<DataState<void>> saveCode({required String code});

  /// Forgets the code: the next visit chooses a new one.
  Future<DataState<void>> clearCode();
}

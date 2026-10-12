import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code_error.dart';
import 'package:kid_matix/features/challenge/domain/entities/code_quiz_result.dart';
import 'package:kid_matix/features/challenge/domain/usecases/build_quiz_from_code_use_case.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/code_entry_state.dart';

/// Reads the challenge code typed by the child, and says why it is
/// refused.
final class CodeEntryCubit extends Cubit<CodeEntryState> {
  /// Creates the Cubit.
  CodeEntryCubit({required this._buildQuizFromCode})
    : super(const CodeEntryIdle());

  final BuildQuizFromCodeUseCase _buildQuizFromCode;

  /// Reads [input]; a valid code ends in [CodeEntryAccepted].
  Future<void> submit(String input) async {
    if (state is CodeEntryChecking) return;
    emit(const CodeEntryChecking());
    final CodeQuizResult result = await _buildQuizFromCode(params: input);
    if (isClosed) return;
    emit(switch (result) {
      CodeQuizReady(:final spec) when spec.sourceKey != null =>
        CodeEntryAccepted(sourceKey: spec.sourceKey!),
      CodeQuizReady() => const CodeEntryRejected(
        error: ChallengeCodeError.malformed,
      ),
      CodeQuizRejected(:final ChallengeCodeError error) => CodeEntryRejected(
        error: error,
      ),
    });
  }

  /// The child changed the code: the message of a refused one goes away.
  void edit() {
    if (state is! CodeEntryIdle) emit(const CodeEntryIdle());
  }
}

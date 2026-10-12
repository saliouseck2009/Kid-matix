import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/challenge/domain/usecases/challenge_code_params.dart';
import 'package:kid_matix/features/challenge/domain/usecases/encode_challenge_code_use_case.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/challenge_share_state.dart';

/// Makes the code of a game for « Défier un ami » and « Renvoyer un
/// défi ».
final class ChallengeShareCubit extends Cubit<ChallengeShareState> {
  /// Creates the Cubit.
  ChallengeShareCubit({required this._encode})
    : super(const ChallengeShareIdle());

  final EncodeChallengeCodeUseCase _encode;

  /// Makes the code of the game played for [sourceKey] with [score] right
  /// answers; a second tap while it is made does nothing.
  Future<void> share({required String sourceKey, required int score}) async {
    if (state is ChallengeSharing) return;
    emit(const ChallengeSharing());
    final DataState<String> code = await _encode(
      params: ChallengeCodeParams(sourceKey: sourceKey, score: score),
    );
    if (isClosed) return;
    emit(switch (code) {
      DataSuccess<String>(:final String data) => ChallengeShareReady(
        code: data,
      ),
      DataFailed<String>(:final exception) => ChallengeShareFailed(
        errorCode: exception.code,
      ),
    });
  }
}

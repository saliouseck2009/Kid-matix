import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/nickname_rules.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_repository.dart';

/// Checks that a nickname follows the rules and is free on the device.
///
/// Shared by the use cases that create and rename a profile.
final class NicknameChecker {
  /// Creates a checker that looks nicknames up in [repository].
  const NicknameChecker({required this._repository});

  final ProfileRepository _repository;

  /// Returns why [nickname] cannot be used, or `null` when it can.
  ///
  /// Fails with a `ValidationException` when the nickname breaks
  /// [NicknameRules], and with a `ConflictException` when another profile
  /// than [excludedProfileId] already uses it.
  Future<AppException?> findProblem({
    required String nickname,
    String? excludedProfileId,
  }) async {
    if (NicknameRules.validate(nickname) != null) {
      return const ValidationException(message: 'Invalid nickname.');
    }
    final DataState<bool> takenState = await _repository.isNicknameTaken(
      nickname: nickname,
      excludedProfileId: excludedProfileId,
    );
    return switch (takenState) {
      DataFailed<bool>(:final exception) => exception,
      DataSuccess<bool>(data: true) => const ConflictException(
        message: 'Nickname already taken.',
      ),
      DataSuccess<bool>(data: false) => null,
    };
  }
}

import 'dart:developer';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/challenge/data/datasources/training_choice_local_data_source.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_source.dart';
import 'package:kid_matix/features/challenge/domain/repositories/training_choice_repository.dart';

/// [TrainingChoiceRepository] over the device preferences; a choice that
/// no longer reads is ignored.
final class TrainingChoiceRepositoryImpl implements TrainingChoiceRepository {
  /// Creates the repository.
  const TrainingChoiceRepositoryImpl({required this._choices});

  static const String _logName = 'challenge';

  final TrainingChoiceLocalDataSource _choices;

  @override
  Future<DataState<TrainingSource?>> getChoice({
    required String profileId,
  }) async {
    try {
      final ChallengeSource? source = ChallengeSource.tryParse(
        await _choices.readChoice(profileId: profileId),
      );
      return DataSuccess<TrainingSource?>(
        source is TrainingSource ? source : null,
      );
    } on Exception catch (error, stackTrace) {
      return _fail('Training choice not read', error, stackTrace);
    }
  }

  @override
  Future<DataState<void>> saveChoice({
    required String profileId,
    required TrainingSource choice,
  }) async {
    try {
      await _choices.writeChoice(
        profileId: profileId,
        sourceKey: choice.toKey(),
      );
      return const DataSuccess<void>(null);
    } on Exception catch (error, stackTrace) {
      return _fail('Training choice not saved', error, stackTrace);
    }
  }

  DataFailed<T> _fail<T>(
    String message,
    Exception error,
    StackTrace stackTrace,
  ) {
    log(message, name: _logName, error: error, stackTrace: stackTrace);
    return DataFailed<T>(CacheException(message: error.toString()));
  }
}

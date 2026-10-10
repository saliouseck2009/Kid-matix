import 'dart:async';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/crown_service.dart';
import 'package:kid_matix/core/services/reward_service.dart';

/// [RewardService] answering the [level] and [badges] the test sets.
final class FixedRewardService implements RewardService {
  /// Creates the service.
  FixedRewardService({
    this.level = 1,
    this.badges = const <String>{},
    this.streak = 0,
  });

  /// Level returned.
  int level;

  /// Badges returned.
  Set<String> badges;

  /// Streak returned.
  int streak;

  /// Failure of every call, or `null`.
  AppException? failure;

  @override
  Future<DataState<int>> readLevel({required String profileId}) async {
    final AppException? error = failure;
    return error == null ? DataSuccess<int>(level) : DataFailed<int>(error);
  }

  @override
  Future<DataState<int>> readStreak({required String profileId}) async {
    final AppException? error = failure;
    return error == null ? DataSuccess<int>(streak) : DataFailed<int>(error);
  }

  @override
  Future<DataState<Set<String>>> readBadgeKeys({
    required String profileId,
  }) async => DataSuccess<Set<String>>(badges);

  /// Changes the test sends to the watchers.
  final StreamController<void> changes = StreamController<void>.broadcast();

  @override
  Stream<void> watchChanges() => changes.stream;
}

/// [CrownService] answering the [crowns] the test sets.
final class FixedCrownService implements CrownService {
  /// Creates the service.
  FixedCrownService({this.crowns = 0});

  /// Crowns returned.
  int crowns;

  @override
  Future<DataState<int>> readCrownCount({required String profileId}) async =>
      DataSuccess<int>(crowns);

  @override
  Stream<void> watchChanges() => const Stream<void>.empty();
}

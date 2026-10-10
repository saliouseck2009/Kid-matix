import 'package:flutter/widgets.dart';
import 'package:kid_matix/features/mascot/domain/usecases/get_mascot_use_case.dart';
import 'package:kid_matix/features/mascot/domain/usecases/update_mascot_use_cases.dart';
import 'package:kid_matix/features/mascot/domain/usecases/watch_mascot_changes_use_case.dart';
import 'package:kid_matix/features/mascot/presentation/bloc/mascot_use_cases.dart';
import 'package:kid_matix/features/mascot/presentation/mascot_pages.dart';

import '../features/mascot/helpers/mascot_fakes.dart';

/// Mascot pages over in-memory doubles.
MascotPages buildTestMascotPages({
  InMemoryMascotRepository? repository,
  FixedRewardService? rewards,
  FixedCrownService? crowns,
}) {
  final InMemoryMascotRepository mascots =
      repository ?? InMemoryMascotRepository();
  final FixedRewardService levels = rewards ?? FixedRewardService();
  final FixedCrownService crowned = crowns ?? FixedCrownService();
  return MascotPages(
    useCases: MascotUseCases(
      getMascot: GetMascotUseCase(
        repository: mascots,
        rewards: levels,
        crowns: crowned,
      ),
      update: UpdateMascotUseCases(repository: mascots),
      watchChanges: WatchMascotChangesUseCase(
        repository: mascots,
        rewards: levels,
        crowns: crowned,
      ),
    ),
  );
}

/// Gives every screen of a test app the mascot of a test player.
Widget Function(Widget child) testMascotScope(MascotPages pages) {
  return (Widget child) => pages.buildScope(profileId: 'p-1', child: child);
}

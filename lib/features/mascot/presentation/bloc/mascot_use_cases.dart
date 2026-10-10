import 'package:kid_matix/features/mascot/domain/usecases/get_mascot_use_case.dart';
import 'package:kid_matix/features/mascot/domain/usecases/update_mascot_use_cases.dart';
import 'package:kid_matix/features/mascot/domain/usecases/watch_mascot_changes_use_case.dart';

/// Use cases of the mascot widgets.
final class MascotUseCases {
  /// Groups the use cases.
  const MascotUseCases({
    required this.getMascot,
    required this.update,
    required this.watchChanges,
  });

  /// Reads the mascot of a player.
  final GetMascotUseCase getMascot;

  /// Changes the choices of the child.
  final UpdateMascotUseCases update;

  /// Tells when the mascot may have changed.
  final WatchMascotChangesUseCase watchChanges;
}

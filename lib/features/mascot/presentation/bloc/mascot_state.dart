import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/mascot/domain/entities/mascot_entity.dart';
import 'package:meta/meta.dart';

/// What the mascot widgets show.
@immutable
sealed class MascotState {
  const MascotState();
}

/// The mascot is being read.
final class MascotLoading extends MascotState {
  /// Creates the state.
  const MascotLoading();
}

/// The mascot of the player.
final class MascotLoaded extends MascotState {
  /// Creates the state.
  const MascotLoaded({required this.mascot});

  /// Name, stage and accessories.
  final MascotEntity mascot;
}

/// The mascot could not be read.
final class MascotFailure extends MascotState {
  /// Creates the state.
  const MascotFailure({required this.errorCode});

  /// Why it failed.
  final AppErrorCode errorCode;
}

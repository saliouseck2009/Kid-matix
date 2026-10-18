import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/learning_path/domain/entities/domain_choice_entity.dart';
import 'package:meta/meta.dart';

/// What the switch of the domains shows.
@immutable
sealed class DomainChoiceState {
  const DomainChoiceState();
}

/// The domains and the player's choice are being read.
final class DomainChoiceLoading extends DomainChoiceState {
  /// Creates the state.
  const DomainChoiceLoading();
}

/// The domains of the app and the one the player sees.
final class DomainChoiceLoaded extends DomainChoiceState {
  /// Creates the state of [choice].
  const DomainChoiceLoaded({required this.choice});

  /// Domains and the one chosen.
  final DomainChoiceEntity choice;
}

/// The domains could not be read.
final class DomainChoiceFailure extends DomainChoiceState {
  /// Creates the state for [errorCode].
  const DomainChoiceFailure({required this.errorCode});

  /// Why it failed.
  final AppErrorCode errorCode;
}

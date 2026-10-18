import 'package:kid_matix/features/learning_path/domain/usecases/get_domain_choice_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/select_domain_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/watch_domain_choice_use_case.dart';

/// Use cases of the domain switch, grouped so the Cubit takes one
/// argument.
final class DomainChoiceUseCases {
  /// Groups the use cases.
  const DomainChoiceUseCases({
    required this.getChoice,
    required this.selectDomain,
    required this.watchChoice,
  });

  /// Reads the domains and the one chosen.
  final GetDomainChoiceUseCase getChoice;

  /// Keeps the domain chosen.
  final SelectDomainUseCase selectDomain;

  /// Tells when the player chose another domain elsewhere.
  final WatchDomainChoiceUseCase watchChoice;
}

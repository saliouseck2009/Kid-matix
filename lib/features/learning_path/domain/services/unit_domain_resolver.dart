import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/features/learning_path/domain/entities/review_key.dart';

/// Finds the learning domain of a unit or review key of the path, so a
/// table detail, a Discovery page or a stage quiz follows its own domain.
final class UnitDomainResolver {
  /// Creates the resolver.
  const UnitDomainResolver();

  /// The domain of [unitKey] among [domains]: the one a review key names,
  /// or the first that has the unit; `null` when none has it.
  LearningDomain? domainOf({
    required DomainRegistry domains,
    required String unitKey,
  }) {
    final ReviewKey? review = ReviewKey.tryParse(unitKey);
    if (review != null) return domains.find(review.domainId);
    for (final LearningDomain domain in domains.domains) {
      if (domain.findUnit(unitKey) != null) return domain;
    }
    return null;
  }
}

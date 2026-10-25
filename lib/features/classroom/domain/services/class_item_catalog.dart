import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_answer.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';

/// What the class mode needs to know of the learning domains: the items
/// of a unit, the domain of an item, the domain a class practised most.
class ClassItemCatalog {
  /// Creates the catalog over the [domains] of the app.
  const ClassItemCatalog({required this._domains});

  final DomainRegistry _domains;

  /// The keys of the items of [unitKey], empty when no domain has it.
  Set<String> unitItemKeys(String unitKey) {
    for (final LearningDomain domain in _domains.domains) {
      final LearningUnit? unit = domain.findUnit(unitKey);
      if (unit == null) continue;
      return unit.items.map((LearningItem item) => item.key).toSet();
    }
    return const <String>{};
  }

  /// The keys of the items of [sessions] that belong to [domainId].
  Set<String> itemKeysOf(Iterable<PracticeSession> sessions, String domainId) {
    final LearningDomain? domain = _domains.find(domainId);
    if (domain == null) return const <String>{};
    return <String>{
      for (final PracticeSession session in sessions)
        for (final PracticeAnswer answer in session.answers)
          if (domain.findItem(answer.itemKey) != null) answer.itemKey,
    };
  }

  /// The domain whose items [sessions] asked most, or `null` when they
  /// asked none; ties go to the first registered domain.
  String? mostPractisedDomain(Iterable<PracticeSession> sessions) {
    final Map<String, int> counts = <String, int>{};
    for (final PracticeSession session in sessions) {
      for (final PracticeAnswer answer in session.answers) {
        final String? domainId = _domains.findByItemKey(answer.itemKey)?.id;
        if (domainId != null) counts[domainId] = (counts[domainId] ?? 0) + 1;
      }
    }
    String? best;
    for (final LearningDomain domain in _domains.domains) {
      final int count = counts[domain.id] ?? 0;
      if (count > 0 && (best == null || count > counts[best]!)) {
        best = domain.id;
      }
    }
    return best;
  }
}

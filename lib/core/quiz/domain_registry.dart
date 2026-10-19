import 'package:kid_matix/core/quiz/learning_domain.dart';

/// The learning domains of the app, declared once at startup.
final class DomainRegistry {
  final Map<String, LearningDomain> _domains = <String, LearningDomain>{};

  /// Every registered domain, in registration order.
  List<LearningDomain> get domains => List<LearningDomain>.unmodifiable(
    _domains.values,
  );

  /// Declares [domain]; registering the same identifier twice is a
  /// programming error.
  void register(LearningDomain domain) {
    if (_domains.containsKey(domain.id)) {
      throw StateError('Domain ${domain.id} is already registered.');
    }
    _domains[domain.id] = domain;
  }

  /// Returns the domain [id], or `null` when it is not registered.
  LearningDomain? find(String id) => _domains[id];

  /// Returns the domain that teaches the item [itemKey], or `null` when no
  /// domain does. Item keys never repeat across domains (`mul:`, `num:`,
  /// `add:`...), which is what lets a quiz mix the items of several
  /// domains (`LearningDomainIds.mixed`).
  LearningDomain? findByItemKey(String itemKey) {
    for (final LearningDomain domain in _domains.values) {
      if (domain.findItem(itemKey) != null) return domain;
    }
    return null;
  }
}

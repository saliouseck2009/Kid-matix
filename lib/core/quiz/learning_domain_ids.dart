/// Identifiers of the learning domains, shared by the modules that build
/// them and the screens that name them.
abstract final class LearningDomainIds {
  /// The multiplication tables.
  static const String multiplication = 'multiplication';

  /// The numbers up to 100: counting, tens and ones, comparing and
  /// ordering (version 2.0).
  static const String numbers = 'numbers';

  /// Additions and subtractions, from the facts up to 10 to the numbers up
  /// to 100 with carrying (version 2.0).
  static const String addition = 'addition';

  /// Not a domain to learn: the id of a quiz that mixes the items of every
  /// domain, such as the daily review. It names no unit and no item
  /// progress; each item belongs to its own domain.
  static const String mixed = 'mixed';

  /// The divisions of the multiplication tables (version 2.0).
  static const String division = 'division';

  /// The words of mathematics: add, take away, compare, group, share
  /// (version 2.0).
  static const String mathWords = 'math_words';
}

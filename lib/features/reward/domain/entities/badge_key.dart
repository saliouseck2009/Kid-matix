/// Keys of the badges, stored with each unlock; they never change once
/// released.
abstract final class BadgeKey {
  /// Premier pas: a first stage of the learning path completed.
  static const String firstStep = 'firstStep';

  /// Sans-faute: a stage completed at 100 %.
  static const String perfect = 'perfect';

  /// Éclair: 20 lightning answers in all.
  static const String lightning = 'lightning';

  /// Sprinter: 20 right answers in one time attack.
  static const String sprinter = 'sprinter';

  /// Régulier: a 7-day streak.
  static const String regular = 'regular';

  /// Les 120: every fact of the domain mastered.
  static const String allFacts = 'allFacts';

  /// Prefix of the tamer badges, one per crowned table.
  static const String tamerPrefix = 'tamer:';

  /// Dompteur of the unit [unitKey], such as `tamer:mul:7`.
  static String tamerOf(String unitKey) => '$tamerPrefix$unitKey';

  /// Unit of a tamer badge, or `null` for another badge.
  static String? unitOfTamer(String badgeKey) {
    return badgeKey.startsWith(tamerPrefix)
        ? badgeKey.substring(tamerPrefix.length)
        : null;
  }
}

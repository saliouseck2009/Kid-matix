/// A family of monsters: the multiplication draws its bosses with horns,
/// every other domain with antennae, so they never look like the 12
/// tables. Two domains after the multiplication share the antennae: one
/// family per domain is a choice left to the owner.
enum MonsterFamily {
  /// Horns: the 12 table monsters of the multiplication.
  horned,

  /// Antennae and spots: the monsters of every other domain, such as
  /// the numbers.
  antennae,
}

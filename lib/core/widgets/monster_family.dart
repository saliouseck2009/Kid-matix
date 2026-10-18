import 'package:kid_matix/core/quiz/learning_domain_ids.dart';

/// A family of monsters, one per learning domain (owner's decision): the
/// bosses of a domain share its look, and never look like those of
/// another domain.
///
/// A new domain adds a value naming its domain here and draws it in
/// `MonsterPainter`, a provisional drawing like the others; the switch of
/// the painter does not compile until it does.
enum MonsterFamily {
  /// Horns: the 12 table monsters of the multiplication.
  horned(LearningDomainIds.multiplication),

  /// Antennae and spots: the monsters of the numbers.
  antennae(LearningDomainIds.numbers),

  /// Round ears and a belly split in two: the monsters of the division.
  eared(LearningDomainIds.division);

  const MonsterFamily(this.domainId);

  /// Learning domain whose bosses belong to the family.
  final String domainId;

  /// The family of [domainId], or `null` when the domain has none yet.
  static MonsterFamily? of(String domainId) {
    for (final MonsterFamily family in values) {
      if (family.domainId == domainId) return family;
    }
    return null;
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/widgets/monster_family.dart';
import 'package:kid_matix/core/widgets/monster_painter.dart';

import '../../features/quiz/helpers/quiz_fixtures.dart';

/// Guard of the monsters: one family per domain (owner's decision). A new
/// domain without its family, or two domains sharing one, fails here.
void main() {
  final List<LearningDomain> domains = buildDomainRegistry().domains;

  test('gives every domain of the app its own family', () {
    // Act
    final List<MonsterFamily?> actualFamilies = <MonsterFamily?>[
      for (final LearningDomain domain in domains) MonsterFamily.of(domain.id),
    ];
    // Assert
    expect(actualFamilies, isNot(contains(null)));
    expect(actualFamilies.toSet(), hasLength(domains.length));
  });
  test('names one domain per family', () {
    // Assert
    expect(
      MonsterFamily.values
          .map((MonsterFamily family) => family.domainId)
          .toSet(),
      hasLength(MonsterFamily.values.length),
    );
  });
  test('keeps the horns of the multiplication and the antennae', () {
    // Assert
    expect(
      MonsterIllustration.familyOf('multiplication'),
      MonsterFamily.horned,
    );
    expect(MonsterIllustration.familyOf('numbers'), MonsterFamily.antennae);
    expect(MonsterIllustration.familyOf('addition'), MonsterFamily.eared);
    expect(MonsterFamily.of('division'), isNull);
  });
}

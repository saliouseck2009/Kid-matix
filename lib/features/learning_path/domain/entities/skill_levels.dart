import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/features/learning_path/domain/entities/skill_level.dart';

/// The skills of the placement test, in the order the test climbs them:
/// numbers, addition, subtraction, multiplication, division.
///
/// Each skill lists the unit keys of the domain that teaches it and three
/// typical questions, easy to hard. The keys are the ones of the released
/// catalogs (`num:`, `addsub:`, `mul:`, `div:`); a test pins them to the
/// real domains. Only units whose items can be answered on the keypad are
/// drawn from, so the comparison unit of the numbers is no typical
/// question.
abstract final class SkillLevels {
  /// Counting and reading numbers up to 100.
  static final SkillLevel numbers = SkillLevel(
    id: 'numbers',
    domainId: LearningDomainIds.numbers,
    unitKeys: const <String>[
      'num:count10',
      'num:count20',
      'num:count100',
      'num:tensones',
      'num:compare',
      'num:order',
      'num:beforeafter',
    ],
    probeUnitKeys: const <String>['num:count20', 'num:tensones', 'num:order'],
  );

  /// Adding, from the sums up to 5 to the carrying.
  static final SkillLevel addition = SkillLevel(
    id: 'addition',
    domainId: LearningDomainIds.addition,
    unitKeys: const <String>[
      'addsub:add5',
      'addsub:add7',
      'addsub:add9',
      'addsub:toten',
      'addsub:add12',
      'addsub:add14',
      'addsub:add20',
      'addsub:add100',
      'addsub:carry',
    ],
    probeUnitKeys: const <String>[
      'addsub:add5',
      'addsub:toten',
      'addsub:add20',
    ],
  );

  /// Subtracting, from the wholes up to 5 to the borrowing.
  static final SkillLevel subtraction = SkillLevel(
    id: 'subtraction',
    domainId: LearningDomainIds.addition,
    unitKeys: const <String>[
      'addsub:sub5',
      'addsub:sub7',
      'addsub:sub9',
      'addsub:subten',
      'addsub:sub12',
      'addsub:sub14',
      'addsub:sub20',
      'addsub:sub100',
      'addsub:borrow',
    ],
    probeUnitKeys: const <String>[
      'addsub:sub5',
      'addsub:subten',
      'addsub:sub20',
    ],
  );

  /// The multiplication tables, in the order of the learning path.
  static final SkillLevel multiplication = SkillLevel(
    id: 'multiplication',
    domainId: LearningDomainIds.multiplication,
    unitKeys: const <String>[
      'mul:1',
      'mul:2',
      'mul:10',
      'mul:5',
      'mul:3',
      'mul:4',
      'mul:6',
      'mul:9',
      'mul:7',
      'mul:8',
      'mul:11',
      'mul:12',
    ],
    probeUnitKeys: const <String>['mul:5', 'mul:9', 'mul:8'],
  );

  /// The divisions of the tables, in the order of the learning path.
  static final SkillLevel division = SkillLevel(
    id: 'division',
    domainId: LearningDomainIds.division,
    unitKeys: const <String>[
      'div:1',
      'div:2',
      'div:10',
      'div:5',
      'div:3',
      'div:4',
      'div:6',
      'div:9',
      'div:7',
      'div:8',
      'div:11',
      'div:12',
    ],
    probeUnitKeys: const <String>['div:5', 'div:9', 'div:8'],
  );

  /// Every skill, in the order of the climb.
  static final List<SkillLevel> all = List<SkillLevel>.unmodifiable(
    <SkillLevel>[numbers, addition, subtraction, multiplication, division],
  );

  /// The domains the test places in, once each, in the order of [all].
  static List<String> get domainIds => <String>[
    ...<String>{for (final SkillLevel skill in all) skill.domainId},
  ];
}

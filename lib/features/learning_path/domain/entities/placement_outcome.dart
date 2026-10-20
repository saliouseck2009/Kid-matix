import 'package:kid_matix/features/learning_path/domain/entities/skill_level.dart';
import 'package:meta/meta.dart';

/// What the placement test found about one skill.
@immutable
final class SkillResult {
  /// Creates the result of the skill [skillId] of [domainId].
  const SkillResult({
    required this.skillId,
    required this.domainId,
    required this.rightCount,
    required this.wrongCount,
    required this.isAcquired,
  });

  /// Skill, such as `addition`.
  final String skillId;

  /// Learning domain of the skill.
  final String domainId;

  /// Right answers among the typical questions asked.
  final int rightCount;

  /// Wrong answers among the typical questions asked.
  final int wrongCount;

  /// Whether the child has the skill.
  final bool isAcquired;

  /// Questions asked about the skill.
  int get askedCount => rightCount + wrongCount;
}

/// The level of a child in one learning domain: how many of its skills
/// they have, and the units the test opened.
@immutable
final class DomainLevel {
  /// Creates the level in [domainId].
  DomainLevel({
    required this.domainId,
    required this.level,
    required this.skillCount,
    required List<String> openedUnitKeys,
  }) : openedUnitKeys = List<String>.unmodifiable(openedUnitKeys);

  /// Learning domain.
  final String domainId;

  /// Skills of the domain the child has, from 0.
  final int level;

  /// Skills the test checks in the domain.
  final int skillCount;

  /// Units of the domain the test opened.
  final List<String> openedUnitKeys;

  /// Whether every skill of the domain is acquired.
  bool get isComplete => level == skillCount;
}

/// The result of a placement test: a level per domain, the units opened
/// and where to start.
@immutable
final class PlacementOutcome {
  /// Creates an outcome from its parts.
  PlacementOutcome({
    required List<SkillResult> skills,
    required List<DomainLevel> domains,
    required List<String> openedUnitKeys,
    required this.recommendedDomainId,
    required this.recommendedUnitKey,
  }) : skills = List<SkillResult>.unmodifiable(skills),
       domains = List<DomainLevel>.unmodifiable(domains),
       openedUnitKeys = List<String>.unmodifiable(openedUnitKeys);

  /// Builds the outcome of the [results] of the tested [skills], where the
  /// test opened [openedUnitKeys].
  ///
  /// The skills after the first one missed were not asked: they count as
  /// not acquired. The start is the first unit of the first skill missed
  /// that the test did not open; nothing is recommended when every skill
  /// is acquired.
  factory PlacementOutcome.of({
    required List<SkillLevel> skills,
    required List<SkillResult> results,
    required List<String> openedUnitKeys,
  }) {
    final Set<String> acquiredIds = <String>{
      for (final SkillResult result in results)
        if (result.isAcquired) result.skillId,
    };
    final List<String> domainIds = <String>[
      ...<String>{for (final SkillLevel skill in skills) skill.domainId},
    ];
    final List<DomainLevel> domains = <DomainLevel>[
      for (final String domainId in domainIds)
        DomainLevel(
          domainId: domainId,
          level: skills
              .where(
                (SkillLevel skill) =>
                    skill.domainId == domainId &&
                    acquiredIds.contains(skill.id),
              )
              .length,
          skillCount: skills
              .where((SkillLevel skill) => skill.domainId == domainId)
              .length,
          openedUnitKeys: _unitsOfDomain(skills, domainId, openedUnitKeys),
        ),
    ];
    SkillLevel? missed;
    for (final SkillLevel skill in skills) {
      if (!acquiredIds.contains(skill.id)) {
        missed = skill;
        break;
      }
    }
    String? startUnitKey;
    if (missed != null) {
      for (final String key in missed.unitKeys) {
        if (!openedUnitKeys.contains(key)) {
          startUnitKey = key;
          break;
        }
      }
    }
    return PlacementOutcome(
      skills: results,
      domains: domains,
      openedUnitKeys: openedUnitKeys,
      recommendedDomainId: missed?.domainId,
      recommendedUnitKey: startUnitKey,
    );
  }

  /// The skills that were asked, in order.
  final List<SkillResult> skills;

  /// A level per domain of the test, in the order of the skills.
  final List<DomainLevel> domains;

  /// Every unit the test opened.
  final List<String> openedUnitKeys;

  /// Domain to start with, or `null` when every skill is acquired.
  final String? recommendedDomainId;

  /// Unit to start with in that domain, or `null`.
  final String? recommendedUnitKey;

  /// Whether the child has every skill of the test.
  bool get isEverythingAcquired => recommendedDomainId == null;

  static List<String> _unitsOfDomain(
    List<SkillLevel> skills,
    String domainId,
    List<String> openedUnitKeys,
  ) {
    final Set<String> domainUnits = <String>{
      for (final SkillLevel skill in skills)
        if (skill.domainId == domainId) ...skill.unitKeys,
    };
    return <String>[
      for (final String key in openedUnitKeys)
        if (domainUnits.contains(key)) key,
    ];
  }
}

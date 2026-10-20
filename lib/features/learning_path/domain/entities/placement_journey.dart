import 'package:kid_matix/features/learning_path/domain/entities/placement_outcome.dart';
import 'package:kid_matix/features/learning_path/domain/entities/skill_level.dart';
import 'package:kid_matix/features/learning_path/domain/entities/skill_levels.dart';
import 'package:meta/meta.dart';

/// The adaptive placement test: it climbs the skills in order, asks the
/// typical questions of one skill, and goes up only while the child has
/// the skill; it stops at the first skill not acquired.
///
/// A skill is acquired with [SkillLevel.passMark] right answers among its
/// typical questions, and missed as soon as too many are wrong for that
/// to be possible, so the child is not asked questions that are too hard
/// for them. A right answer opens its unit and the easier units of the
/// skill before it. The journey is immutable: [answered] returns the next
/// one.
@immutable
final class PlacementJourney {
  const PlacementJourney._({
    required this.skills,
    required this.skillIndex,
    required this.probeIndex,
    required this.rightCount,
    required this.wrongCount,
    required this.results,
    required this.openedUnitKeys,
    required this.isOver,
  });

  /// Starts the journey at the first of [skills].
  factory PlacementJourney.start({List<SkillLevel>? skills}) {
    return PlacementJourney._(
      skills: List<SkillLevel>.unmodifiable(skills ?? SkillLevels.all),
      skillIndex: 0,
      probeIndex: 0,
      rightCount: 0,
      wrongCount: 0,
      results: const <SkillResult>[],
      openedUnitKeys: const <String>[],
      isOver: false,
    );
  }

  /// Every skill the journey can climb, in order.
  final List<SkillLevel> skills;

  /// Rank of the skill being asked, from 0.
  final int skillIndex;

  /// Rank of the typical question being asked in that skill, from 0.
  final int probeIndex;

  /// Right answers in the skill being asked.
  final int rightCount;

  /// Wrong answers in the skill being asked.
  final int wrongCount;

  /// The skills already decided, in order.
  final List<SkillResult> results;

  /// Units opened so far, without repeats.
  final List<String> openedUnitKeys;

  /// Whether the journey ended: a skill was missed or the last one done.
  final bool isOver;

  /// Skill being asked, or `null` when the journey is over.
  SkillLevel? get skill => isOver ? null : skills[skillIndex];

  /// Unit the next question is drawn from, or `null` when over.
  String? get probeUnitKey => skill?.probeUnitKeys[probeIndex];

  /// Questions answered so far.
  int get answeredCount =>
      results.fold(0, (int sum, SkillResult r) => sum + r.askedCount) +
      (isOver ? 0 : rightCount + wrongCount);

  /// Most questions the journey can ask: every typical question of every
  /// skill.
  int get maxQuestionCount => skills.fold(
    0,
    (int sum, SkillLevel skill) => sum + skill.probeUnitKeys.length,
  );

  /// Units a right answer to the next question opens.
  List<String> get unitKeysToOpen {
    final SkillLevel? current = skill;
    final String? probe = probeUnitKey;
    if (current == null || probe == null) return const <String>[];
    return current.unitKeysUpTo(probe);
  }

  /// The journey after the answer to the question asked.
  PlacementJourney answered({required bool isCorrect}) {
    final SkillLevel? current = skill;
    if (current == null) return this;
    final int right = rightCount + (isCorrect ? 1 : 0);
    final int wrong = wrongCount + (isCorrect ? 0 : 1);
    final List<String> opened = <String>[
      ...openedUnitKeys,
      if (isCorrect)
        for (final String key in unitKeysToOpen)
          if (!openedUnitKeys.contains(key)) key,
    ];
    final bool isMissed = wrong >= current.failureMark;
    final bool isLastProbe = probeIndex == current.probeUnitKeys.length - 1;
    if (!isMissed && !isLastProbe) {
      return _copyWith(
        probeIndex: probeIndex + 1,
        rightCount: right,
        wrongCount: wrong,
        openedUnitKeys: opened,
      );
    }
    final bool isAcquired = right >= SkillLevel.passMark;
    final bool isLastSkill = skillIndex == skills.length - 1;
    final List<SkillResult> decided = <SkillResult>[
      ...results,
      SkillResult(
        skillId: current.id,
        domainId: current.domainId,
        rightCount: right,
        wrongCount: wrong,
        isAcquired: isAcquired,
      ),
    ];
    return _copyWith(
      skillIndex: isAcquired && !isLastSkill ? skillIndex + 1 : skillIndex,
      probeIndex: 0,
      rightCount: 0,
      wrongCount: 0,
      results: decided,
      openedUnitKeys: opened,
      isOver: !isAcquired || isLastSkill,
    );
  }

  /// What the journey found; meaningful once it is over.
  PlacementOutcome get outcome {
    return PlacementOutcome.of(
      skills: skills,
      results: results,
      openedUnitKeys: openedUnitKeys,
    );
  }

  PlacementJourney _copyWith({
    int? skillIndex,
    int? probeIndex,
    int? rightCount,
    int? wrongCount,
    List<SkillResult>? results,
    List<String>? openedUnitKeys,
    bool? isOver,
  }) {
    return PlacementJourney._(
      skills: skills,
      skillIndex: skillIndex ?? this.skillIndex,
      probeIndex: probeIndex ?? this.probeIndex,
      rightCount: rightCount ?? this.rightCount,
      wrongCount: wrongCount ?? this.wrongCount,
      results: results ?? this.results,
      openedUnitKeys: openedUnitKeys ?? this.openedUnitKeys,
      isOver: isOver ?? this.isOver,
    );
  }
}

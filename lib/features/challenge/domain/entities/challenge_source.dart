import 'package:meta/meta.dart';

/// What a quiz of the challenge feature is played for, as the session
/// remembers it in its opaque source key.
///
/// A free training is written `training:20:timer:mul:2+mul:5`, a time
/// attack `timeAttack:mul:1+mul:2`, a survival game
/// `survival:mul:1+mul:2`, the daily review `dailyReview`, the monster
/// hunt `monsterHunt` (`monsterHunt:profile` when started from the
/// Profile tab).
@immutable
sealed class ChallengeSource {
  /// Creates a source on [unitKeys].
  ChallengeSource({required List<String> unitKeys})
    : unitKeys = List<String>.unmodifiable(unitKeys);

  /// Separator of the parts of a source key.
  static const String separator = ':';

  /// Separator of the unit keys.
  static const String unitSeparator = '+';

  /// Units the questions are drawn from, such as `mul:5`.
  final List<String> unitKeys;

  /// Reads [sourceKey]; `null` when it is not a source of this feature.
  static ChallengeSource? tryParse(String? sourceKey) {
    if (sourceKey == null) return null;
    return TrainingSource._tryParse(sourceKey) ??
        TimeAttackSource._tryParse(sourceKey) ??
        SurvivalSource._tryParse(sourceKey) ??
        DailyReviewSource._tryParse(sourceKey) ??
        MonsterHuntSource._tryParse(sourceKey);
  }

  /// The source key of the quiz.
  String toKey();

  static String _joinUnits(List<String> unitKeys) {
    return unitKeys.join(unitSeparator);
  }

  static List<String>? _splitUnits(String text) {
    final List<String> keys = text.split(unitSeparator);
    return keys.any((String key) => key.isEmpty) ? null : keys;
  }

  @override
  String toString() => toKey();
}

/// A free training: the tables, the question count and the timer chosen
/// by the child.
final class TrainingSource extends ChallengeSource {
  /// Creates the source.
  TrainingSource({
    required super.unitKeys,
    required this.questionCount,
    required this.hasTimer,
  });

  /// Prefix of every training source key.
  static const String prefix = 'training';

  static const String _timer = 'timer';
  static const String _noTimer = 'free';

  /// Scored questions to ask.
  final int questionCount;

  /// Whether each question has a timer.
  final bool hasTimer;

  /// Returns a copy with the given fields replaced.
  TrainingSource copyWith({
    List<String>? unitKeys,
    int? questionCount,
    bool? hasTimer,
  }) {
    return TrainingSource(
      unitKeys: unitKeys ?? this.unitKeys,
      questionCount: questionCount ?? this.questionCount,
      hasTimer: hasTimer ?? this.hasTimer,
    );
  }

  @override
  String toKey() {
    const String s = ChallengeSource.separator;
    final String timer = hasTimer ? _timer : _noTimer;
    return '$prefix$s$questionCount$s$timer$s'
        '${ChallengeSource._joinUnits(unitKeys)}';
  }

  static TrainingSource? _tryParse(String sourceKey) {
    final List<String> parts = sourceKey.split(ChallengeSource.separator);
    if (parts.length < 4 || parts.first != prefix) return null;
    final int? count = int.tryParse(parts[1]);
    final bool? hasTimer = switch (parts[2]) {
      _timer => true,
      _noTimer => false,
      _ => null,
    };
    final List<String>? units = ChallengeSource._splitUnits(
      parts.skip(3).join(ChallengeSource.separator),
    );
    if (count == null || count <= 0 || hasTimer == null || units == null) {
      return null;
    }
    return TrainingSource(
      unitKeys: units,
      questionCount: count,
      hasTimer: hasTimer,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TrainingSource && other.toKey() == toKey();
  }

  @override
  int get hashCode => toKey().hashCode;
}

/// A time attack on the units open to the player.
final class TimeAttackSource extends ChallengeSource {
  /// Creates the source.
  TimeAttackSource({required super.unitKeys});

  /// Prefix of every time attack source key.
  static const String prefix = 'timeAttack';

  @override
  String toKey() {
    return '$prefix${ChallengeSource.separator}'
        '${ChallengeSource._joinUnits(unitKeys)}';
  }

  static TimeAttackSource? _tryParse(String sourceKey) {
    const String start = '$prefix${ChallengeSource.separator}';
    if (!sourceKey.startsWith(start)) return null;
    final List<String>? units = ChallengeSource._splitUnits(
      sourceKey.substring(start.length),
    );
    return units == null ? null : TimeAttackSource(unitKeys: units);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TimeAttackSource && other.toKey() == toKey();
  }

  @override
  int get hashCode => toKey().hashCode;
}

/// A survival game on the units open to the player.
final class SurvivalSource extends ChallengeSource {
  /// Creates the source.
  SurvivalSource({required super.unitKeys});

  /// Prefix of every survival source key.
  static const String prefix = 'survival';

  @override
  String toKey() {
    return '$prefix${ChallengeSource.separator}'
        '${ChallengeSource._joinUnits(unitKeys)}';
  }

  static SurvivalSource? _tryParse(String sourceKey) {
    const String start = '$prefix${ChallengeSource.separator}';
    if (!sourceKey.startsWith(start)) return null;
    final List<String>? units = ChallengeSource._splitUnits(
      sourceKey.substring(start.length),
    );
    return units == null ? null : SurvivalSource(unitKeys: units);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SurvivalSource && other.toKey() == toKey();
  }

  @override
  int get hashCode => toKey().hashCode;
}

/// The daily review: the facts the mastery engine picks among every
/// table, so it names no unit.
final class DailyReviewSource extends ChallengeSource {
  /// Creates the source.
  DailyReviewSource() : super(unitKeys: const <String>[]);

  /// Source key of the daily review.
  static const String key = 'dailyReview';

  @override
  String toKey() => key;

  static DailyReviewSource? _tryParse(String sourceKey) {
    return sourceKey == key ? DailyReviewSource() : null;
  }

  @override
  bool operator ==(Object other) => other is DailyReviewSource;

  @override
  int get hashCode => key.hashCode;
}

/// The monster hunt: the facts the player keeps missing, picked by the
/// mastery engine among every table, so it names no unit. It remembers
/// whether « Mes monstres » was opened from the Profile tab, so the
/// results go back there.
final class MonsterHuntSource extends ChallengeSource {
  /// Creates the source.
  MonsterHuntSource({this.isFromProfile = false})
    : super(unitKeys: const <String>[]);

  /// Source key of the monster hunt started from the challenges.
  static const String key = 'monsterHunt';

  static const String _profile = 'profile';

  /// Whether the hunt was started from the Profile tab.
  final bool isFromProfile;

  @override
  String toKey() {
    return isFromProfile ? '$key${ChallengeSource.separator}$_profile' : key;
  }

  static MonsterHuntSource? _tryParse(String sourceKey) {
    if (sourceKey == key) return MonsterHuntSource();
    if (sourceKey == MonsterHuntSource(isFromProfile: true).toKey()) {
      return MonsterHuntSource(isFromProfile: true);
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MonsterHuntSource && other.isFromProfile == isFromProfile;
  }

  @override
  int get hashCode => toKey().hashCode;
}

import 'package:kid_matix/features/classroom/domain/entities/class_dashboard.dart';
import 'package:kid_matix/features/classroom/domain/entities/item_standing.dart';
import 'package:kid_matix/features/classroom/domain/entities/item_struggle.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_progress.dart';
import 'package:kid_matix/features/classroom/domain/services/item_standing_rule.dart';

/// Computes the dashboard of a class from its results alone: per pupil
/// (practice, last session, right answers, items acquired and stuck
/// on) and per item (how many pupils are stuck on it).
///
/// Pure and deterministic, so a class on one tablet and a class merged
/// from files give the same figures; the progress reports of F31 build
/// on it.
abstract final class ClassDashboardCalculator {
  /// The dashboard of [pupils] from their [sessions]; [assignmentItemKeys]
  /// are the items of the class's assignment, or `null` without one.
  static ClassDashboard compute({
    required List<PupilEntity> pupils,
    required List<PracticeSession> sessions,
    Set<String>? assignmentItemKeys,
  }) {
    final Map<String, List<PracticeSession>> byPupil =
        <String, List<PracticeSession>>{};
    for (final PracticeSession session in sessions) {
      byPupil
          .putIfAbsent(session.pupilId, () => <PracticeSession>[])
          .add(
            session,
          );
    }
    final List<PupilProgress> progress = <PupilProgress>[
      for (final PupilEntity pupil in pupils)
        progressOf(
          pupil,
          byPupil[pupil.id] ?? const <PracticeSession>[],
          assignmentItemKeys,
        ),
    ];
    return ClassDashboard(pupils: progress, struggles: _strugglesOf(progress));
  }

  /// The progress of [pupil] from their [sessions].
  static PupilProgress progressOf(
    PupilEntity pupil,
    List<PracticeSession> sessions,
    Set<String>? assignmentItemKeys,
  ) {
    final Map<String, ItemStanding> standings = ItemStandingRule.standingsOf(
      sessions,
    );
    final Set<String> acquired = _keysWith(standings, ItemStanding.acquired);
    return PupilProgress(
      pupil: pupil,
      sessionCount: sessions.length,
      practiceTime: sessions.fold(
        Duration.zero,
        (Duration total, PracticeSession session) => total + session.duration,
      ),
      lastPlayedAt: _lastEndOf(sessions),
      answerCount: _sum(sessions, (PracticeSession s) => s.questionCount),
      correctCount: _sum(sessions, (PracticeSession s) => s.correctCount),
      answeredItemKeys: standings.keys.toSet(),
      acquiredItemKeys: acquired,
      struggleItemKeys: _keysWith(standings, ItemStanding.struggling).toList()
        ..sort(),
      assignmentProgress: _shareOf(acquired, assignmentItemKeys),
    );
  }

  static List<ItemStruggle> _strugglesOf(List<PupilProgress> pupils) {
    final Map<String, List<String>> stuck = <String, List<String>>{};
    for (final PupilProgress progress in pupils) {
      for (final String itemKey in progress.struggleItemKeys) {
        stuck.putIfAbsent(itemKey, () => <String>[]).add(progress.pupil.id);
      }
    }
    return <ItemStruggle>[
      for (final MapEntry<String, List<String>> entry in stuck.entries)
        ItemStruggle(itemKey: entry.key, pupilIds: entry.value),
    ]..sort(_byPupilCountThenKey);
  }

  static int _byPupilCountThenKey(ItemStruggle a, ItemStruggle b) {
    final int byCount = b.pupilCount.compareTo(a.pupilCount);
    return byCount != 0 ? byCount : a.itemKey.compareTo(b.itemKey);
  }

  static Set<String> _keysWith(
    Map<String, ItemStanding> standings,
    ItemStanding standing,
  ) {
    return <String>{
      for (final MapEntry<String, ItemStanding> entry in standings.entries)
        if (entry.value == standing) entry.key,
    };
  }

  static DateTime? _lastEndOf(List<PracticeSession> sessions) {
    DateTime? last;
    for (final PracticeSession session in sessions) {
      final DateTime end = session.endedAt;
      if (last == null || end.isAfter(last)) last = end;
    }
    return last;
  }

  static int _sum(
    List<PracticeSession> sessions,
    int Function(PracticeSession session) valueOf,
  ) {
    return sessions.fold(
      0,
      (int total, PracticeSession session) => total + valueOf(session),
    );
  }

  static double? _shareOf(Set<String> acquired, Set<String>? itemKeys) {
    if (itemKeys == null || itemKeys.isEmpty) return null;
    return acquired.intersection(itemKeys).length / itemKeys.length;
  }
}

import 'package:kid_matix/features/classroom/domain/entities/item_standing.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_answer.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';

/// How a pupil stands on each item, read from their last answers in the
/// class results: the measure of the dashboard and of the level groups,
/// the same on every tablet since it only needs the results.
///
/// Second chances are left out: the item was just shown with its answer.
abstract final class ItemStandingRule {
  /// Last answers on an item that decide its standing.
  static const int window = 3;

  /// Mistakes among the last [window] answers that make a pupil
  /// « bloqué » on an item.
  static const int struggleMistakes = 2;

  /// The standing of an item from its answers, oldest first (`true` for
  /// a right one).
  static ItemStanding standingOf(List<bool> results) {
    final Iterable<bool> last = results.length > window
        ? results.sublist(results.length - window)
        : results;
    final int mistakes = last.where((bool isRight) => !isRight).length;
    if (mistakes >= struggleMistakes) return ItemStanding.struggling;
    if (last.length == window && mistakes == 0) return ItemStanding.acquired;
    return ItemStanding.learning;
  }

  /// The answers of [sessions], one pupil's, grouped by item, oldest
  /// first, second chances left out.
  static Map<String, List<bool>> resultsByItem(
    Iterable<PracticeSession> sessions,
  ) {
    final List<PracticeSession> ordered = sessions.toList()
      ..sort(
        (PracticeSession a, PracticeSession b) =>
            a.startedAt.compareTo(b.startedAt),
      );
    final Map<String, List<bool>> results = <String, List<bool>>{};
    for (final PracticeSession session in ordered) {
      final List<PracticeAnswer> answers = session.answers.toList()
        ..sort(
          (PracticeAnswer a, PracticeAnswer b) =>
              a.position.compareTo(b.position),
        );
      for (final PracticeAnswer answer in answers) {
        if (answer.isRetry) continue;
        results
            .putIfAbsent(answer.itemKey, () => <bool>[])
            .add(
              answer.isCorrect,
            );
      }
    }
    return results;
  }

  /// The standing of every item [sessions] asked, one pupil's.
  static Map<String, ItemStanding> standingsOf(
    Iterable<PracticeSession> sessions,
  ) {
    return resultsByItem(sessions).map(
      (String itemKey, List<bool> results) =>
          MapEntry<String, ItemStanding>(itemKey, standingOf(results)),
    );
  }
}

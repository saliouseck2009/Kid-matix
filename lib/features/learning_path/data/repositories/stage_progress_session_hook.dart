import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/storage/session_saved_hook.dart';
import 'package:kid_matix/features/learning_path/data/datasources/learning_path_tables.dart';
import 'package:kid_matix/features/learning_path/data/datasources/stage_progress_local_data_source.dart';
import 'package:kid_matix/features/learning_path/data/models/stage_progress_local_model.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_source.dart';
import 'package:kid_matix/features/learning_path/domain/services/star_policy.dart';
import 'package:sqflite/sqflite.dart';

/// Keeps the best stars of a stage when its quiz session is saved, in the
/// same transaction.
///
/// Only a completed quiz played for a stage counts: an abandoned one
/// earns no star.
final class StageProgressSessionHook implements SessionSavedHook {
  /// Creates the hook.
  const StageProgressSessionHook({
    required this._progress,
    required this._clock,
    this._stars = const StarPolicy(),
  });

  final StageProgressLocalDataSource _progress;
  final Clock _clock;
  final StarPolicy _stars;

  @override
  Future<List<String>> onSessionSaved({
    required Transaction transaction,
    required SavedQuizSession session,
  }) async {
    final StageSource? source = StageSource.tryParse(session.sourceKey);
    if (source == null || !session.isCompleted) return const <String>[];
    await _progress.keepBest(
      executor: transaction,
      result: StageProgressLocalModel(
        profileId: session.profileId,
        domainId: session.domainId,
        unitKey: source.unitKey,
        stage: source.stage,
        bestStars: _stars.starsFor(
          correctCount: session.correctCount,
          questionCount: session.questionCount,
        ),
        bestScore: session.correctCount,
        completedAt: session.endedAt.millisecondsSinceEpoch,
        updatedAt: _clock.now().millisecondsSinceEpoch,
      ),
    );
    return const <String>[LearningPathTables.stageProgress];
  }
}

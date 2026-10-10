import 'package:kid_matix/core/entities/game_feedback.dart';
import 'package:kid_matix/core/services/game_feedback_service.dart';

/// [GameFeedbackService] that plays nothing and keeps what it was asked.
final class RecordingGameFeedback implements GameFeedbackService {
  /// Feedback asked so far, in order.
  final List<GameFeedback> played = <GameFeedback>[];

  @override
  Future<void> play(GameFeedback feedback) async => played.add(feedback);
}

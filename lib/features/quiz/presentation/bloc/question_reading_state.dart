import 'package:kid_matix/features/quiz/domain/entities/read_aloud_mode.dart';
import 'package:meta/meta.dart';

/// What the listen button of a question outside the quiz shows.
@immutable
final class QuestionReadingState {
  /// Creates the state.
  const QuestionReadingState({
    this.mode = ReadAloudMode.unavailable,
    this.isSpeaking = false,
  });

  /// Whether a voice exists and whether questions read themselves.
  final ReadAloudMode mode;

  /// Whether the voice is reading the question.
  final bool isSpeaking;

  /// Whether the listen button is shown.
  bool get canRead => mode != ReadAloudMode.unavailable;

  /// Returns a copy with the given fields replaced.
  QuestionReadingState copyWith({ReadAloudMode? mode, bool? isSpeaking}) {
    return QuestionReadingState(
      mode: mode ?? this.mode,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionReadingState &&
          other.mode == mode &&
          other.isSpeaking == isSpeaking;

  @override
  int get hashCode => Object.hash(mode, isSpeaking);
}

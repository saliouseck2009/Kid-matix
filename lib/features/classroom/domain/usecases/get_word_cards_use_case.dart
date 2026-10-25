import 'package:kid_matix/core/entities/word_card.dart';
import 'package:kid_matix/core/services/teacher_audio_service.dart';
import 'package:kid_matix/core/services/word_card_service.dart';

/// The printable word cards (F31-07): each math word in French, with the
/// help language of the app (the first audio pack, `null` without one)
/// whose line stays blank until the owner writes its text.
typedef WordCardSheet = ({List<WordCard> cards, String? helpLanguage});

/// Reads the printable word cards and their help language.
class GetWordCardsUseCase {
  /// Creates the use case.
  const GetWordCardsUseCase({required this._cards, required this._audio});

  final WordCardService _cards;
  final TeacherAudioService _audio;

  /// The cards and their help language.
  WordCardSheet call() {
    return (
      cards: _cards.readCards(),
      helpLanguage: _audio.packLanguages.firstOrNull,
    );
  }
}

import 'package:kid_matix/core/entities/word_audio_kind.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/services/teacher_audio_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/entities/teacher_recordings.dart';

/// Reads the page of the teacher's recordings: every math word with
/// whether the pack and the teacher recorded it, in [languageCode] (the
/// first help language when `null`) for [kind].
class GetTeacherRecordingsUseCase
    implements
        UseCase<
          DataState<TeacherRecordings>,
          ({String? languageCode, WordAudioKind kind})
        > {
  /// Creates the use case.
  const GetTeacherRecordingsUseCase({
    required this._audio,
    required this._domains,
  });

  final TeacherAudioService _audio;
  final DomainRegistry _domains;

  @override
  Future<DataState<TeacherRecordings>> call({
    required ({String? languageCode, WordAudioKind kind}) params,
  }) async {
    final List<String> languages = _audio.packLanguages;
    final String? language = languages.contains(params.languageCode)
        ? params.languageCode
        : languages.firstOrNull;
    if (language == null) {
      return DataSuccess<TeacherRecordings>(
        TeacherRecordings(
          languages: languages,
          languageCode: null,
          kind: params.kind,
          words: const <RecordingWord>[],
        ),
      );
    }
    final DataState<Set<String>> recorded = await _audio.readRecordedKeys(
      languageCode: language,
      kind: params.kind,
    );
    return switch (recorded) {
      DataFailed<Set<String>>(:final exception) =>
        DataFailed<TeacherRecordings>(exception),
      DataSuccess<Set<String>>(:final data) => DataSuccess<TeacherRecordings>(
        TeacherRecordings(
          languages: languages,
          languageCode: language,
          kind: params.kind,
          words: _wordsOf(language, params.kind, data),
        ),
      ),
    };
  }

  List<RecordingWord> _wordsOf(
    String language,
    WordAudioKind kind,
    Set<String> recorded,
  ) {
    final LearningDomain? words = _domains.find(LearningDomainIds.mathWords);
    if (words == null) return const <RecordingWord>[];
    return <RecordingWord>[
      for (final LearningUnit unit in words.units)
        for (final LearningItem item in unit.items)
          if (words.recordingKeyOf(item) case final String wordKey)
            RecordingWord(
              itemKey: item.key,
              wordKey: wordKey,
              hasPackAudio: _audio.hasPackAudio(
                languageCode: language,
                wordKey: wordKey,
                kind: kind,
              ),
              hasTeacherAudio: recorded.contains(wordKey),
            ),
    ];
  }
}

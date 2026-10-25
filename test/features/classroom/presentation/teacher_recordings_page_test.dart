import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/word_audio_kind.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/system_clock.dart';
import 'package:kid_matix/core/services/teacher_audio_service.dart';
import 'package:kid_matix/core/entities/shared_file.dart';
import 'package:kid_matix/features/classroom/domain/repositories/report_share_repository.dart';
import 'package:kid_matix/features/classroom/domain/usecases/audio_pack_file_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_teacher_recordings_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/record_explanation_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/teacher_audio_pages.dart';

import '../../../helpers/fake_word_audio_service.dart';
import '../../../helpers/pump_localized.dart';
import '../../math_word/helpers/math_word_fixtures.dart';

/// The teacher's recordings kept in memory; the microphone is allowed
/// unless [isAllowed] is false.
final class _FakeTeacherAudio implements TeacherAudioService {
  final Set<String> recorded = <String>{};
  bool isAllowed = true;
  bool isRecording = false;

  @override
  List<String> get packLanguages => const <String>['wo'];

  @override
  bool hasPackAudio({
    required String languageCode,
    required String wordKey,
    required WordAudioKind kind,
  }) => wordKey == 'ajouter';

  @override
  Future<DataState<Set<String>>> readRecordedKeys({
    required String languageCode,
    required WordAudioKind kind,
  }) async => DataSuccess<Set<String>>(recorded.toSet());

  @override
  Future<DataState<void>> startRecording() async {
    if (!isAllowed) {
      return const DataFailed<void>(
        PermissionDeniedException(message: 'No microphone.'),
      );
    }
    isRecording = true;
    return const DataSuccess<void>(null);
  }

  @override
  Future<DataState<void>> saveRecording({
    required String languageCode,
    required String wordKey,
    required WordAudioKind kind,
  }) async {
    isRecording = false;
    recorded.add(wordKey);
    return const DataSuccess<void>(null);
  }

  @override
  Future<DataState<void>> cancelRecording() async {
    isRecording = false;
    return const DataSuccess<void>(null);
  }

  @override
  Future<DataState<void>> deleteRecording({
    required String languageCode,
    required String wordKey,
    required WordAudioKind kind,
  }) async {
    recorded.remove(wordKey);
    return const DataSuccess<void>(null);
  }

  @override
  Future<DataState<List<int>>> exportPack({
    required String languageCode,
  }) async => const DataSuccess<List<int>>(<int>[1]);

  @override
  Future<DataState<int>> importPack({required List<int> bytes}) async =>
      const DataSuccess<int>(1);
}

final class _NoFiles implements ReportShareRepository {
  @override
  Future<DataState<bool>> share({required List<SharedFile> files}) async =>
      const DataSuccess<bool>(true);

  @override
  Future<DataState<List<int>?>> pick() async =>
      const DataSuccess<List<int>?>(null);
}

void main() {
  late _FakeTeacherAudio audio;
  late TeacherAudioPages pages;

  setUp(() {
    audio = _FakeTeacherAudio();
    final DomainRegistry domains = DomainRegistry()
      ..register(buildMathWordDomain());
    const Clock clock = SystemClock();
    pages = TeacherAudioPages(
      useCases: (
        get: GetTeacherRecordingsUseCase(audio: audio, domains: domains),
        record: RecordExplanationUseCase(
          audio: audio,
          words: FakeWordAudioService(),
        ),
        packs: AudioPackFileUseCase(
          audio: audio,
          files: _NoFiles(),
          clock: clock,
        ),
      ),
      domains: domains,
    );
  });

  testWidgets('records a word and shows it as the teacher\'s voice', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpLocalized(tester, pages.buildPage(onBack: () {}));
    await tester.pumpAndSettle();
    expect(find.text('Voix du pack'), findsOneWidget);
    // Act
    await tester.tap(find.byTooltip('Enregistrer «\u00a0ajouter\u00a0»'));
    await tester.pumpAndSettle();
    expect(audio.isRecording, isTrue);
    await tester.tap(find.text('Arrêter et garder'));
    await tester.pumpAndSettle();
    // Assert
    expect(audio.recorded, <String>{'ajouter'});
    expect(find.text('Ta voix'), findsOneWidget);
    expect(find.text("C'est enregistré."), findsOneWidget);
  });

  testWidgets('says the microphone is needed when it is refused', (
    WidgetTester tester,
  ) async {
    // Arrange
    audio.isAllowed = false;
    await pumpLocalized(tester, pages.buildPage(onBack: () {}));
    await tester.pumpAndSettle();
    // Act
    await tester.tap(find.byTooltip('Enregistrer «\u00a0ajouter\u00a0»'));
    await tester.pumpAndSettle();
    // Assert
    expect(find.textContaining('Sans le micro'), findsOneWidget);
    expect(audio.recorded, isEmpty);
  });
}

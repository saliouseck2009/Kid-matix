import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kid_matix/core/entities/shared_file.dart';
import 'package:kid_matix/core/entities/word_card.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/extensions/prompt_reading.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/services/seeded_random_source.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_exercise_sheet_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/report/printable_files.dart';
import 'package:kid_matix/features/math_word/domain/entities/math_word_catalog.dart';
import 'package:kid_matix/features/math_word/domain/services/word_card_service_impl.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/features/number/domain/services/numbers_domain.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

import '../../math_word/helpers/math_word_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final AppLocalizations l10n = lookupAppLocalizations(const Locale('fr'));
  final DomainRegistry domains = DomainRegistry()
    ..register(MultiplicationDomain())
    ..register(NumbersDomain());
  final GetExerciseSheetUseCase getSheet = GetExerciseSheetUseCase(
    domains: domains,
    random: SeededRandomSource(seed: 7),
  );

  setUpAll(() => initializeDateFormatting('fr'));

  test('draws each fact of a table once, as on the keypad', () async {
    // Act
    final ExerciseSheet actual = ((await getSheet(
      params: (domainId: 'multiplication', unitKey: 'mul:7'),
    )) as DataSuccess<ExerciseSheet>).data;
    // Assert
    expect(actual.questions, hasLength(10));
    expect(
      actual.questions.map((q) => q.itemKey).toSet(),
      hasLength(10),
    );
    expect(
      actual.questions.first.prompt.toDisplayText(blankText: '___'),
      contains('7'),
    );
  });

  test('refuses a unit played with pictures', () async {
    // Act
    final DataState<ExerciseSheet> actual = await getSheet(
      params: (domainId: 'numbers', unitKey: 'num:count10'),
    );
    // Assert
    expect(
      (actual as DataFailed<ExerciseSheet>).exception.code,
      AppErrorCode.validation,
    );
  });

  test('prints the exercises and their answers as a PDF', () async {
    // Arrange
    final ExerciseSheet inputSheet = ((await getSheet(
      params: (domainId: 'multiplication', unitKey: 'mul:7'),
    )) as DataSuccess<ExerciseSheet>).data;
    // Act
    final SharedFile actual = await PrintableFiles(l10n: l10n).exerciseSheetOf(
      inputSheet,
      day: DateTime(2026, 11, 2),
    );
    // Assert
    expect(actual.name, 'KidMatix-Exercices-Table-de-7-2026-11-02.pdf');
    expect(ascii.decode(actual.bytes.take(5).toList()), '%PDF-');
  });

  test('prints the word cards, the Wolof text only when written', () async {
    // Arrange: the owner wrote the Wolof explanation of one word only.
    final Map<String, Object?> inputJson = jsonDecode(
      File('assets/math_words/math_words.json').readAsStringSync(),
    ) as Map<String, Object?>;
    for (final Object? word in inputJson['words']! as List<Object?>) {
      (word! as Map<String, Object?>).remove('help');
    }
    final Map<String, Object?> inputFirst =
        (inputJson['words']! as List<Object?>).first! as Map<String, Object?>
          ..['help'] = <String, Object?>{
            'wo': <String, Object?>{
              'explanation': '(texte du propriétaire)',
              'example': '(exemple du propriétaire)',
            },
          };
    final List<WordCard> actualCards = WordCardServiceImpl(
      catalog: MathWordCatalog.fromJson(inputJson),
    ).readCards();
    // Act
    final SharedFile actual = await PrintableFiles(l10n: l10n).wordCardsOf((
      cards: actualCards,
      helpLanguage: 'wo',
    ), day: DateTime(2026, 11, 2));
    // Assert
    expect(inputFirst['key'], actualCards.first.wordKey);
    expect(actualCards.first.helpExplanations['wo'], '(texte du propriétaire)');
    expect(actualCards.first.helpExamples['wo'], '(exemple du propriétaire)');
    expect(actualCards[1].helpExplanations, isEmpty);
    expect(
      WordCardServiceImpl(catalog: loadMathWordCatalog()).readCards().every(
        (WordCard card) =>
            card.helpExplanations.keys.every((String code) => code == 'wo'),
      ),
      isTrue,
    );
    expect(actual.name, 'KidMatix-Mots-2026-11-02.pdf');
    expect(ascii.decode(actual.bytes.take(5).toList()), '%PDF-');
  });
}

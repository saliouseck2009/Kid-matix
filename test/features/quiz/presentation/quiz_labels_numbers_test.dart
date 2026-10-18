import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_labels.dart';
import 'package:kid_matix/l10n/app_localizations_fr.dart';

import '../helpers/quiz_fixtures.dart';

Question _question(
  String questionTypeId,
  List<PromptToken> prompt, {
  MathPicture? picture,
}) {
  return Question(
    itemKey: 'num:after:39',
    unitKey: 'num:beforeafter',
    questionTypeId: questionTypeId,
    prompt: prompt,
    picture: picture,
    expectedAnswer: const NumberAnswer(40),
  );
}

void main() {
  final QuizLabels labels = QuizLabels(
    domains: buildDomainRegistry(),
    l10n: AppLocalizationsFr(),
  );
  final NumberLinePicture line = NumberLinePicture(
    values: const <int>[38, 39, 40],
    blankIndex: 2,
  );

  test('asks to read a drawing in the formats made for it', () {
    // Act
    final Question inputLine = _question(
      QuestionTypeIds.numberLine,
      const <PromptToken>[],
      picture: line,
    );
    final Question inputObjects = _question(
      QuestionTypeIds.countObjects,
      const <PromptToken>[BlankToken()],
      picture: const ObjectsPicture(count: 7),
    );
    // Assert
    expect(
      labels.describeQuestion(inputLine, 'numbers'),
      'Quel nombre manque ?',
    );
    expect(
      labels.speakQuestion(inputLine, 'numbers'),
      'Droite des nombres : 38, 39, nombre caché. '
      'Quel nombre manque ?',
    );
    expect(
      labels.describeQuestion(inputObjects, 'numbers'),
      'Combien de mangues ?',
    );
  });
  test('asks to write the number of a drawing alone', () {
    // Act
    final Question inputWritten = _question(
      QuestionTypeIds.typedAnswer,
      const <PromptToken>[BlankToken()],
      picture: const TenBundlesPicture(tens: 3, ones: 4),
    );
    // Assert
    expect(
      labels.describeQuestion(inputWritten, 'numbers'),
      'Quel nombre ?',
    );
    expect(
      labels.speakQuestion(inputWritten, 'numbers'),
      '3 paquets de dix et 4 bâtonnets : quel nombre ?',
    );
  });
  test('names the unit of an operation helped by a drawing', () {
    // Act
    final Question inputOperation = _question(
      QuestionTypeIds.typedAnswer,
      const <PromptToken>[
        NumberToken(39),
        OperatorToken(MathOperator.add),
        NumberToken(1),
        EqualsToken(),
        BlankToken(),
      ],
      picture: line,
    );
    final Question inputPicked = _question(
      QuestionTypeIds.multipleChoice,
      const <PromptToken>[BlankToken()],
      picture: line,
    );
    // Assert
    expect(
      labels.describeQuestion(inputOperation, 'numbers'),
      'Avant et après',
    );
    expect(
      labels.speakQuestion(inputOperation, 'numbers'),
      '39 plus 1 égale combien',
    );
    expect(labels.describeQuestion(inputPicked, 'numbers'), 'Avant et après');
  });
}

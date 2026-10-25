import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/bar_model.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_template.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_templates.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/problem_board_progress.dart';

/// The steps of a word problem, without a screen (F30-03, F30-04).
void main() {
  BarModelPicture modelOf(String key) {
    return ProblemTemplates.all
        .firstWhere((ProblemTemplate p) => p.problemKey == key)
        .fixedInstance()
        .picture;
  }

  /// `12 - 5 = 7`: the whole 12 (tile 0) and the part 5 (tile 1).
  ProblemBoardProgress subtraction({bool isGuided = false}) {
    return ProblemBoardProgress(
      model: modelOf('mangues_donnees'),
      isGuided: isGuided,
    );
  }

  group('the steps', () {
    test('are three on the bar model and five when guided', () {
      // Assert
      expect(subtraction().steps, <ProblemStep>[
        ProblemStep.model,
        ProblemStep.operation,
        ProblemStep.compute,
      ]);
      expect(subtraction(isGuided: true).steps, <ProblemStep>[
        ProblemStep.listen,
        ProblemStep.model,
        ProblemStep.operation,
        ProblemStep.compute,
        ProblemStep.check,
      ]);
    });

    test('finish after the last one, with no mistake', () {
      // Arrange
      final ProblemBoardProgress progress = subtraction();
      // Act
      progress
        ..selectTile(0)
        ..placeSelected(BarRole.whole)
        ..selectTile(1)
        ..placeSelected(BarRole.partA);
      // Assert
      expect(progress.step, ProblemStep.operation);
      expect(progress.pickOperator(MathOperator.subtract), isTrue);
      expect(progress.step, ProblemStep.compute);
      expect(progress.isFinished, isFalse);
      expect(progress.pickNumber(7), isTrue);
      expect(progress.isFinished, isTrue);
      expect(progress.answer, const ProblemAnswer());
    });

    test('wait for the check of a guided problem', () {
      // Arrange
      final ProblemBoardProgress progress = subtraction(isGuided: true)
        ..advance()
        ..selectTile(0)
        ..placeSelected(BarRole.whole)
        ..selectTile(1)
        ..placeSelected(BarRole.partA)
        ..pickOperator(MathOperator.subtract)
        ..pickNumber(7);
      // Assert
      expect(progress.step, ProblemStep.check);
      expect(progress.isFinished, isFalse);
      // Act
      progress.advance();
      // Assert
      expect(progress.isFinished, isTrue);
    });
  });

  group('a wrong touch', () {
    test('is counted, shown and never ends the problem', () {
      // Arrange
      final ProblemBoardProgress progress = subtraction();
      // Act: the part on the whole.
      progress.selectTile(1);
      final bool placed = progress.placeSelected(BarRole.whole);
      // Assert
      expect(placed, isFalse);
      expect(progress.mistakeCount, 1);
      expect(progress.wrongRole, BarRole.whole);
      expect(progress.lastTouchWasWrong, isTrue);
      expect(progress.step, ProblemStep.model);
      expect(progress.usedTiles, isEmpty);
      // Act: a sign and a result that do not fit.
      progress
        ..selectTile(0)
        ..placeSelected(BarRole.whole)
        ..selectTile(1)
        ..placeSelected(BarRole.partA);
      expect(progress.pickOperator(MathOperator.add), isFalse);
      expect(progress.wrongOperators, <MathOperator>{MathOperator.add});
      progress.pickOperator(MathOperator.subtract);
      expect(progress.pickNumber(17), isFalse);
      expect(progress.wrongNumbers, <int>{17});
      progress.pickNumber(7);
      // Assert
      expect(progress.answer, const ProblemAnswer(mistakeCount: 3));
      expect(progress.answer, isNot(const ProblemAnswer()));
    });

    test('forgets the last mistake once the child does the right thing', () {
      // Arrange
      final ProblemBoardProgress progress = subtraction()
        ..selectTile(1)
        ..placeSelected(BarRole.whole);
      // Act
      progress
        ..selectTile(0)
        ..placeSelected(BarRole.whole);
      // Assert
      expect(progress.lastTouchWasWrong, isFalse);
      expect(progress.wrongRole, isNull);
      expect(progress.mistakeCount, 1);
    });

    test('does nothing when no number was picked first', () {
      // Arrange
      final ProblemBoardProgress progress = subtraction();
      // Act
      final bool placed = progress.placeSelected(BarRole.whole);
      // Assert
      expect(placed, isFalse);
      expect(progress.mistakeCount, 0);
    });
  });

  group('the places', () {
    test('take any part first when the whole is the answer', () {
      // Arrange: 5 and 7 are the two parts of the 12 to find.
      final ProblemBoardProgress progress = ProblemBoardProgress(
        model: modelOf('mangues_donnees_piege'),
        isGuided: false,
      );
      final int first = progress.tiles.first;
      final int second = progress.tiles.last;
      // Act: the second part goes first, on the first place.
      progress.selectTile(1);
      final bool firstPlaced = progress.placeSelected(BarRole.partA);
      progress.selectTile(0);
      final bool secondPlaced = progress.placeSelected(BarRole.partB);
      // Assert
      expect(<int>{first, second}, <int>{5, 7});
      expect(firstPlaced && secondPlaced, isTrue);
      expect(progress.mistakeCount, 0);
      expect(progress.step, ProblemStep.operation);
    });

    test('give each part its own tile', () {
      // Arrange
      final ProblemBoardProgress progress =
          ProblemBoardProgress(
              model: modelOf('mangues_donnees_piege'),
              isGuided: false,
            )
            ..selectTile(0)
            ..placeSelected(BarRole.partA);
      final int remaining = progress.tiles[1];
      // Assert: only the other part is left to place.
      expect(remaining, isNot(progress.tiles[0]));
    });

    test('start filled when the story gives the number, like the half', () {
      // Arrange
      final ProblemBoardProgress progress = ProblemBoardProgress(
        model: modelOf('mangues_moitie_piege'),
        isGuided: false,
      );
      // Assert: « la moitié » is a 2 the child does not write.
      expect(progress.placed[BarRole.times], 2);
      expect(progress.tiles, <int>[25]);
      // Act
      progress
        ..selectTile(0)
        ..placeSelected(BarRole.small);
      // Assert
      expect(progress.step, ProblemStep.operation);
      expect(progress.mistakeCount, 0);
    });
  });
}

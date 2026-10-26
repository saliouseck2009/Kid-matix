import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/bar_model.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';

/// The steps of a word problem.
enum ProblemStep {
  /// Listen to the statement and touch its math words.
  listen,

  /// Put the numbers of the story on the bar model.
  model,

  /// Pick the operation.
  operation,

  /// Pick the result of the calculation.
  compute,

  /// Read the check sentence.
  check,
}

/// Where a child is in a word problem: the step, what is placed on the
/// model, what was picked wrongly, and the mistakes made.
///
/// A wrong touch never ends the problem: it is counted and the child tries
/// again. The problem is [isFinished] once its last step is done, and its
/// [answer] is right when no mistake was made.
final class ProblemBoardProgress {
  /// Creates the progress on [model]; [isGuided] adds the listening and the
  /// check steps.
  ProblemBoardProgress({required this.model, required this.isGuided})
    : steps = <ProblemStep>[
        if (isGuided) ProblemStep.listen,
        ProblemStep.model,
        ProblemStep.operation,
        ProblemStep.compute,
        if (isGuided) ProblemStep.check,
      ],
      tiles = <int>[
        for (final BarRole role in model.placeableRoles) model.values[role]!,
      ],
      placed = <BarRole, int>{
        for (final BarRole role in model.prefilled) role: model.values[role]!,
      };

  /// The bar model of the story.
  final BarModelPicture model;

  /// Whether the problem is solved in five steps instead of three.
  final bool isGuided;

  /// The steps, in order.
  final List<ProblemStep> steps;

  /// The numbers of the story to put on the model, in the order of its
  /// places.
  final List<int> tiles;

  /// The number written in each filled place, the places the story fills
  /// for the child included.
  final Map<BarRole, int> placed;

  /// Tiles already put on the model.
  final Set<int> usedTiles = <int>{};

  /// Signs picked wrongly.
  final Set<MathOperator> wrongOperators = <MathOperator>{};

  /// Results picked wrongly.
  final Set<int> wrongNumbers = <int>{};

  /// Position of the current step.
  int stepIndex = 0;

  /// Wrong touches so far.
  int mistakeCount = 0;

  /// The tile the child picked to put on a place, or `null`.
  int? selectedTile;

  /// The place that just got a wrong number, or `null`.
  BarRole? wrongRole;

  /// Whether the last touch was wrong, so the board says kindly where to
  /// look.
  bool lastTouchWasWrong = false;

  /// Whether the right result was picked.
  bool isComputed = false;

  /// Whether the last step is done.
  bool isFinished = false;

  /// The current step.
  ProblemStep get step => steps[stepIndex];

  /// The answer of the problem: right with no mistake.
  ProblemAnswer get answer => ProblemAnswer(mistakeCount: mistakeCount);

  /// Picks the tile [index], or puts it back when it was picked.
  void selectTile(int index) {
    selectedTile = selectedTile == index ? null : index;
    wrongRole = null;
  }

  /// Puts the picked tile on [role]. Returns whether it fits; a wrong place
  /// is a mistake. The step ends when every number is placed.
  bool placeSelected(BarRole role) {
    final int? tile = selectedTile;
    if (tile == null) {
      lastTouchWasWrong = false;
      return false;
    }
    final int value = tiles[tile];
    selectedTile = null;
    if (!_fits(role, value)) {
      wrongRole = role;
      _miss();
      return false;
    }
    placed[role] = value;
    usedTiles.add(tile);
    wrongRole = null;
    lastTouchWasWrong = false;
    if (usedTiles.length == tiles.length) advance();
    return true;
  }

  /// Picks the sign [operator]. Returns whether it is the right one.
  bool pickOperator(MathOperator operator) {
    if (operator == model.operator) {
      advance();
      return true;
    }
    wrongOperators.add(operator);
    _miss();
    return false;
  }

  /// Picks the result [value]. Returns whether it is the right one.
  bool pickNumber(int value) {
    if (value == model.answer) {
      isComputed = true;
      advance();
      return true;
    }
    wrongNumbers.add(value);
    _miss();
    return false;
  }

  /// Goes to the next step, or finishes after the last one.
  void advance() {
    lastTouchWasWrong = false;
    if (stepIndex == steps.length - 1) {
      isFinished = true;
    } else {
      stepIndex++;
    }
  }

  void _miss() {
    mistakeCount++;
    lastTouchWasWrong = true;
  }

  /// Whether [value] belongs in [role]: the number the story gives there,
  /// or, for the two parts of a whole to find, any part not placed yet.
  bool _fits(BarRole role, int value) {
    if (!model.hasInterchangeableParts) return model.values[role] == value;
    final List<int> remaining = <int>[
      model.values[BarRole.partA]!,
      model.values[BarRole.partB]!,
    ];
    for (final int taken in placed.values) {
      remaining.remove(taken);
    }
    return remaining.contains(value);
  }
}

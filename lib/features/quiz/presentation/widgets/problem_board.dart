import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/extensions/prompt_reading.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/bar_model.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/theme/app_feedback_palette.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/bar_model_view.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/problem_statement.dart';

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

/// A word problem solved on its bar model (F30-03), or step by step from
/// the statement to the check (F30-04).
///
/// The child puts the numbers of the story on the model, picks the
/// operation, then the result. A wrong touch never ends the problem: the
/// message sends the child back to the story and the drawing, and the
/// mistake is counted. The problem is answered once its last step is done,
/// with the number of mistakes: right when there was none.
class ProblemBoard extends StatefulWidget {
  /// Creates the board of [question]; [isGuided] adds the listening and
  /// the check steps.
  const ProblemBoard({
    required this.question,
    required this.isGuided,
    required this.languageCode,
    required this.onSolved,
    this.listenButton,
    super.key,
  });

  /// The problem, whose picture is a [BarModelPicture].
  final Question question;

  /// Whether the problem is solved in five steps instead of three.
  final bool isGuided;

  /// Language of the statement, which the voice speaks.
  final String languageCode;

  /// Called with the [ProblemAnswer] when the last step is done.
  final ValueChanged<Answer> onSolved;

  /// The button that reads the statement aloud, or `null` without a voice.
  final Widget? listenButton;

  @override
  State<ProblemBoard> createState() => _ProblemBoardState();
}

class _ProblemBoardState extends State<ProblemBoard> {
  static const double _radius = 28;

  late final BarModelPicture _model =
      widget.question.picture! as BarModelPicture;
  late final List<ProblemStep> _steps = <ProblemStep>[
    if (widget.isGuided) ProblemStep.listen,
    ProblemStep.model,
    ProblemStep.operation,
    ProblemStep.compute,
    if (widget.isGuided) ProblemStep.check,
  ];
  late final List<int> _tiles = <int>[
    for (final BarRole role in _model.knownRoles) _model.values[role]!,
  ];

  int _stepIndex = 0;
  int _mistakes = 0;
  bool _showsTryAgain = false;
  final Map<BarRole, int> _placed = <BarRole, int>{};
  final Set<int> _usedTiles = <int>{};
  int? _selectedTile;
  BarRole? _wrongRole;
  final Set<MathOperator> _wrongOperators = <MathOperator>{};
  final Set<int> _wrongNumbers = <int>{};
  bool _isComputed = false;

  ProblemStep get _step => _steps[_stepIndex];

  void _goToNextStep() {
    if (_stepIndex == _steps.length - 1) {
      widget.onSolved(ProblemAnswer(mistakeCount: _mistakes));
      return;
    }
    setState(() {
      _stepIndex++;
      _showsTryAgain = false;
    });
  }

  void _miss() {
    _mistakes++;
    _showsTryAgain = true;
  }

  void _selectTile(int index) {
    setState(() {
      _selectedTile = _selectedTile == index ? null : index;
      _wrongRole = null;
    });
  }

  /// Whether [value] belongs in [role]: the number the story gives there,
  /// or, for the two parts of a whole to find, any part not placed yet.
  bool _fits(BarRole role, int value) {
    if (!_model.hasInterchangeableParts) return _model.values[role] == value;
    final List<int> remaining = <int>[
      _model.values[BarRole.partA]!,
      _model.values[BarRole.partB]!,
    ];
    for (final int placed in _placed.values) {
      remaining.remove(placed);
    }
    return remaining.contains(value);
  }

  void _placeOn(BarRole role) {
    final int? tile = _selectedTile;
    if (tile == null) {
      setState(() => _showsTryAgain = false);
      return;
    }
    final int value = _tiles[tile];
    setState(() {
      if (_fits(role, value)) {
        _placed[role] = value;
        _usedTiles.add(tile);
        _selectedTile = null;
        _wrongRole = null;
        _showsTryAgain = false;
      } else {
        _wrongRole = role;
        _selectedTile = null;
        _miss();
      }
    });
    if (_placed.length == _tiles.length) _goToNextStep();
  }

  void _pickOperator(MathOperator operator) {
    if (operator == _model.operator) {
      _goToNextStep();
      return;
    }
    setState(() {
      _wrongOperators.add(operator);
      _miss();
    });
  }

  void _pickNumber(int value) {
    if (value == _model.answer) {
      setState(() => _isComputed = true);
      _goToNextStep();
      return;
    }
    setState(() {
      _wrongNumbers.add(value);
      _miss();
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space12,
      children: <Widget>[
        Row(
          spacing: AppSizes.space8,
          children: <Widget>[
            Expanded(
              child: Text(
                widget.isGuided
                    ? context.l10n.quizProblemSolveLabel
                    : context.l10n.quizBarModelQuestionLabel,
                style: textTheme.headlineSmall,
              ),
            ),
            ?widget.listenButton,
          ],
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(_radius),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSizes.space16,
                children: <Widget>[
                  ProblemStatement(
                    sentence: widget.question.sentence,
                    languageCode: widget.languageCode,
                    recordingKey: widget.question.recordingKey,
                    isCompact: _step != ProblemStep.listen,
                  ),
                  Text(
                    context.l10n.quizProblemStepCounter(
                      _stepIndex + 1,
                      _steps.length,
                    ),
                    style: textTheme.labelLarge?.copyWith(
                      color: context.palette.mutedText,
                    ),
                  ),
                  Text(_instruction(context), style: textTheme.titleMedium),
                  if (_step != ProblemStep.listen)
                    BarModelView(
                      picture: _model,
                      placed: _placed,
                      showsAnswer: _isComputed || _step == ProblemStep.check,
                      wrongRole: _wrongRole,
                      onSlotTap: _step == ProblemStep.model ? _placeOn : null,
                    ),
                  if (_showsTryAgain)
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        context.l10n.quizProblemTryAgain,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(
                          color: context.feedbackPalette.wrong,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  if (_step == ProblemStep.check)
                    Text(_model.check, style: textTheme.titleLarge),
                ],
              ),
            ),
          ),
        ),
        ..._choices(context),
        if (_step == ProblemStep.listen || _step == ProblemStep.check)
          DepthButton(
            label: _step == ProblemStep.listen
                ? context.l10n.quizProblemListened
                : context.l10n.quizProblemChecked,
            onPressed: _goToNextStep,
          ),
      ],
    );
  }

  String _instruction(BuildContext context) {
    return switch (_step) {
      ProblemStep.listen => context.l10n.quizProblemStepListen,
      ProblemStep.model => context.l10n.quizProblemStepModel,
      ProblemStep.operation => context.l10n.quizProblemStepOperation,
      ProblemStep.compute => context.l10n.quizProblemStepCompute,
      ProblemStep.check => context.l10n.quizProblemStepCheck,
    };
  }

  List<Widget> _choices(BuildContext context) {
    switch (_step) {
      case ProblemStep.model:
        return <Widget>[
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSizes.space12,
            runSpacing: AppSizes.space12,
            children: <Widget>[
              for (int index = 0; index < _tiles.length; index++)
                if (!_usedTiles.contains(index))
                  _ChoiceButton(
                    key: ValueKey<String>('tile-$index'),
                    label: '${_tiles[index]}',
                    semanticLabel: '${_tiles[index]}',
                    state: _selectedTile == index
                        ? _ChoiceState.selected
                        : _ChoiceState.none,
                    onTap: () => _selectTile(index),
                  ),
            ],
          ),
          Text(
            context.l10n.quizProblemPickNumberFirst,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.palette.mutedText,
            ),
          ),
        ];
      case ProblemStep.operation:
        return <Widget>[
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSizes.space12,
            runSpacing: AppSizes.space12,
            children: <Widget>[
              for (final OperatorAnswer answer in OperatorAnswer.all)
                _ChoiceButton(
                  key: ValueKey<String>('operator-${answer.operator.name}'),
                  label: <PromptToken>[
                    OperatorToken(answer.operator),
                  ].toDisplayText(),
                  semanticLabel: <PromptToken>[
                    OperatorToken(answer.operator),
                  ].toSpokenText(context.l10n),
                  state: _wrongOperators.contains(answer.operator)
                      ? _ChoiceState.wrong
                      : _ChoiceState.none,
                  onTap: _wrongOperators.contains(answer.operator)
                      ? null
                      : () => _pickOperator(answer.operator),
                ),
            ],
          ),
        ];
      case ProblemStep.compute:
        return <Widget>[
          Text(
            _calculationStart(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSizes.space12,
            runSpacing: AppSizes.space12,
            children: <Widget>[
              for (final Answer choice in widget.question.choices)
                if (choice is NumberAnswer)
                  _ChoiceButton(
                    key: ValueKey<String>('number-${choice.value}'),
                    label: '${choice.value}',
                    semanticLabel: '${choice.value}',
                    state: _wrongNumbers.contains(choice.value)
                        ? _ChoiceState.wrong
                        : _ChoiceState.none,
                    onTap: _wrongNumbers.contains(choice.value)
                        ? null
                        : () => _pickNumber(choice.value),
                  ),
            ],
          ),
        ];
      case ProblemStep.listen:
      case ProblemStep.check:
        return const <Widget>[];
    }
  }

  /// `12 − 5 =` with the result still to pick.
  String _calculationStart() {
    final List<PromptToken> tokens = _model.calculation;
    return '${tokens.take(4).toList().toDisplayText()} ?';
  }
}

enum _ChoiceState { none, selected, wrong }

/// A big number or sign to touch; once wrong it turns red with a cross, so
/// the meaning never relies on color alone.
class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    super.key,
    required this.label,
    required this.semanticLabel,
    required this.state,
    required this.onTap,
  });

  static const double _size = 64;

  final String label;
  final String semanticLabel;
  final _ChoiceState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final AppFeedbackPalette feedback = context.feedbackPalette;
    final bool isWrong = state == _ChoiceState.wrong;
    final bool isSelected = state == _ChoiceState.selected;
    return Semantics(
      button: true,
      enabled: onTap != null,
      selected: isSelected,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: isWrong
            ? feedback.wrong
            : isSelected
            ? colors.primary
            : context.palette.tint,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: _size,
              minHeight: _size,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.space16,
                vertical: AppSizes.space8,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSizes.space4,
                children: <Widget>[
                  if (isWrong)
                    Icon(Icons.close_rounded, color: colors.onPrimary),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isWrong || isSelected
                          ? colors.onPrimary
                          : context.palette.primaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

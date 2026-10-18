import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/extensions/prompt_reading.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/question_pair.dart';
import 'package:kid_matix/core/widgets/help_audio_button.dart';
import 'package:kid_matix/core/widgets/word_picture/word_picture_view.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/answer_feedback.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/multiple_choice_answers.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_answer_button.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_hint_box.dart';

/// A match-pairs question: the title, the pairs found, the operations on
/// the left, their results on the right and the hint.
///
/// The player taps one side then the other, in any order. A right pair
/// turns green and stays; a wrong one shakes, counts as a mistake on the
/// operation's item, and the player tries again. Once every pair is
/// found, [onMatched] gets a [PairsAnswer] naming the items missed; the
/// quiz judges it like any other answer.
class MatchPairsAnswers extends StatefulWidget {
  /// Creates the board of [pairs], with [results] in display order.
  const MatchPairsAnswers({
    required this.pairs,
    required this.results,
    required this.onMatched,
    this.listenButton,
    super.key,
  });

  /// Pairs to find, in the display order of their operations.
  final List<QuestionPair> pairs;

  /// Results of [pairs], in display order.
  final List<Answer> results;

  /// Called once every pair is found; `null` once the answer is judged,
  /// which shows every pair found.
  final ValueChanged<Answer>? onMatched;

  /// The listen button, at the right of the title, or `null` when no
  /// voice can read the question.
  final Widget? listenButton;

  @override
  State<MatchPairsAnswers> createState() => _MatchPairsAnswersState();
}

/// Side of a button: the operations or the results.
enum _Side { operation, result }

/// A button of the board.
typedef _Pick = ({_Side side, int index});

/// What a button of the board shows and does.
typedef _ButtonData = ({
  String label,
  Widget? picture,
  String semanticLabel,
  AnswerFeedback feedback,
  bool isSelected,
  bool isShaking,
  VoidCallback? onTap,
});

class _MatchPairsAnswersState extends State<MatchPairsAnswers>
    with SingleTickerProviderStateMixin {
  static const Duration _shakeTime = Duration(milliseconds: 450);

  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: _shakeTime,
  )..addStatusListener(_onShakeStatus);
  final Set<String> _found = <String>{};
  final Set<String> _missed = <String>{};
  _Pick? _selected;
  _Pick? _wrong;

  bool get _isJudged => widget.onMatched == null;

  /// Whether the board ties words to their drawings (lot F28) rather than
  /// operations to their results.
  bool get _isWordBoard => widget.pairs.first.operation is WordAnswer;

  /// Key of the word of the button touched, on a board of words.
  String? get _selectedWordKey {
    final _Pick? selected = _selected;
    if (!_isWordBoard || selected == null) return null;
    return switch (_pairOf(selected).operation) {
      WordAnswer(:final String wordKey) => wordKey,
      _ => null,
    };
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  void _onShakeStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() => _wrong = null);
    }
  }

  QuestionPair _pairOf(_Pick pick) {
    return switch (pick.side) {
      _Side.operation => widget.pairs[pick.index],
      _Side.result => widget.pairs.firstWhere(
        (QuestionPair pair) => pair.result == widget.results[pick.index],
      ),
    };
  }

  void _onTap(_Pick pick) {
    final _Pick? selected = _selected;
    if (selected == null || selected.side == pick.side) {
      setState(() => _selected = pick);
      return;
    }
    final QuestionPair tapped = _pairOf(pick);
    final QuestionPair first = _pairOf(selected);
    if (tapped == first) return _match(tapped);
    final QuestionPair operation = pick.side == _Side.operation
        ? tapped
        : first;
    setState(() {
      _missed.add(operation.itemKey);
      _wrong = pick;
    });
    _shake.forward(from: 0);
  }

  void _match(QuestionPair pair) {
    setState(() {
      _found.add(pair.itemKey);
      _selected = null;
    });
    if (_found.length == widget.pairs.length) {
      widget.onMatched?.call(PairsAnswer(missedItemKeys: _missed));
    }
  }

  bool _isFound(_Pick pick) =>
      _isJudged || _found.contains(_pairOf(pick).itemKey);

  @override
  Widget build(BuildContext context) {
    final int foundCount = _isJudged ? widget.pairs.length : _found.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: _isWordBoard ? AppSizes.space8 : AppSizes.space16,
      children: <Widget>[
        _Title(
          title: _isWordBoard
              ? context.l10n.quizWordMatchTitle
              : context.l10n.quizMatchPairsTitle,
          isSentence: _isWordBoard,
          foundCount: foundCount,
          total: widget.pairs.length,
          listenButton: widget.listenButton,
        ),
        Expanded(
          child: _PairGrid(
            rowCount: widget.pairs.length,
            shake: _shake,
            dataOf: (_Pick pick) => _dataOf(context, pick),
          ),
        ),
        if (_selectedWordKey case final String wordKey)
          Center(
            child: HelpAudioButton(
              key: ValueKey<String>(wordKey),
              wordKey: wordKey,
            ),
          ),
        if (!_isJudged)
          Semantics(
            liveRegion: true,
            child: QuizHintBox(hint: _hintOf(context)),
          ),
      ],
    );
  }

  String _hintOf(BuildContext context) {
    final _Pick? selected = _selected;
    if (selected == null) {
      return _isWordBoard
          ? context.l10n.quizWordMatchHintStart
          : context.l10n.quizMatchPairsHintStart;
    }
    final QuestionPair pair = _pairOf(selected);
    if (_isWordBoard) {
      return switch (selected.side) {
        _Side.operation => context.l10n.quizWordMatchHintPicture(
          MultipleChoiceAnswers.describeAnswer(pair.operation),
        ),
        _Side.result => context.l10n.quizWordMatchHintWord,
      };
    }
    return switch (selected.side) {
      _Side.operation => context.l10n.quizMatchPairsHintResult(
        MultipleChoiceAnswers.describeAnswer(pair.operation),
      ),
      _Side.result => context.l10n.quizMatchPairsHintOperation(
        MultipleChoiceAnswers.describeAnswer(pair.result),
      ),
    };
  }

  _ButtonData _dataOf(BuildContext context, _Pick pick) {
    final Answer answer = pick.side == _Side.operation
        ? widget.pairs[pick.index].operation
        : widget.results[pick.index];
    final bool isFound = _isFound(pick);
    final bool isWrong = _wrong == pick;
    final String spoken = switch (answer) {
      OperationAnswer(:final operation) => operation.toSpokenText(
        context.l10n,
      ),
      _ => MultipleChoiceAnswers.describeAnswer(answer),
    };
    // The right side of a word board is the drawing of the word.
    final Widget? picture = pick.side == _Side.result && answer is WordAnswer
        ? WordPictureView(wordKey: answer.wordKey)
        : null;
    return (
      label: picture == null
          ? MultipleChoiceAnswers.describeAnswer(answer)
          : '',
      picture: picture,
      semanticLabel: isFound
          ? context.l10n.quizMatchPairsFound(spoken)
          : spoken,
      isSelected: _selected == pick,
      feedback: isFound
          ? AnswerFeedback.right
          : isWrong
          ? AnswerFeedback.wrong
          : AnswerFeedback.none,
      isShaking: isWrong && !MediaQuery.disableAnimationsOf(context),
      onTap: isFound || _isJudged ? null : () => _onTap(pick),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    required this.title,
    required this.isSentence,
    required this.foundCount,
    required this.total,
    required this.listenButton,
  });

  final String title;
  final bool isSentence;
  final int foundCount;
  final int total;
  final Widget? listenButton;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      spacing: AppSizes.space8,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSizes.space4,
            children: <Widget>[
              // The title of the words is a sentence: a smaller type keeps
              // two lines of it, and the four rows, on a small phone.
              Text(
                title,
                style: isSentence
                    ? textTheme.titleLarge
                    : textTheme.headlineSmall,
              ),
              Semantics(
                liveRegion: true,
                child: Text(
                  context.l10n.quizMatchPairsProgress(foundCount, total),
                  style: textTheme.labelLarge?.copyWith(
                    color: context.palette.mutedText,
                  ),
                ),
              ),
            ],
          ),
        ),
        ?listenButton,
      ],
    );
  }
}

/// Rows of an operation and a result, as tall as the room allows.
class _PairGrid extends StatelessWidget {
  const _PairGrid({
    required this.rowCount,
    required this.shake,
    required this.dataOf,
  });

  static const double _rowGap = 10;
  static const double _columnGap = 28;
  static const double _maxHeight = 88;
  static const double _minHeight = 48;

  final int rowCount;
  final Animation<double> shake;
  final _ButtonData Function(_Pick pick) dataOf;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double room =
            (constraints.maxHeight - _rowGap * (rowCount - 1)) / rowCount;
        final double height = room.clamp(_minHeight, _maxHeight);
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: _rowGap,
          children: <Widget>[
            for (int index = 0; index < rowCount; index++)
              SizedBox(
                height: height,
                child: Row(
                  spacing: _columnGap,
                  children: <Widget>[
                    for (final _Side side in _Side.values)
                      Expanded(
                        child: _PairButton(
                          data: dataOf((side: side, index: index)),
                          height: height,
                          shake: shake,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

/// A button of the board, shaking after a wrong pairing.
class _PairButton extends StatelessWidget {
  const _PairButton({
    required this.data,
    required this.height,
    required this.shake,
  });

  final _ButtonData data;
  final double height;
  final Animation<double> shake;

  @override
  Widget build(BuildContext context) {
    return _Shaking(
      animation: shake,
      isShaking: data.isShaking,
      child: QuizAnswerButton(
        label: data.label,
        semanticLabel: data.semanticLabel,
        isSelected: data.isSelected,
        feedback: data.feedback,
        height: height,
        onTap: data.onTap,
        child: data.picture,
      ),
    );
  }
}

/// Shakes [child] side to side while [isShaking].
class _Shaking extends StatelessWidget {
  const _Shaking({
    required this.animation,
    required this.isShaking,
    required this.child,
  });

  static const double _amplitude = 8;
  static const int _swings = 3;

  final Animation<double> animation;
  final bool isShaking;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isShaking) return child;
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (BuildContext context, Widget? child) {
        final double progress = animation.value;
        final double offset =
            math.sin(progress * math.pi * 2 * _swings) *
            _amplitude *
            (1 - progress);
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
    );
  }
}

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/widgets/listen_button.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/question_reading_cubit.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/question_reading_state.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/question_card.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_labels.dart';

/// The question card of a screen outside the quiz that reads its question
/// aloud, such as the placement test: the same card and the same sentence
/// as in a quiz, with the « Écouter » button.
///
/// The reading itself is the job of the enclosing [QuestionReadingCubit]
/// (see `QuizPages.buildQuestionCard`); this card says the sentence of its
/// question and draws the button the Cubit allows.
class ReadableQuestionCard extends StatelessWidget {
  /// Creates the card of [question] in [domainId]; [typedDigits] stand in
  /// place of its blank.
  const ReadableQuestionCard({
    required this.question,
    required this.domainId,
    required this.domains,
    this.typedDigits,
    super.key,
  });

  /// Question asked.
  final Question question;

  /// Learning domain of the question.
  final String domainId;

  /// Registered learning domains.
  final DomainRegistry domains;

  /// Digits typed in place of the blank, if any.
  final String? typedDigits;

  @override
  Widget build(BuildContext context) {
    final QuizLabels labels = QuizLabels(domains: domains, l10n: context.l10n);
    final String spoken = labels.speakQuestion(question, domainId);
    return _QuestionShown(
      question: question,
      spoken: spoken,
      child: BlocBuilder<QuestionReadingCubit, QuestionReadingState>(
        builder: (BuildContext context, QuestionReadingState state) {
          return QuestionCard(
            label: labels.describeQuestion(question, domainId),
            prompt: question.prompt,
            picture: question.picture,
            spokenText: spoken,
            blankText: typedDigits,
            listenButton: state.canRead
                ? ListenButton(
                    isSpeaking: state.isSpeaking,
                    onPressed: context.read<QuestionReadingCubit>().toggle,
                  )
                : null,
          );
        },
      ),
    );
  }
}

/// Tells the Cubit each time a new question appears: a lifecycle hook with
/// no state of its own besides the question it last announced.
class _QuestionShown extends StatefulWidget {
  const _QuestionShown({
    required this.question,
    required this.spoken,
    required this.child,
  });

  final Question question;
  final String spoken;
  final Widget child;

  @override
  State<_QuestionShown> createState() => _QuestionShownState();
}

class _QuestionShownState extends State<_QuestionShown> {
  Question? _announced;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _announce();
  }

  @override
  void didUpdateWidget(_QuestionShown oldWidget) {
    super.didUpdateWidget(oldWidget);
    _announce();
  }

  void _announce() {
    if (identical(_announced, widget.question)) return;
    _announced = widget.question;
    final QuestionReadingCubit cubit = context.read<QuestionReadingCubit>();
    final String text = widget.spoken;
    final String languageCode = Localizations.localeOf(context).languageCode;
    // Out of the build phase: the Cubit may change the button at once.
    scheduleMicrotask(() {
      if (!cubit.isClosed) {
        unawaited(cubit.show(text: text, interfaceLanguageCode: languageCode));
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

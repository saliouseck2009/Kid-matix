import 'package:kid_matix/core/quiz/question_type.dart';

/// A question type that only makes the child discover an item: it is
/// recorded as a presentation of the item, never as an answer, so it moves
/// no box of the spaced repetition.
abstract interface class DiscoveryQuestionType implements QuestionType {}

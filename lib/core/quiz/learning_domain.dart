import 'package:kid_matix/core/quiz/item_help.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/services/random_source.dart';

/// A subject to learn, such as multiplication.
///
/// The quiz, the mastery engine and the rewards know only this contract,
/// so a new domain is a new module and nothing else changes.
abstract interface class LearningDomain {
  /// Stable identifier, such as `multiplication`.
  String get id;

  /// Units in their natural order.
  List<LearningUnit> get units;

  /// Units in the order of the learning path.
  List<LearningUnit> get path;

  /// Identifiers of the question types the domain can build.
  List<String> get questionTypeIds;

  /// Identifiers of the question types fit for [item], in the order of
  /// [questionTypeIds]: every one for a multiplication fact, only those
  /// that make sense for the item in other domains (objects to count are
  /// not compared). Never empty.
  List<String> questionTypeIdsOf(LearningItem item);

  /// Returns the item of [key], or `null` when the domain has none.
  LearningItem? findItem(String key);

  /// Returns the unit of [key], or `null` when the domain has none.
  LearningUnit? findUnit(String key);

  /// Relative chance of [item] when items are drawn at random: an item of
  /// weight 2 comes out twice as often as an item of weight 1. Items too
  /// easy outside their own unit get a lower weight.
  int drawWeightOf(LearningItem item);

  /// A related fact recalled after a mistake, such as 8 x 7 for 7 x 8; it
  /// is only described, never drawn as a question. `null` when the item
  /// has none.
  LearningItem? mirrorOf(LearningItem item);

  /// The help card of [item], shown after two mistakes on it in a quiz.
  ItemHelp helpOf(LearningItem item);

  /// The whole fact of [item] with its answer, such as `5 × 8 = 40`, shown
  /// in the results among the facts to review.
  List<PromptToken> describeItem(LearningItem item);

  /// The name of the recordings of [item] in the audio packs, such as
  /// `il_reste` for the word `word:il_reste`; `null` when the domain has
  /// none, which is the case of every domain but the math words.
  String? recordingKeyOf(LearningItem item);

  /// The language the questions of the domain are written in, such as
  /// `fr` for the math words, which the voice must speak whatever the
  /// language of the interface; `null` to follow the interface.
  String? get contentLanguageCode;

  /// Builds a question of type [questionTypeId] about [item], drawing
  /// choices and positions from [random].
  ///
  /// [questionTypeId] must be one of [questionTypeIds] and [item] one of
  /// the domain's items.
  Question buildQuestion({
    required LearningItem item,
    required String questionTypeId,
    required RandomSource random,
  });
}

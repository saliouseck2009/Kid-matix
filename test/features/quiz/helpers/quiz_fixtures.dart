import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/question_generator.dart';
import 'package:kid_matix/core/quiz/question_type_registry.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/question_types/version_one_question_types.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/core/services/id_generator.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_mode.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_status.dart';
import 'package:kid_matix/features/quiz/domain/repositories/quiz_session_repository.dart';
import 'package:kid_matix/features/quiz/domain/usecases/build_quiz_params.dart';
import 'package:kid_matix/features/quiz/domain/usecases/build_quiz_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/submit_answer_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/data_state_test_extension.dart';

/// Test double of [QuizSessionRepository].
final class MockQuizSessionRepository extends Mock
    implements QuizSessionRepository {}

/// [Clock] stopped at a time the test sets.
final class FakeClock implements Clock {
  /// Creates a clock stopped at [now].
  FakeClock(this.now_);

  /// Current time; tests move it forward.
  DateTime now_;

  @override
  DateTime now() => now_;
}

/// [IdGenerator] that always returns [id].
final class FixedIdGenerator implements IdGenerator {
  /// Creates the generator.
  const FixedIdGenerator(this.id);

  /// Identifier returned.
  final String id;

  @override
  String generateId() => id;
}

/// When the test quizzes start.
final DateTime quizStart = DateTime(2026, 10, 9, 17);

/// Lets mocktail match any session; call it in `setUpAll`.
void registerQuizFallbacks() {
  registerFallbackValue(
    QuizSessionEntity(
      id: '',
      profileId: '',
      domainId: '',
      mode: QuizMode.freeTraining,
      status: QuizSessionStatus.completed,
      startedAt: quizStart,
      duration: Duration.zero,
      questionCount: 0,
      correctCount: 0,
    ),
  );
}

/// Registries holding the multiplication domain and the 1.0 types.
DomainRegistry buildDomainRegistry() {
  return DomainRegistry()..register(MultiplicationDomain());
}

/// Registry of the question types of version 1.0.
QuestionTypeRegistry buildQuestionTypeRegistry() {
  final QuestionTypeRegistry registry = QuestionTypeRegistry();
  versionOneQuestionTypes.forEach(registry.register);
  return registry;
}

/// Keys of the table of [table], multiplier 1 first.
List<String> tableKeys(int table) {
  return <String>[
    for (int multiplier = 1; multiplier <= 10; multiplier++)
      'mul:${table}x$multiplier',
  ];
}

/// [BuildQuizUseCase] over the real registries and a seeded draw.
BuildQuizUseCase buildQuizUseCase({int seed = 5}) {
  return BuildQuizUseCase(
    domains: buildDomainRegistry(),
    generator: const QuestionGenerator(),
    random: DartRandomSource(seed: seed),
    idGenerator: const FixedIdGenerator('session-1'),
    clock: FakeClock(quizStart),
  );
}

/// [SubmitAnswerUseCase] over the real registries and a seeded draw.
SubmitAnswerUseCase buildSubmitAnswerUseCase({int seed = 5}) {
  return SubmitAnswerUseCase(
    questionTypes: buildQuestionTypeRegistry(),
    domains: buildDomainRegistry(),
    generator: const QuestionGenerator(),
    random: DartRandomSource(seed: seed),
  );
}

/// Parameters of a free training quiz on [itemKeys] in typed answers.
BuildQuizParams buildParams({
  required List<String> itemKeys,
  List<String> questionTypeIds = const <String>[QuestionTypeIds.typedAnswer],
  Duration? timeLimit = const Duration(seconds: 10),
}) {
  return BuildQuizParams(
    profileId: 'profile-1',
    domainId: MultiplicationDomain.domainId,
    mode: QuizMode.freeTraining,
    itemKeys: itemKeys,
    questionTypeIds: questionTypeIds,
    timeLimit: timeLimit,
  );
}

/// A built run of typed-answer questions on [itemKeys].
Future<QuizRun> buildRun(List<String> itemKeys) async {
  return (await buildQuizUseCase()(params: buildParams(itemKeys: itemKeys)))
      .requireData;
}

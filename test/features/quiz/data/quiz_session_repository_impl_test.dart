import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/app_migrations.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/quiz/data/datasources/quiz_session_local_data_source_impl.dart';
import 'package:kid_matix/features/quiz/data/models/quiz_answer_local_model.dart';
import 'package:kid_matix/features/quiz/data/models/quiz_session_local_model.dart';
import 'package:kid_matix/features/quiz/data/repositories/quiz_session_repository_impl.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_answer_entity.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_result_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_status.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../helpers/quiz_fixtures.dart';

QuizSessionEntity _buildSession({String profileId = 'p1'}) {
  return QuizSessionEntity(
    id: 's1',
    profileId: profileId,
    domainId: 'multiplication',
    mode: QuizMode.freeTraining,
    status: QuizSessionStatus.completed,
    startedAt: quizStart,
    duration: const Duration(seconds: 75),
    questionCount: 2,
    correctCount: 1,
  );
}

const List<QuizAnswerEntity> _answers = <QuizAnswerEntity>[
  QuizAnswerEntity(
    itemKey: 'mul:5x7',
    questionTypeId: 'multipleChoice',
    isCorrect: true,
    isTimedOut: false,
    isRetry: false,
    answerTime: Duration(milliseconds: 2400),
  ),
  QuizAnswerEntity(
    itemKey: 'mul:5x8',
    questionTypeId: 'typedAnswer',
    isCorrect: false,
    isTimedOut: true,
    isRetry: false,
    answerTime: Duration(seconds: 10),
  ),
];

void main() {
  late AppDatabase appDatabase;
  late TableChangeBus changeBus;
  late QuizSessionRepositoryImpl repository;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    appDatabase = AppDatabase(
      databaseFactory: databaseFactoryFfi,
      resolvePath: () async => inMemoryDatabasePath,
      migrationRunner: MigrationRunner(migrations: appMigrations),
    );
    await (await appDatabase.database).insert('profile', <String, Object?>{
      'id': 'p1',
      'nickname': 'Awa',
      'normalized_nickname': 'awa',
      'avatar': 'avatar1',
      'color': 'violet',
      'created_at': 0,
      'updated_at': 0,
    });
    changeBus = TableChangeBus();
    repository = QuizSessionRepositoryImpl(
      sessions: QuizSessionLocalDataSourceImpl(database: appDatabase),
      clock: FakeClock(quizStart),
      changeBus: changeBus,
    );
  });

  tearDown(() async {
    await changeBus.dispose();
    await appDatabase.close();
  });

  group('QuizSessionRepositoryImpl', () {
    test('saves the session and its answers in order', () async {
      // Act
      final DataState<void> actualState = await repository.saveSession(
        session: _buildSession(),
        answers: _answers,
      );
      // Assert
      expect(actualState, isA<DataSuccess<void>>());
      final Database database = await appDatabase.database;
      final QuizSessionEntity actualSession = QuizSessionLocalModel.fromJson(
        (await database.query('quiz_session')).single,
      ).toEntity();
      final List<QuizAnswerEntity> actualAnswers =
          (await database.query('quiz_answer', orderBy: 'position'))
              .map(
                (Map<String, Object?> row) =>
                    QuizAnswerLocalModel.fromJson(row).toEntity(),
              )
              .toList();
      expect(actualSession, _buildSession());
      expect(actualAnswers, _answers);
    });
    test('tells the watchers that the sessions changed', () async {
      // Arrange
      final Future<String> actualChange = changeBus
          .watchTable(table: 'quiz_session')
          .first;
      // Act
      await repository.saveSession(session: _buildSession(), answers: _answers);
      // Assert
      expect(await actualChange, 'quiz_session');
    });
    test('writes nothing when the session cannot be saved', () async {
      // Act
      final DataState<void> actualState = await repository.saveSession(
        session: _buildSession(profileId: 'unknown'),
        answers: _answers,
      );
      // Assert
      expect(actualState.exceptionOrNull, isA<CacheException>());
      final Database database = await appDatabase.database;
      expect(await database.query('quiz_answer'), isEmpty);
    });
    test('reads a saved session with its answers', () async {
      // Arrange
      await repository.saveSession(session: _buildSession(), answers: _answers);
      // Act
      final QuizResultEntity actualResult = (await repository.getResult(
        sessionId: 's1',
      )).requireData;
      // Assert
      expect(actualResult.session, _buildSession());
      expect(actualResult.answers, _answers);
    });
    test('fails to read a session that does not exist', () async {
      // Act
      final AppException? actualException = (await repository.getResult(
        sessionId: 'missing',
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<NotFoundException>());
    });
  });
}

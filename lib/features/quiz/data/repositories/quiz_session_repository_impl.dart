import 'dart:developer';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/quiz/data/datasources/quiz_session_local_data_source.dart';
import 'package:kid_matix/features/quiz/data/datasources/quiz_tables.dart';
import 'package:kid_matix/features/quiz/data/models/quiz_answer_local_model.dart';
import 'package:kid_matix/features/quiz/data/models/quiz_session_local_model.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_answer_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_result_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_entity.dart';
import 'package:kid_matix/features/quiz/domain/repositories/quiz_session_repository.dart';
import 'package:sqflite/sqflite.dart';

/// [QuizSessionRepository] over the local database.
///
/// After each write it tells the [TableChangeBus] that the `quiz_session`
/// table changed.
final class QuizSessionRepositoryImpl implements QuizSessionRepository {
  /// Creates the repository.
  const QuizSessionRepositoryImpl({
    required this._sessions,
    required this._clock,
    required this._changeBus,
  });

  static const String _logName = 'quiz';

  final QuizSessionLocalDataSource _sessions;
  final Clock _clock;
  final TableChangeBus _changeBus;

  @override
  Future<DataState<void>> saveSession({
    required QuizSessionEntity session,
    required List<QuizAnswerEntity> answers,
  }) async {
    final DateTime now = _clock.now();
    try {
      final List<String> hookTables = await _sessions.insertSession(
        session: QuizSessionLocalModel.fromEntity(
          session: session,
          updatedAt: now,
        ),
        answers: <QuizAnswerLocalModel>[
          for (int index = 0; index < answers.length; index++)
            QuizAnswerLocalModel.fromEntity(
              answer: answers[index],
              sessionId: session.id,
              position: index + 1,
              updatedAt: now,
            ),
        ],
      );
      _changeBus.notifyChanged(table: QuizTables.session);
      for (final String table in hookTables.toSet()) {
        _changeBus.notifyChanged(table: table);
      }
      return const DataSuccess<void>(null);
    } on DatabaseException catch (error, stackTrace) {
      log(
        'Session not saved',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return DataFailed<void>(CacheException(message: error.toString()));
    }
  }

  @override
  Future<DataState<QuizResultEntity>> getResult({
    required String sessionId,
  }) async {
    try {
      final QuizSessionLocalModel? session = await _sessions.getSession(
        sessionId: sessionId,
      );
      if (session == null) {
        return DataFailed<QuizResultEntity>(
          NotFoundException(message: 'No session $sessionId.'),
        );
      }
      final List<QuizAnswerLocalModel> answers = await _sessions.getAnswers(
        sessionId: sessionId,
      );
      return DataSuccess<QuizResultEntity>(
        QuizResultEntity(
          session: session.toEntity(),
          answers: answers
              .map((QuizAnswerLocalModel answer) => answer.toEntity())
              .toList(),
        ),
      );
    } on DatabaseException catch (error, stackTrace) {
      log(
        'Result not read',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return DataFailed<QuizResultEntity>(
        CacheException(message: error.toString()),
      );
    }
  }
}

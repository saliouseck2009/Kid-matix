import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/features/quiz/data/datasources/quiz_session_local_data_source.dart';
import 'package:kid_matix/features/quiz/data/datasources/quiz_tables.dart';
import 'package:kid_matix/features/quiz/data/models/quiz_answer_local_model.dart';
import 'package:kid_matix/features/quiz/data/models/quiz_session_local_model.dart';
import 'package:sqflite/sqflite.dart';

/// [QuizSessionLocalDataSource] over the app database.
final class QuizSessionLocalDataSourceImpl
    implements QuizSessionLocalDataSource {
  /// Creates the data source over [database].
  const QuizSessionLocalDataSourceImpl({required this._database});

  final AppDatabase _database;

  @override
  Future<void> insertSession({
    required QuizSessionLocalModel session,
    required List<QuizAnswerLocalModel> answers,
  }) async {
    final Database database = await _database.database;
    await database.transaction((Transaction transaction) async {
      await transaction.insert(QuizTables.session, session.toJson());
      final Batch batch = transaction.batch();
      for (final QuizAnswerLocalModel answer in answers) {
        batch.insert(QuizTables.answer, answer.toJson());
      }
      await batch.commit(noResult: true);
    });
  }
}

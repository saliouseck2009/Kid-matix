import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/features/classroom/data/models/assessment_result_file_model.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_result.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_answer.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';
import 'package:kid_matix/features/classroom/domain/entities/qr_results.dart';
import 'package:kid_matix/features/classroom/domain/repositories/qr_results_codec.dart';

/// [QrResultsCodec], format `kidmatix-qr` version 1:
///
/// `KMXQ1.` then, in base64url, the gzip of this JSON in UTF-8:
/// `{"c": classroomId, "s": [sessions], "r": [results]}`, where a session
/// is `[id, pupilId, domainId, startedAt ms, duration ms, questions,
/// right, [[position, itemKey, right 0|1, retry 0|1]...]]` and a result
/// is written as in the class files (`AssessmentResultFileModel`).
///
/// A newer app writes `KMXQ2.`…; this one refuses it as too new.
final class QrResultsCodecImpl implements QrResultsCodec {
  /// Creates the codec.
  const QrResultsCodecImpl();

  /// Start of every code, before its version.
  static const String marker = 'KMXQ';

  /// Version written by this app.
  static const int version = 1;

  static const int _sessionLength = 8;
  static const int _answerLength = 4;

  @override
  String encode(QrResults results) {
    final String json = jsonEncode(<String, Object?>{
      'c': results.classroomId,
      's': results.sessions.map(_sessionRowOf).toList(),
      'r': results.results
          .map((AssessmentResult r) => AssessmentResultFileModel.fromEntity(r))
          .map((AssessmentResultFileModel m) => m.toJson())
          .toList(),
    });
    final List<int> packed = const GZipEncoder().encodeBytes(utf8.encode(json));
    return '$marker$version.${base64Url.encode(packed)}';
  }

  @override
  QrResults decode(String text) {
    final int dot = text.indexOf('.');
    final int? codeVersion = text.startsWith(marker) && dot > marker.length
        ? int.tryParse(text.substring(marker.length, dot))
        : null;
    if (codeVersion == null || codeVersion < 1) {
      throw const InvalidFileException(message: 'Not a results code.');
    }
    if (codeVersion > version) {
      throw UnsupportedVersionException(message: 'Results code v$codeVersion.');
    }
    try {
      return _resultsOf(_jsonOf(text.substring(dot + 1)));
    } on FormatException catch (error) {
      throw InvalidFileException(message: error.message);
    } on TypeError catch (error) {
      throw InvalidFileException(message: error.toString());
    } on ArgumentError catch (error) {
      throw InvalidFileException(message: error.toString());
    } on Exception catch (error) {
      // A damaged gzip stream.
      throw InvalidFileException(message: error.toString());
    }
  }

  static Map<String, Object?> _jsonOf(String data) {
    final List<int> packed = base64Url.decode(base64Url.normalize(data));
    final Object? json = jsonDecode(
      utf8.decode(const GZipDecoder().decodeBytes(packed)),
    );
    if (json is! Map<String, Object?>) {
      throw const FormatException('Not a JSON object.');
    }
    return json;
  }

  static QrResults _resultsOf(Map<String, Object?> json) {
    return QrResults(
      classroomId: json['c']! as String,
      sessions: <PracticeSession>[
        for (final Object? row in json['s']! as List<Object?>)
          _sessionOf(json['c']! as String, row! as List<Object?>),
      ],
      results: <AssessmentResult>[
        for (final Object? row in json['r']! as List<Object?>)
          AssessmentResultFileModel.fromJson(
            row! as Map<String, Object?>,
          ).toEntity(),
      ],
    );
  }

  static List<Object> _sessionRowOf(PracticeSession session) {
    return <Object>[
      session.id,
      session.pupilId,
      session.domainId,
      session.startedAt.millisecondsSinceEpoch,
      session.duration.inMilliseconds,
      session.questionCount,
      session.correctCount,
      <List<Object>>[
        for (final PracticeAnswer answer in session.answers)
          <Object>[
            answer.position,
            answer.itemKey,
            if (answer.isCorrect) 1 else 0,
            if (answer.isRetry) 1 else 0,
          ],
      ],
    ];
  }

  static PracticeSession _sessionOf(String classroomId, List<Object?> row) {
    if (row.length != _sessionLength) {
      throw const FormatException('Malformed session row.');
    }
    return PracticeSession(
      id: row[0]! as String,
      pupilId: row[1]! as String,
      classroomId: classroomId,
      domainId: row[2]! as String,
      startedAt: DateTime.fromMillisecondsSinceEpoch(row[3]! as int),
      duration: Duration(milliseconds: row[4]! as int),
      questionCount: row[5]! as int,
      correctCount: row[6]! as int,
      answers: <PracticeAnswer>[
        for (final Object? answer in row[7]! as List<Object?>)
          _answerOf(answer! as List<Object?>),
      ],
    );
  }

  static PracticeAnswer _answerOf(List<Object?> row) {
    if (row.length != _answerLength) {
      throw const FormatException('Malformed answer row.');
    }
    return PracticeAnswer(
      position: row[0]! as int,
      itemKey: row[1]! as String,
      isCorrect: row[2] != 0,
      isRetry: row[3] != 0,
    );
  }
}

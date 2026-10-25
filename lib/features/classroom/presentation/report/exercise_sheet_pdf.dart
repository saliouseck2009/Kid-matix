import 'package:kid_matix/core/extensions/domain_naming.dart';
import 'package:kid_matix/core/extensions/prompt_reading.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_exercise_sheet_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/report/report_fonts.dart';
import 'package:kid_matix/features/classroom/presentation/report/report_pdf_parts.dart';
import 'package:kid_matix/l10n/app_localizations.dart';
import 'package:pdf/widgets.dart' as pw;

/// Prints the exercises of a unit (F31-07): name and date, instruction,
/// the exercises in two columns with a blank to fill, then a page of
/// answers for the teacher.
abstract final class ExerciseSheetPdf {
  /// Size of the exercises.
  static const double exerciseSize = 16;

  /// Space under each exercise.
  static const double exerciseGap = 14;

  /// Columns of exercises.
  static const int columns = 2;

  /// What the child fills in.
  static const String blank = '______';

  /// The bytes of the PDF of [sheet].
  static Future<List<int>> build({
    required ExerciseSheet sheet,
    required AppLocalizations l10n,
    required ReportFonts fonts,
  }) {
    final String unit = l10n.unitName(sheet.domainId, sheet.unitKey);
    final pw.Document document = pw.Document(
      theme: fonts.theme,
      title: l10n.printExercisesTitle(unit),
      creator: 'Kid Matix',
    );
    document
      ..addPage(
        pw.MultiPage(
          margin: const pw.EdgeInsets.all(ReportPdfParts.margin),
          build: (pw.Context context) => <pw.Widget>[
            ReportPdfParts.title(l10n.printExercisesTitle(unit)),
            ReportPdfParts.line(l10n.printNameLine),
            ReportPdfParts.line(l10n.printExercisesInstruction),
            pw.SizedBox(height: ReportPdfParts.gap),
            _grid(<String>[
              for (final (int index, Question q) in sheet.questions.indexed)
                _numbered(index, q, blank),
            ], exerciseSize),
          ],
        ),
      )
      ..addPage(
        pw.MultiPage(
          margin: const pw.EdgeInsets.all(ReportPdfParts.margin),
          build: (pw.Context context) => <pw.Widget>[
            ReportPdfParts.heading(l10n.printAnswersTitle(unit)),
            _grid(<String>[
              for (final (int index, Question q) in sheet.questions.indexed)
                _numbered(index, q, _answerOf(q)),
            ], ReportPdfParts.textSize),
          ],
        ),
      );
    return document.save();
  }

  static pw.Widget _grid(List<String> lines, double size) {
    final int perColumn = (lines.length / columns).ceil();
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        for (int column = 0; column < columns; column++)
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                for (final String line
                    in lines.skip(column * perColumn).take(perColumn))
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: exerciseGap),
                    child: pw.Text(line, style: pw.TextStyle(fontSize: size)),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  /// « 3.  7 × 8 = ______ »: the number of the exercise and its prompt,
  /// the blank written [blank].
  static String _numbered(int index, Question question, String blank) {
    return '${index + 1}.  ${question.prompt.toDisplayText(blankText: blank)}';
  }

  static String _answerOf(Question question) {
    return switch (question.expectedAnswer) {
      NumberAnswer(:final int value) => '$value',
      _ => '?',
    };
  }
}

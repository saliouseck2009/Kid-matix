import 'package:kid_matix/core/entities/shared_file.dart';
import 'package:kid_matix/core/entities/word_card.dart';
import 'package:kid_matix/core/extensions/domain_naming.dart';
import 'package:kid_matix/core/extensions/prompt_reading.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_exercise_sheet_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_word_cards_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/report/report_fonts.dart';
import 'package:kid_matix/features/classroom/presentation/report/report_format.dart';
import 'package:kid_matix/features/classroom/presentation/report/report_pdf_parts.dart';
import 'package:kid_matix/l10n/app_localizations.dart';
import 'package:pdf/widgets.dart' as pw;

/// The printable sheets of the teacher area as PDF (F31-07): exercises of
/// a unit with their answers, and the cards of the math words, in French
/// and the help language. A help-language text the owner has not written
/// prints as a blank line to fill in by hand; nothing is ever invented.
final class PrintableFiles {
  /// Creates the maker in the language of [l10n].
  PrintableFiles({
    required this.l10n,
    Future<ReportFonts> Function()? loadFonts,
  }) : _loadFonts = loadFonts ?? ReportFonts.load;

  /// Texts of the app.
  final AppLocalizations l10n;

  final Future<ReportFonts> Function() _loadFonts;

  static const double _exerciseSize = 16;
  static const double _wordSize = 18;
  static const int _columns = 2;
  static const String _blank = '______';

  /// The PDF of [sheet] made on [day]; [helpLanguage] adds its line.
  Future<SharedFile> exerciseSheetOf(
    ExerciseSheet sheet, {
    required DateTime day,
    String? helpLanguage,
  }) async {
    final String unit = l10n.unitName(sheet.domainId, sheet.unitKey);
    final pw.Document document = await _document(
      l10n.printExercisesTitle(unit),
    );
    document
      ..addPage(
        pw.MultiPage(
          margin: const pw.EdgeInsets.all(ReportPdfParts.margin),
          build: (pw.Context context) => <pw.Widget>[
            ReportPdfParts.title(l10n.printExercisesTitle(unit)),
            ReportPdfParts.line(l10n.printNameLine),
            ReportPdfParts.line(l10n.printExercisesInstruction),
            ?_helpLine(helpLanguage, null),
            pw.SizedBox(height: ReportPdfParts.gap),
            _grid(<String>[
              for (final (int index, Question q) in sheet.questions.indexed)
                _numbered(index, q, _blank),
            ], _exerciseSize),
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
    return SharedFile(
      name: ReportFormat(l10n).fileNameOf(
        stem: l10n.printExercisesFileName,
        subject: unit,
        day: day,
        extension: 'pdf',
      ),
      bytes: await document.save(),
      mimeType: SharedFile.pdfType,
    );
  }

  /// The PDF of the word cards of [sheet] made on [day].
  Future<SharedFile> wordCardsOf(
    WordCardSheet sheet, {
    required DateTime day,
  }) async {
    final pw.Document document = await _document(l10n.printWordsTitle);
    document.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(ReportPdfParts.margin),
        build: (pw.Context context) => <pw.Widget>[
          ReportPdfParts.title(l10n.printWordsTitle),
          pw.SizedBox(height: ReportPdfParts.gap),
          pw.Wrap(
            spacing: ReportPdfParts.gap,
            runSpacing: ReportPdfParts.gap,
            children: <pw.Widget>[
              for (final WordCard card in sheet.cards)
                _cardOf(card, sheet.helpLanguage),
            ],
          ),
        ],
      ),
    );
    return SharedFile(
      name: ReportFormat(l10n).fileNameOf(
        stem: l10n.printWordsFileName,
        subject: '',
        day: day,
        extension: 'pdf',
      ),
      bytes: await document.save(),
      mimeType: SharedFile.pdfType,
    );
  }

  Future<pw.Document> _document(String title) async {
    final ReportFonts fonts = await _loadFonts();
    return pw.Document(theme: fonts.theme, title: title, creator: 'Kid Matix');
  }

  pw.Widget _cardOf(WordCard card, String? helpLanguage) {
    const double cardWidth = 250;
    return pw.Container(
      width: cardWidth,
      padding: const pw.EdgeInsets.all(ReportPdfParts.gap),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            card.text,
            style: const pw.TextStyle(
              fontSize: _wordSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          ReportPdfParts.line(card.meaning),
          ReportPdfParts.line(l10n.printWordExample(card.example)),
          ?_helpLine(
            helpLanguage,
            helpLanguage == null ? null : card.helpExplanations[helpLanguage],
          ),
        ],
      ),
    );
  }

  /// « En wolof : » then [text], or a line to write on; nothing without a
  /// help language.
  pw.Widget? _helpLine(String? language, String? text) {
    if (language == null) return null;
    final String label = l10n.printHelpLine(
      l10n.helpAudioLanguageName(language),
    );
    if (text != null && text.isNotEmpty) {
      return ReportPdfParts.line('$label $text');
    }
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 4, bottom: 4),
      child: pw.Row(
        children: <pw.Widget>[
          pw.Text(label),
          pw.SizedBox(width: 4),
          pw.Expanded(
            child: pw.Container(
              height: ReportPdfParts.textSize * 1.6,
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(width: 0.6)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _grid(List<String> lines, double size) {
    final int perColumn = (lines.length / _columns).ceil();
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        for (int column = 0; column < _columns; column++)
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                for (final String line
                    in lines
                        .skip(column * perColumn)
                        .take(
                          perColumn,
                        ))
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 14),
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

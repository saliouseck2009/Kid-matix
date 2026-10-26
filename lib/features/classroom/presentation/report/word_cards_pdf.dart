import 'package:kid_matix/core/entities/word_card.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_word_cards_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/report/report_fonts.dart';
import 'package:kid_matix/features/classroom/presentation/report/report_pdf_parts.dart';
import 'package:kid_matix/l10n/app_localizations.dart';
import 'package:pdf/widgets.dart' as pw;

/// Prints the cards of the math words (F31-07): the word, its meaning and
/// its example in French, then its explanation and its example in the
/// help language when the owner wrote them, else a blank line to fill in
/// by hand. Nothing is ever invented.
abstract final class WordCardsPdf {
  /// Width of a card: two cards side by side on A4.
  static const double cardWidth = 250;

  /// Size of the word.
  static const double wordSize = 18;

  /// Width of the frame of a card.
  static const double frameWidth = 0.8;

  /// Corner radius of a card.
  static const double cornerRadius = 8;

  /// Space between a label and its line.
  static const double labelGap = 4;

  /// Height of a line to write on, in text heights.
  static const double writingLineHeight = 1.6;

  /// Thickness of a line to write on.
  static const double writingLineWidth = 0.6;

  /// The bytes of the PDF of [sheet].
  static Future<List<int>> build({
    required WordCardSheet sheet,
    required AppLocalizations l10n,
    required ReportFonts fonts,
  }) {
    final pw.Document document = pw.Document(
      theme: fonts.theme,
      title: l10n.printWordsTitle,
      creator: 'Kid Matix',
    );
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
                _cardOf(card, sheet.helpLanguage, l10n),
            ],
          ),
        ],
      ),
    );
    return document.save();
  }

  static pw.Widget _cardOf(
    WordCard card,
    String? language,
    AppLocalizations l10n,
  ) {
    return pw.Container(
      width: cardWidth,
      padding: const pw.EdgeInsets.all(ReportPdfParts.gap),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: frameWidth),
        borderRadius: const pw.BorderRadius.all(
          pw.Radius.circular(cornerRadius),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            card.text,
            style: const pw.TextStyle(
              fontSize: wordSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          ReportPdfParts.line(card.meaning),
          ReportPdfParts.line(l10n.printWordExample(card.example)),
          if (language != null) ...<pw.Widget>[
            _helpLine(
              l10n.printHelpLine(l10n.helpAudioLanguageName(language)),
              card.helpExplanations[language],
            ),
            _helpLine(
              l10n.printHelpExample(l10n.helpAudioLanguageName(language)),
              card.helpExamples[language],
            ),
          ],
        ],
      ),
    );
  }

  /// [label] then [text], or a line to write on when it is not written.
  static pw.Widget _helpLine(String label, String? text) {
    if (text != null && text.isNotEmpty) {
      return ReportPdfParts.line('$label $text');
    }
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: labelGap),
      child: pw.Row(
        children: <pw.Widget>[
          pw.Text(label),
          pw.SizedBox(width: labelGap),
          pw.Expanded(
            child: pw.Container(
              height: ReportPdfParts.textSize * writingLineHeight,
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(width: writingLineWidth),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

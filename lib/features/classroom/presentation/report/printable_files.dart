import 'package:kid_matix/core/entities/shared_file.dart';
import 'package:kid_matix/core/extensions/domain_naming.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_exercise_sheet_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_word_cards_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/report/exercise_sheet_pdf.dart';
import 'package:kid_matix/features/classroom/presentation/report/report_fonts.dart';
import 'package:kid_matix/features/classroom/presentation/report/report_format.dart';
import 'package:kid_matix/features/classroom/presentation/report/word_cards_pdf.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// The printable sheets of the teacher area as PDF files to share
/// (F31-07): the exercises of a unit ([ExerciseSheetPdf]) and the cards
/// of the math words ([WordCardsPdf]).
final class PrintableFiles {
  /// Creates the maker in the language of [l10n].
  PrintableFiles({
    required this.l10n,
    Future<ReportFonts> Function()? loadFonts,
  }) : _loadFonts = loadFonts ?? ReportFonts.load;

  /// Texts of the app.
  final AppLocalizations l10n;

  final Future<ReportFonts> Function() _loadFonts;

  /// The PDF of the exercises [sheet] made on [day].
  Future<SharedFile> exerciseSheetOf(
    ExerciseSheet sheet, {
    required DateTime day,
  }) async {
    return SharedFile(
      name: ReportFormat(l10n).fileNameOf(
        stem: l10n.printExercisesFileName,
        subject: l10n.unitName(sheet.domainId, sheet.unitKey),
        day: day,
        extension: 'pdf',
      ),
      bytes: await ExerciseSheetPdf.build(
        sheet: sheet,
        l10n: l10n,
        fonts: await _loadFonts(),
      ),
      mimeType: SharedFile.pdfType,
    );
  }

  /// The PDF of the word cards [sheet] made on [day].
  Future<SharedFile> wordCardsOf(
    WordCardSheet sheet, {
    required DateTime day,
  }) async {
    return SharedFile(
      name: ReportFormat(l10n).fileNameOf(
        stem: l10n.printWordsFileName,
        subject: '',
        day: day,
        extension: 'pdf',
      ),
      bytes: await WordCardsPdf.build(
        sheet: sheet,
        l10n: l10n,
        fonts: await _loadFonts(),
      ),
      mimeType: SharedFile.pdfType,
    );
  }
}

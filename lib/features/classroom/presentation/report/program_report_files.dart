import 'package:kid_matix/core/entities/shared_file.dart';
import 'package:kid_matix/core/extensions/domain_naming.dart';
import 'package:kid_matix/features/classroom/domain/entities/program_report.dart';
import 'package:kid_matix/features/classroom/presentation/report/class_report_files.dart';
import 'package:kid_matix/features/classroom/presentation/report/report_csv.dart';
import 'package:kid_matix/features/classroom/presentation/report/report_fonts.dart';
import 'package:kid_matix/features/classroom/presentation/report/report_format.dart';
import 'package:kid_matix/features/classroom/presentation/report/report_pdf_parts.dart';
import 'package:kid_matix/l10n/app_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Turns a school or program report into its file, anonymous only: one
/// row per class and the total, the same columns in the PDF and the CSV.
final class ProgramReportFiles {
  /// Creates the maker in the language of [l10n].
  ProgramReportFiles({
    required this.l10n,
    Future<ReportFonts> Function()? loadFonts,
  }) : _loadFonts = loadFonts ?? ReportFonts.load;

  /// Texts of the app.
  final AppLocalizations l10n;

  final Future<ReportFonts> Function() _loadFonts;

  ReportFormat get _format => ReportFormat(l10n);

  /// The file of [report] of [kind].
  Future<List<SharedFile>> filesOf(
    ProgramReport report,
    ReportFileKind kind,
  ) async {
    final String name = _format.fileNameOf(
      subject: l10n.classroomProgramFileName,
      day: report.generatedAt,
      extension: kind.name,
      suffix: l10n.classroomReportFileAnonymous,
    );
    return <SharedFile>[
      switch (kind) {
        ReportFileKind.pdf => SharedFile(
          name: name,
          bytes: await _pdfOf(report),
          mimeType: SharedFile.pdfType,
        ),
        ReportFileKind.csv => SharedFile(
          name: name,
          bytes: ReportCsv.encode(<List<Object?>>[
            headerOf(report, practice: l10n.classroomReportPracticeMinutes),
            for (final ProgramReportRow row in _rowsOf(report))
              valuesOf(report, row),
          ]),
          mimeType: SharedFile.csvType,
        ),
      },
    ];
  }

  /// The column headers of [report].
  List<String> headerOf(ProgramReport report, {required String practice}) {
    final String assessed = l10n.classroomProgramAssessed;
    final String words = l10n.classroomReportWordsShort;
    return <String>[
      l10n.classroomProgramClass,
      l10n.classroomProgramPupils,
      l10n.classroomReportColumnStart(assessed),
      l10n.classroomReportColumnEnd(assessed),
      for (final String domainId in report.domainIds) ...<String>[
        l10n.classroomReportColumnStart(l10n.domainName(domainId)),
        l10n.classroomReportColumnEnd(l10n.domainName(domainId)),
      ],
      l10n.classroomReportColumnStart(words),
      l10n.classroomReportColumnEnd(words),
      practice,
      l10n.classroomReportAcquiredShort,
    ];
  }

  /// The cells of [row] for a spreadsheet: whole percentages and minutes.
  List<Object?> valuesOf(ProgramReport report, ProgramReportRow row) {
    return <Object?>[
      row.name ?? l10n.classroomProgramTotal,
      row.pupilCount,
      row.assessedFromCount,
      row.assessedToCount,
      for (final String domainId in report.domainIds) ...<Object?>[
        ReportFormat.percentValueOf(row.domainOf(domainId)?.averageFrom),
        ReportFormat.percentValueOf(row.domainOf(domainId)?.averageTo),
      ],
      ReportFormat.percentValueOf(row.wordsFrom),
      ReportFormat.percentValueOf(row.wordsTo),
      row.practiceTime.inMinutes,
      row.acquiredItemCount,
    ];
  }

  /// The cells of [row] as the PDF shows them.
  List<String> printedCellsOf(ProgramReport report, ProgramReportRow row) {
    return <String>[
      row.name ?? l10n.classroomProgramTotal,
      '${row.pupilCount}',
      '${row.assessedFromCount}',
      '${row.assessedToCount}',
      for (final String domainId in report.domainIds) ...<String>[
        _format.percentOf(row.domainOf(domainId)?.averageFrom),
        _format.percentOf(row.domainOf(domainId)?.averageTo),
      ],
      _format.percentOf(row.wordsFrom),
      _format.percentOf(row.wordsTo),
      _format.durationOf(row.practiceTime),
      '${row.acquiredItemCount}',
    ];
  }

  static List<ProgramReportRow> _rowsOf(ProgramReport report) {
    return <ProgramReportRow>[...report.classes, report.total];
  }

  Future<List<int>> _pdfOf(ProgramReport report) async {
    final ReportFonts fonts = await _loadFonts();
    final String? from = report.fromLabel;
    final pw.Document document = pw.Document(
      theme: fonts.theme,
      title: l10n.classroomProgramOpen,
      creator: 'Kid Matix',
    );
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(ReportPdfParts.margin),
        build: (pw.Context context) => <pw.Widget>[
          ReportPdfParts.title(l10n.classroomProgramOpen),
          ReportPdfParts.line(
            from == null
                ? l10n.classroomProgramOnePeriod(report.toLabel)
                : l10n.classroomProgramPeriods(from, report.toLabel),
          ),
          ReportPdfParts.line(l10n.classroomProgramNote),
          pw.SizedBox(height: ReportPdfParts.gap),
          ReportPdfParts.table(
            header: headerOf(
              report,
              practice: l10n.classroomReportPracticeShort,
            ),
            rows: <List<String>>[
              for (final ProgramReportRow row in _rowsOf(report))
                printedCellsOf(report, row),
            ],
            size: ReportPdfParts.cellSize,
          ),
          pw.SizedBox(height: ReportPdfParts.gap),
          ReportPdfParts.line(
            l10n.classroomReportGenerated(report.generatedAt),
          ),
        ],
      ),
    );
    return document.save();
  }
}

import 'package:kid_matix/core/extensions/domain_naming.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_period.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_progress_report.dart';
import 'package:kid_matix/features/classroom/domain/entities/domain_progress.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_report_row.dart';
import 'package:kid_matix/features/classroom/presentation/report/class_report_table.dart';
import 'package:kid_matix/features/classroom/presentation/report/report_fonts.dart';
import 'package:kid_matix/features/classroom/presentation/report/report_format.dart';
import 'package:kid_matix/features/classroom/presentation/report/report_pdf_parts.dart';
import 'package:kid_matix/l10n/app_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Prints the progress report of a class as a PDF document: the periods
/// compared, the class (each domain, the words, the practice, the items
/// acquired), then a table of the pupils, on landscape A4 pages.
final class ClassReportPdf {
  /// Creates the document of [report] in the language of [l10n].
  ClassReportPdf({
    required this.report,
    required AppLocalizations l10n,
    required this.fonts,
    this.compress = true,
  }) : _table = ClassReportTable(report, l10n);

  /// The report.
  final ClassProgressReport report;

  /// The fonts.
  final ReportFonts fonts;

  /// Whether the streams are compressed; off only to read the text back
  /// in tests.
  final bool compress;

  final ClassReportTable _table;

  ReportFormat get _format => _table.format;

  AppLocalizations get _l10n => _format.l10n;

  /// The bytes of the PDF file.
  Future<List<int>> build() {
    final pw.Document document = pw.Document(
      compress: compress,
      theme: fonts.theme,
      title: _l10n.classroomReportTitle(report.classroomName),
      creator: 'Kid Matix',
    );
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(ReportPdfParts.margin),
        build: (pw.Context context) => <pw.Widget>[
          ReportPdfParts.title(
            _l10n.classroomReportTitle(report.classroomName),
          ),
          ReportPdfParts.line(_periodsOf(report.from, report.to)),
          if (report.isAnonymous)
            ReportPdfParts.line(_l10n.classroomReportAnonymousNote),
          ReportPdfParts.heading(_l10n.classroomReportClassTitle),
          ReportPdfParts.table(
            header: <String>[
              _l10n.classroomReportDomain,
              _l10n.classroomReportFrom,
              _l10n.classroomReportTo,
              _l10n.classroomReportProgressed,
            ],
            rows: _summaryRows(),
          ),
          pw.SizedBox(height: ReportPdfParts.gap),
          ReportPdfParts.line(
            _l10n.classroomReportPractice(
              report.sessionCount,
              _format.durationOf(report.practiceTime),
            ),
          ),
          ReportPdfParts.line(
            _l10n.classroomReportAcquired(report.acquiredItemCount),
          ),
          ReportPdfParts.heading(_l10n.classroomReportPupilsTitle),
          ReportPdfParts.table(
            header: _table.headerOf(
              practice: _l10n.classroomReportPracticeShort,
            ),
            rows: <List<String>>[
              for (final PupilReportRow row in report.pupils)
                _table.printedCellsOf(row),
            ],
            size: ReportPdfParts.cellSize,
          ),
          pw.SizedBox(height: ReportPdfParts.gap),
          ReportPdfParts.line(
            _l10n.classroomReportGenerated(report.generatedAt),
          ),
        ],
      ),
    );
    return document.save();
  }

  String _periodsOf(AssessmentPeriod? from, AssessmentPeriod to) {
    if (from == null) {
      return _l10n.classroomReportOnePeriod(to.label, to.startedAt);
    }
    return _l10n.classroomReportPeriods(
      from.label,
      from.startedAt,
      to.label,
      to.startedAt,
    );
  }

  List<List<String>> _summaryRows() {
    return <List<String>>[
      for (final DomainProgress domain in report.domains)
        <String>[
          _l10n.domainName(domain.domainId),
          _format.percentOf(domain.averageFrom),
          _format.percentOf(domain.averageTo),
          _l10n.classroomReportCount(
            domain.progressedCount,
            domain.assessedToCount,
          ),
        ],
      <String>[
        _l10n.classroomReportWords,
        _format.percentOf(report.wordsFrom),
        _format.percentOf(report.wordsTo),
        _l10n.classroomReportCount(_wordsProgressed(), _wordsAssessed()),
      ],
    ];
  }

  int _wordsProgressed() {
    return report.pupils.where((PupilReportRow row) {
      final WordScore? start = row.wordsFrom;
      final WordScore? end = row.wordsTo;
      return start != null && end != null && end.understood > start.understood;
    }).length;
  }

  int _wordsAssessed() {
    return report.pupils
        .where((PupilReportRow row) => row.wordsTo != null)
        .length;
  }
}

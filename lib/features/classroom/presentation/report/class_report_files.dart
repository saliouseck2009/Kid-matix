import 'package:kid_matix/core/entities/shared_file.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_progress_report.dart';
import 'package:kid_matix/features/classroom/domain/services/report_anonymizer.dart';
import 'package:kid_matix/features/classroom/presentation/report/class_report_pdf.dart';
import 'package:kid_matix/features/classroom/presentation/report/class_report_table.dart';
import 'package:kid_matix/features/classroom/presentation/report/report_csv.dart';
import 'package:kid_matix/features/classroom/presentation/report/report_fonts.dart';
import 'package:kid_matix/features/classroom/presentation/report/report_format.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// The kinds of report files.
enum ReportFileKind {
  /// A PDF document to read and print.
  pdf,

  /// A CSV table for spreadsheets.
  csv,
}

/// Turns a class report into the files the teacher shares.
final class ClassReportFiles {
  /// Creates the maker in the language of [l10n]; [loadFonts] reads the
  /// fonts of the PDF files the first time one is made.
  ClassReportFiles({
    required this.l10n,
    Future<ReportFonts> Function()? loadFonts,
    this.compress = true,
  }) : _loadFonts = loadFonts ?? ReportFonts.load;

  /// Whether the PDF streams are compressed; off only to read the text
  /// back in tests.
  final bool compress;

  /// Texts of the app.
  final AppLocalizations l10n;

  final Future<ReportFonts> Function() _loadFonts;
  Future<ReportFonts>? _fonts;

  /// The files of [report] of [kind]: the named version, and always the
  /// anonymous one next to it.
  Future<List<SharedFile>> filesOf(
    ClassProgressReport report,
    ReportFileKind kind,
  ) async {
    return <SharedFile>[
      await fileOf(report, kind),
      await fileOf(
        ReportAnonymizer.anonymize(report),
        kind,
        suffix: l10n.classroomReportFileAnonymous,
      ),
    ];
  }

  /// The file of [report] of [kind]; [suffix] ends its name.
  Future<SharedFile> fileOf(
    ClassProgressReport report,
    ReportFileKind kind, {
    String? suffix,
  }) async {
    final String name = ReportFormat(l10n).fileNameOf(
      subject: report.classroomName,
      day: report.generatedAt,
      extension: kind.name,
      suffix: suffix,
    );
    return switch (kind) {
      ReportFileKind.pdf => SharedFile(
        name: name,
        bytes: await ClassReportPdf(
          report: report,
          l10n: l10n,
          fonts: await (_fonts ??= _loadFonts()),
          compress: compress,
        ).build(),
        mimeType: SharedFile.pdfType,
      ),
      ReportFileKind.csv => SharedFile(
        name: name,
        bytes: ReportCsv.encode(ClassReportTable(report, l10n).csvRows),
        mimeType: SharedFile.csvType,
      ),
    };
  }
}

import 'package:kid_matix/core/extensions/domain_naming.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_progress_report.dart';
import 'package:kid_matix/features/classroom/domain/entities/domain_progress.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_report_row.dart';
import 'package:kid_matix/features/classroom/presentation/report/report_format.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// The table of the pupils of a class report, the same columns in the PDF
/// and the CSV files: the pupil, each domain at the start and the end,
/// the words at the start and the end, the practice and the items
/// acquired.
final class ClassReportTable {
  /// Creates the table of [report] in the language of [l10n].
  ClassReportTable(this.report, AppLocalizations l10n)
    : format = ReportFormat(l10n);

  /// The report.
  final ClassProgressReport report;

  /// Writes the values.
  final ReportFormat format;

  AppLocalizations get _l10n => format.l10n;

  /// The column headers; [practice] heads the practice column.
  List<String> headerOf({required String practice}) {
    final String words = _l10n.classroomReportWordsShort;
    return <String>[
      _l10n.classroomReportPupil,
      for (final DomainProgress domain in report.domains) ...<String>[
        _l10n.classroomReportColumnStart(_l10n.domainName(domain.domainId)),
        _l10n.classroomReportColumnEnd(_l10n.domainName(domain.domainId)),
      ],
      _l10n.classroomReportColumnStart(words),
      _l10n.classroomReportColumnEnd(words),
      practice,
      _l10n.classroomReportAcquiredShort,
    ];
  }

  /// The cells of [row] as the PDF shows them.
  List<String> printedCellsOf(PupilReportRow row) {
    return <String>[
      format.pupilOf(row),
      for (final DomainProgress domain in report.domains) ...<String>[
        format.levelOf(row.levelsFrom[domain.domainId]),
        format.levelOf(row.levelsTo[domain.domainId]),
      ],
      format.wordsOf(row.wordsFrom),
      format.wordsOf(row.wordsTo),
      format.durationOf(row.practiceTime),
      '${row.acquiredItemCount}',
    ];
  }

  /// The cells of [row] for a spreadsheet: whole percentages and minutes,
  /// empty when unknown, so they can be computed with.
  List<Object?> valuesOf(PupilReportRow row) {
    return <Object?>[
      format.pupilOf(row),
      for (final DomainProgress domain in report.domains) ...<Object?>[
        ReportFormat.percentValueOf(row.levelsFrom[domain.domainId]?.share),
        ReportFormat.percentValueOf(row.levelsTo[domain.domainId]?.share),
      ],
      row.wordsFrom?.understood,
      row.wordsTo?.understood,
      row.practiceTime.inMinutes,
      row.acquiredItemCount,
    ];
  }

  /// Every row of the CSV file, the header first.
  List<List<Object?>> get csvRows => <List<Object?>>[
    <Object?>[
      ...headerOf(practice: _l10n.classroomReportPracticeMinutes),
      _l10n.classroomReportSessions,
    ],
    for (final PupilReportRow row in report.pupils)
      <Object?>[...valuesOf(row), row.sessionCount],
  ];
}

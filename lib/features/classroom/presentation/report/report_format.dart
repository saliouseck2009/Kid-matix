import 'package:kid_matix/core/entities/domain_placement.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_report_row.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Writes the values of the reports in the language of [l10n], the same
/// way in the PDF and the CSV files.
final class ReportFormat {
  /// Creates the writer.
  const ReportFormat(this.l10n);

  static const int _percentBase = 100;
  static const int _minutesPerHour = 60;

  /// Texts of the app.
  final AppLocalizations l10n;

  /// The nickname of the pupil of [row], or « Élève 7 » without one.
  String pupilOf(PupilReportRow row) {
    return row.nickname ?? l10n.classroomReportPupilNumber(row.number);
  }

  /// « 2/3 », or a dash without a level.
  String levelOf(DomainPlacement? level) {
    final int? reached = level?.level;
    if (level == null || reached == null) return l10n.classroomReportNoValue;
    return '$reached/${level.skillCount}';
  }

  /// « 5/12 », or a dash.
  String wordsOf(WordScore? score) {
    if (score == null) return l10n.classroomReportNoValue;
    return '${score.understood}/${score.asked}';
  }

  /// « 42 % », or a dash.
  String percentOf(double? share) {
    if (share == null) return l10n.classroomReportNoValue;
    return l10n.classroomReportPercent(percentValueOf(share)!);
  }

  /// The whole percentage of [share], or `null`.
  static int? percentValueOf(double? share) {
    return share == null ? null : (share * _percentBase).round();
  }

  /// « 45 min », or « 12 h 30 min » from an hour.
  String durationOf(Duration time) {
    final int minutes = time.inMinutes;
    if (minutes < _minutesPerHour) {
      return l10n.classroomPracticeMinutes(minutes);
    }
    return l10n.classroomReportHours(
      minutes ~/ _minutesPerHour,
      minutes % _minutesPerHour,
    );
  }

  /// The name of a report file of [subject] made on [day]:
  /// `KidMatix-Rapport-CE1-B-2026-11-01.pdf`, with « -anonyme » for the
  /// anonymous version.
  String fileNameOf({
    required String subject,
    required DateTime day,
    required String extension,
    String? suffix,
  }) {
    final String name = subject
        .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    final String date = day.toIso8601String().substring(0, 10);
    final String end = suffix == null ? '' : '-$suffix';
    return 'KidMatix-${l10n.classroomReportFileName}-$name-$date$end'
        '.$extension';
  }
}

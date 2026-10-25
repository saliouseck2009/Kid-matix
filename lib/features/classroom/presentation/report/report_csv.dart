import 'dart:convert';

/// Writes a table as CSV for spreadsheets: UTF-8 with a byte order mark,
/// so accents open right, semicolon separators, as French spreadsheets
/// expect, and quotes around a cell that needs them.
abstract final class ReportCsv {
  /// Separator of the cells.
  static const String separator = ';';

  static const String _byteOrderMark = '﻿';
  static const String _lineEnd = '\r\n';

  /// The bytes of the table of [rows], the header first.
  static List<int> encode(List<List<Object?>> rows) {
    final StringBuffer text = StringBuffer(_byteOrderMark);
    for (final List<Object?> row in rows) {
      text
        ..write(row.map(_cellOf).join(separator))
        ..write(_lineEnd);
    }
    return utf8.encode(text.toString());
  }

  static String _cellOf(Object? value) {
    final String text = value?.toString() ?? '';
    final bool needsQuotes =
        text.contains(separator) ||
        text.contains('"') ||
        text.contains('\n') ||
        text.contains('\r');
    if (!needsQuotes) return text;
    return '"${text.replaceAll('"', '""')}"';
  }
}

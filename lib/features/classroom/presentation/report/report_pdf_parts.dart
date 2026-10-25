import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// The building blocks shared by the PDF files of the teacher area:
/// titles, lines of text and tables, black on white for any printer.
abstract final class ReportPdfParts {
  /// Size of the title of a document.
  static const double titleSize = 20;

  /// Size of a heading.
  static const double headingSize = 14;

  /// Size of the text.
  static const double textSize = 10;

  /// Size of the cells of a wide table.
  static const double cellSize = 8;

  /// Space between two blocks.
  static const double gap = 12;

  /// Margin of the pages.
  static const double margin = 32;

  static const PdfColor _headerColor = PdfColors.grey300;

  /// The title of a document.
  static pw.Widget title(String text) {
    return pw.Text(
      text,
      style: const pw.TextStyle(
        fontSize: titleSize,
        fontWeight: pw.FontWeight.bold,
      ),
    );
  }

  /// A heading, with space above it.
  static pw.Widget heading(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: gap, bottom: gap / 2),
      child: pw.Text(
        text,
        style: const pw.TextStyle(
          fontSize: headingSize,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  /// A line of text.
  static pw.Widget line(String text, {double size = textSize}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(text, style: pw.TextStyle(fontSize: size)),
    );
  }

  /// A table of [rows] under [header], with cells of [size].
  static pw.Widget table({
    required List<String> header,
    required List<List<String>> rows,
    double size = textSize,
  }) {
    return pw.TableHelper.fromTextArray(
      headers: header,
      data: rows,
      headerStyle: pw.TextStyle(fontSize: size, fontWeight: pw.FontWeight.bold),
      cellStyle: pw.TextStyle(fontSize: size),
      headerDecoration: const pw.BoxDecoration(color: _headerColor),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(3),
      border: pw.TableBorder.all(width: 0.5),
    );
  }
}

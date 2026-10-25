import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

/// The fonts of the PDF files of the teacher area: the app's own bundled
/// fonts, so accents, « », × and − print everywhere.
final class ReportFonts {
  /// Creates the fonts.
  const ReportFonts({required this.body, required this.title});

  /// Asset of the font of the text.
  static const String bodyAsset = 'assets/fonts/Nunito-Variable.ttf';

  /// Asset of the font of the titles.
  static const String titleAsset = 'assets/fonts/Fredoka-Variable.ttf';

  /// Font of the text.
  final pw.Font body;

  /// Font of the titles.
  final pw.Font title;

  /// Reads the fonts from [bundle], the app's assets by default.
  static Future<ReportFonts> load({AssetBundle? bundle}) async {
    final AssetBundle assets = bundle ?? rootBundle;
    return ReportFonts(
      body: pw.Font.ttf(await assets.load(bodyAsset)),
      title: pw.Font.ttf(await assets.load(titleAsset)),
    );
  }

  /// The theme of a document in these fonts.
  pw.ThemeData get theme => pw.ThemeData.withFont(base: body, bold: title);
}

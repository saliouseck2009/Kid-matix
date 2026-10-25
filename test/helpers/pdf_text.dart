import 'dart:convert';

/// The text of an uncompressed PDF made by the `pdf` package with
/// embedded TrueType fonts, word by word, joined with spaces.
///
/// The words are glyph identifiers (`[<0001000200030003>]TJ`); each font
/// declares their characters in its `ToUnicode` map. Good enough to check
/// in a test what a page prints; not a general PDF reader.
String pdfTextOf(List<int> bytes) {
  final String pdf = latin1.decode(bytes);
  final Map<String, Map<int, String>> maps = <String, Map<int, String>>{};
  final RegExp name = RegExp(r'/Name/(F\d+)/');
  final RegExp toUnicode = RegExp(r'/ToUnicode (\d+) 0 R');
  for (final String object in pdf.split('endobj')) {
    final RegExpMatch? font = name.firstMatch(object);
    final RegExpMatch? cmap = toUnicode.firstMatch(object);
    if (font != null && cmap != null) {
      maps[font.group(1)!] = _cmapOf(pdf, cmap.group(1)!);
    }
  }
  final RegExp word = RegExp(r'/(F\d+) [\d.]+ Tf[^\[]*?\[<([0-9a-f]+)>\]TJ');
  final StringBuffer text = StringBuffer();
  for (final RegExpMatch match in word.allMatches(pdf)) {
    final Map<int, String> map = maps[match.group(1)!] ?? <int, String>{};
    final String hex = match.group(2)!;
    for (int index = 0; index + 4 <= hex.length; index += 4) {
      text.write(map[int.parse(hex.substring(index, index + 4), radix: 16)]);
    }
    text.write(' ');
  }
  return text.toString();
}

Map<int, String> _cmapOf(String pdf, String objectNumber) {
  final int start = pdf.indexOf('\n$objectNumber 0 obj');
  final int end = pdf.indexOf('endobj', start);
  final String cmap = pdf.substring(start, end);
  final Map<int, String> map = <int, String>{};
  final RegExp pair = RegExp(r'<([0-9a-fA-F]{4})>\s*<([0-9a-fA-F]+)>');
  for (final RegExpMatch match in pair.allMatches(cmap)) {
    final String unicode = match.group(2)!;
    map[int.parse(match.group(1)!, radix: 16)] = String.fromCharCodes(<int>[
      for (int index = 0; index + 4 <= unicode.length; index += 4)
        int.parse(unicode.substring(index, index + 4), radix: 16),
    ]);
  }
  return map;
}

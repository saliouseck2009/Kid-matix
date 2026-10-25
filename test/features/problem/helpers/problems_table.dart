import 'dart:io';

/// One problem of `docs/product/problems.md`: its two rows joined by key.
final class ProblemRow {
  const ProblemRow({
    required this.key,
    required this.level,
    required this.operation,
    required this.form,
    required this.calculation,
    required this.statement,
    required this.template,
    required this.roles,
    required this.ranges,
    required this.wordKeys,
    required this.check,
  });

  final String key;
  final int level;
  final String operation;
  final String form;
  final String calculation;

  /// The statement with the recorded numbers.
  final String statement;

  /// The statement with `{a}`, `{b}`, `{r}`.
  final String template;

  /// Role name to placeholder (`a`) or integer literal (`2`).
  final Map<String, String> roles;
  final String ranges;
  final Set<String> wordKeys;
  final String check;
}

/// The two tables of every level of the content file, read as data (the
/// tests run from the root of the project).
List<ProblemRow> readProblemsTable() {
  final List<String> lines = File(
    'docs/product/problems.md',
  ).readAsLinesSync();
  final Map<String, List<String>> story = <String, List<String>>{};
  final Map<String, List<String>> gabarit = <String, List<String>>{};
  bool isStory = false;
  for (final String line in lines) {
    if (!line.startsWith('|')) continue;
    final List<String> cells = _cells(line);
    if (cells.first == 'Clé') {
      isStory = cells[1] == 'Niveau';
      continue;
    }
    if (cells.first.startsWith('---')) continue;
    final String key = cells.first.replaceAll('`', '');
    if (!RegExp(r'^[a-z_]+$').hasMatch(key)) continue;
    if (cells.length < 7) continue; // the table of the traps
    (isStory ? story : gabarit)[key] = cells;
  }
  return <ProblemRow>[
    for (final MapEntry<String, List<String>> entry in story.entries)
      _join(entry.key, entry.value, gabarit[entry.key]!),
  ];
}

List<String> _cells(String line) {
  final String inner = line.trim().substring(1, line.trim().length - 1);
  return inner.split(RegExp(r'(?<!\\)\|')).map((String c) => c.trim()).toList();
}

ProblemRow _join(String key, List<String> story, List<String> gab) {
  // Story: key, level, op, situation, form, all, parts, sought, calc,
  // statement, wolof, audio. Gabarit: key, template, roles, ranges, words,
  // check, trap, (image).
  final Map<String, String> roles = <String, String>{};
  for (final String part in gab[2].replaceAll('`', '').split(';')) {
    final String text = part.replaceAll('(constante)', '').trim();
    if (text.isEmpty) continue;
    final List<String> pair = text.split('=');
    roles[pair[0].trim()] = pair[1].trim();
  }
  return ProblemRow(
    key: key,
    level: int.parse(story[1]),
    operation: story[2],
    form: story[4].replaceAll('`', ''),
    calculation: story[8],
    statement: story[9],
    template: gab[1],
    roles: roles,
    ranges: gab[3].replaceAll('`', ''),
    wordKeys: RegExp(
      r'word:([a-z_]+)',
    ).allMatches(gab[4]).map((RegExpMatch m) => m.group(1)!).toSet(),
    check: gab[5],
  );
}

/// Trap key to twin key, from the table « Les pièges du mot-clé ».
Map<String, String> readTrapTwins() {
  final Map<String, String> twins = <String, String>{};
  bool inside = false;
  for (final String line in File(
    'docs/product/problems.md',
  ).readAsLinesSync()) {
    if (line.startsWith('## ')) inside = line.contains('pièges du mot-clé');
    if (!inside || !line.startsWith('|')) continue;
    final List<String> cells = _cells(line);
    if (cells.first == 'Clé du piège' || cells.first.startsWith('---')) {
      continue;
    }
    twins[cells[0].replaceAll('`', '')] = cells[1].replaceAll('`', '');
  }
  return twins;
}

/// Real and suggested operation (`+`, `−`, `×`, `÷`) of each trap, from the
/// table « Les pièges du mot-clé ».
Map<String, ({String real, String suggested})> readTrapOperations() {
  final Map<String, ({String real, String suggested})> operations =
      <String, ({String real, String suggested})>{};
  bool inside = false;
  for (final String line in File(
    'docs/product/problems.md',
  ).readAsLinesSync()) {
    if (line.startsWith('## ')) inside = line.contains('pièges du mot-clé');
    if (!inside || !line.startsWith('|')) continue;
    final List<String> cells = _cells(line);
    if (cells.first == 'Clé du piège' || cells.first.startsWith('---')) {
      continue;
    }
    operations[cells[0].replaceAll('`', '')] = (
      real: cells[3],
      suggested: cells[4],
    );
  }
  return operations;
}

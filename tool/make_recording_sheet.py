"""Builds docs/product/recording-sheet.md, the sheet to record the Wolof files.

One numbered row per file to record, in recording order: the 80 word files
(for each word of docs/product/math-words.md, the explanation
`wo_<key>.m4a` then the example `wo_<key>_exemple.m4a`), then the 30
problems of docs/product/problems.md (`wo_problem_<key>.m4a`). The text to
say is the Wolof cell of the table (« à écrire » when empty); the French is
there for reference.

Standard library only, no virtualenv.

  python3 tool/make_recording_sheet.py           write the sheet
  python3 tool/make_recording_sheet.py --check   fail when the sheet is stale
"""

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
WORDS = ROOT / "docs" / "product" / "math-words.md"
PROBLEMS = ROOT / "docs" / "product" / "problems.md"
OUTPUT = ROOT / "docs" / "product" / "recording-sheet.md"

MARKS = (" (machine, à relire)", " (Google, à relire)")
TO_WRITE = "à écrire"

HEADER = """\
# Feuille d'enregistrement du wolof

Fichier généré par `python3 tool/make_recording_sheet.py` à partir des
tableaux `math-words.md` et `problems.md` : ne le modifie pas à la main,
corrige plutôt le texte wolof dans les tableaux, puis relance la commande.

## Les règles

- **Un fichier par ligne**, dans l'ordre du tableau : coche la case quand le
  fichier est enregistré et écouté.
- **Le nom exact** de la colonne « Fichier », en minuscules, en `.m4a`
  (ou garde l'extension de ton enregistreur : le script convertit).
- **Deux secondes de silence** avant de parler et après la dernière phrase.
- **Une voix lente et chaleureuse**, comme pour un petit enfant qui apprend.
- **Les nombres sont dits en lettres**, en wolof, jamais en chiffres.
- **Pas de « franc »** : les montants se disent sans le mot de la monnaie.
- **De 5 à 10 secondes** par fichier, 15 au plus.
- **Un essai raté** : supprime-le et recommence le fichier en entier depuis
  le début (le script ne coupe pas les erreurs au milieu).
- Texte « à relire » : le texte wolof vient de Google Translate et n'a pas
  été relu ; corrige-le dans le tableau avant d'enregistrer. Quand « à
  écrire » est affiché, la cellule du tableau est vide.

Le guide complet est dans `audio-recording.md`.

| N° | Fichier | À dire (wolof) | Français, pour repère | Fait |
| --- | --- | --- | --- | --- |
"""


def cells(line):
    return [cell.strip() for cell in line.strip().strip("|").split("|")]


def is_row(line):
    return line.startswith("|") and not line.startswith("| ---")


def word_rows(markdown):
    """(key, explanation fr, example fr, explanation wo, example wo)."""
    section = family = False
    for line in markdown.splitlines():
        if line.startswith("## "):
            section = line[3:].strip().startswith("1.")
            family = False
        elif line.startswith("### "):
            family = True
        elif section and family and is_row(line):
            row = cells(line)
            if len(row) >= 8 and row[0] != "Clé":
                yield row[0].strip("`"), row[2], row[4], row[6], row[7]


def problem_rows(markdown):
    """(key, statement fr, statement wo)."""
    for line in markdown.splitlines():
        if is_row(line):
            row = cells(line)
            if len(row) == 12 and row[0] != "Clé":
                yield row[0].strip("`"), row[9], row[10]


def to_say(cell):
    """The text to say for a Wolof cell: without its mark, with a reminder
    when the mark is still there, « à écrire » when empty."""
    if not cell:
        return f"*{TO_WRITE}*"
    for mark in MARKS:
        if cell.endswith(mark):
            return cell[: -len(mark)] + " *(à relire)*"
    return cell


def escape(text):
    return text.replace("|", "/")


def build(words_markdown, problems_markdown):
    rows = []
    for key, fr_explanation, fr_example, wo_explanation, wo_example in word_rows(
        words_markdown
    ):
        rows.append((f"wo_{key}.m4a", wo_explanation, fr_explanation))
        rows.append((f"wo_{key}_exemple.m4a", wo_example, fr_example))
    for key, french, wolof in problem_rows(problems_markdown):
        rows.append((f"wo_problem_{key}.m4a", wolof, french))
    lines = [
        f"| {number} | `{name}` | {escape(to_say(wolof))} | {escape(french)} | [ ] |"
        for number, (name, wolof, french) in enumerate(rows, start=1)
    ]
    return HEADER + "\n".join(lines) + "\n", len(rows)


def main():
    text, count = build(
        WORDS.read_text(encoding="utf-8"), PROBLEMS.read_text(encoding="utf-8")
    )
    if "--check" in sys.argv:
        if not OUTPUT.exists() or OUTPUT.read_text(encoding="utf-8") != text:
            raise SystemExit(f"{OUTPUT} is stale: run tool/make_recording_sheet.py")
        print("recording-sheet.md is up to date")
        return
    OUTPUT.write_text(text, encoding="utf-8")
    print(f"{count} files in {OUTPUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()

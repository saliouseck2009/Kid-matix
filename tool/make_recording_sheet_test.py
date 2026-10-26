"""Tests of tool/make_recording_sheet.py:
python3 -m unittest tool/make_recording_sheet_test.py"""

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import make_recording_sheet as sheet  # noqa: E402

WORDS = """## 1. Les mots

### Ajouter

| Clé | Mot | Sens simple | Image | Exemple | Forme | Explication en wolof | Exemple en wolof | A | B |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `ajouter` | ajouter | Mettre en plus. | x | Awa a 4 mangues. | ajoute | Yokk (Google, à relire) |  | `a` | `b` |
| `en_plus` | en plus | Encore. | x | Fatou a 6 mangues. | en plus | Ba pare | Misaal | `a` | `b` |
"""

PROBLEMS = """### Énoncé et schéma

| Clé | Niveau | Opération | Situation | Forme | Tout | Parties | Cherché | Calcul | Énoncé | Wolof : énoncé | Audio |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `mangues_donnees` | 1 | − | retirer | `retirer` | 12 | 5 | reste | 12 − 5 = 7 | Awa a 12 mangues. | Awa am na | `wo_problem_mangues_donnees.m4a` |

### Gabarit

| Clé | Gabarit | Rôles |
| --- | --- | --- |
| `mangues_donnees` | {a} | tout=a |
"""


class SheetTest(unittest.TestCase):
    def test_files_come_in_recording_order(self):
        text, count = sheet.build(WORDS, PROBLEMS)
        self.assertEqual(count, 5)
        names = [line.split("`")[1] for line in text.splitlines() if line.startswith("| ") and "`" in line]
        self.assertEqual(
            names,
            [
                "wo_ajouter.m4a", "wo_ajouter_exemple.m4a", "wo_en_plus.m4a",
                "wo_en_plus_exemple.m4a", "wo_problem_mangues_donnees.m4a",
            ],
        )

    def test_empty_cell_says_to_write_and_a_mark_is_a_reminder(self):
        text, _ = sheet.build(WORDS, PROBLEMS)
        self.assertIn("| 1 | `wo_ajouter.m4a` | Yokk *(à relire)* |", text)
        self.assertIn("| 2 | `wo_ajouter_exemple.m4a` | *à écrire* |", text)
        self.assertIn("| 3 | `wo_en_plus.m4a` | Ba pare |", text)
        self.assertIn("| [ ] |", text)

    def test_the_real_tables_give_110_files(self):
        text, count = sheet.build(
            sheet.WORDS.read_text(encoding="utf-8"),
            sheet.PROBLEMS.read_text(encoding="utf-8"),
        )
        self.assertEqual(count, 110)

    def test_header_holds_the_rules(self):
        for rule in ("Un fichier par ligne", "Deux secondes de silence", "lettres", "franc"):
            self.assertIn(rule, sheet.HEADER)


if __name__ == "__main__":
    unittest.main()

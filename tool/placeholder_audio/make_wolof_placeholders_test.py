"""Tests of make_wolof_placeholders.py, offline and without torch:

  python3 -m unittest tool/placeholder_audio/make_wolof_placeholders_test.py
"""

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import make_wolof_placeholders as make  # noqa: E402

WORDS = """# Les mots

Statut : brouillon.

## 1. Les mots et expressions

### Ajouter

| Clé | Mot | Sens simple | Image | Exemple | Forme | Explication en wolof | Exemple en wolof | A1 | A2 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `ajouter` | ajouter | Mettre en plus. | Un panier. | Awa a 4 mangues. | ajoute |  |  | `a` | `b` |
| `en_plus` | en plus | Encore. | Un panier. | Fatou a 6 mangues. | en plus | écrit à la main |  | `a` | `b` |

## 2. Notions

| Notion | x | y |
| --- | --- | --- |
| `ajouter` | a | b |
"""

PROBLEMS = """# Problèmes

Statut : brouillon.

## Niveau 1

### Énoncé et schéma

| Clé | Niveau | Opération | Situation | Forme | Tout | Parties | Cherché | Calcul | Énoncé | Wolof : énoncé | Audio |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `mangues_donnees` | 1 | − | retirer | `retirer` | 12 | 5 | reste | 12 − 5 = 7 | Awa a 12 mangues. |  | `wo_problem_mangues_donnees.m4a` |

### Gabarit

| Clé | Gabarit | Rôles |
| --- | --- | --- |
| `mangues_donnees` | {a} mangues | tout=a |
"""


class ExtractTest(unittest.TestCase):
    def test_words_give_an_explanation_and_an_example(self):
        self.assertEqual(
            make.extract_words(WORDS),
            [
                ("wo_ajouter", "Mettre en plus."),
                ("wo_ajouter_exemple", "Awa a 4 mangues."),
                ("wo_en_plus", "Encore."),
                ("wo_en_plus_exemple", "Fatou a 6 mangues."),
            ],
        )

    def test_problems_give_the_statement_of_the_first_table_only(self):
        self.assertEqual(
            make.extract_problems(PROBLEMS),
            [("wo_problem_mangues_donnees", "Awa a 12 mangues.")],
        )

    def test_the_real_tables_hold_80_words_and_30_problems(self):
        words = make.extract_words(make.WORDS_TABLE.read_text(encoding="utf-8"))
        problems = make.extract_problems(make.PROBLEMS_TABLE.read_text(encoding="utf-8"))
        self.assertEqual(len(words), 80)
        self.assertEqual(len(problems), 30)
        names = [name for name, _ in words + problems]
        self.assertEqual(len(set(names)), 110)


class TablesTest(unittest.TestCase):
    wolof = {
        "wo_ajouter": "AAA",
        "wo_ajouter_exemple": "BBB",
        "wo_en_plus": "CCC",
        "wo_en_plus_exemple": "DDD",
        "wo_problem_mangues_donnees": "EEE",
    }

    def test_every_cell_gets_the_machine_mark(self):
        text = make.rewrite_words(WORDS, self.wolof)
        self.assertIn("| AAA (machine, à relire) | BBB (machine, à relire) |", text)
        self.assertIn("| DDD (machine, à relire) |", text)

    def test_a_cell_written_by_hand_is_kept(self):
        text = make.rewrite_words(WORDS, self.wolof)
        self.assertIn("| écrit à la main |", text)
        self.assertNotIn("CCC", text)

    def test_rewriting_twice_changes_nothing(self):
        once = make.rewrite_words(WORDS, self.wolof)
        self.assertEqual(make.rewrite_words(once, self.wolof), once)

    def test_a_new_translation_replaces_a_machine_cell(self):
        once = make.rewrite_words(WORDS, self.wolof)
        again = make.rewrite_words(once, {**self.wolof, "wo_ajouter": "ZZZ"})
        self.assertIn("ZZZ (machine, à relire)", again)
        self.assertNotIn("AAA", again)

    def test_a_bar_in_the_translation_cannot_break_the_table(self):
        text = make.rewrite_words(WORDS, {"wo_ajouter": "a|b"})
        self.assertIn("a/b (machine, à relire)", text)

    def test_the_problem_column_is_filled_in_the_first_table_only(self):
        text = make.rewrite_problems(PROBLEMS, self.wolof)
        self.assertIn("| EEE (machine, à relire) | `wo_problem_mangues_donnees.m4a` |", text)
        self.assertIn("| `mangues_donnees` | {a} mangues | tout=a |", text)

    def test_the_status_line_is_added_once(self):
        once = make.with_status(WORDS)
        self.assertEqual(once.count(make.STATUS_PREFIX), 1)
        self.assertEqual(make.with_status(once), once)
        lines = once.splitlines()
        self.assertTrue(lines[lines.index("Statut : brouillon.") + 2].startswith(make.STATUS_PREFIX))


class TokensTest(unittest.TestCase):
    vocab = {"a": 1, "e": 4, "n": 5, "o": 2, " ": 40, "|": 0, "'": 19}

    def test_a_blank_surrounds_every_character(self):
        self.assertEqual(make.token_ids("an", self.vocab), [0, 1, 0, 5, 0])

    def test_marks_are_read_without_the_accent(self):
        self.assertEqual(make.token_ids("é", self.vocab), [0, 4, 0])
        self.assertEqual(make.token_ids("ñ", self.vocab), [0, 5, 0])

    def test_unknown_characters_are_dropped_and_upper_case_lowered(self):
        self.assertEqual(make.token_ids("A?z", self.vocab), [0, 1, 0])
        self.assertEqual(make.token_ids("?", self.vocab), [])


class NumbersTest(unittest.TestCase):
    def test_digits_are_spelled_in_french(self):
        try:
            import num2words  # noqa: F401
        except ImportError:
            self.skipTest("num2words is not installed")
        self.assertEqual(make.spell_numbers("Awa a 12 mangues."), "Awa a douze mangues.")
        self.assertEqual(make.spell_numbers("100 francs"), "cent francs")


if __name__ == "__main__":
    unittest.main()

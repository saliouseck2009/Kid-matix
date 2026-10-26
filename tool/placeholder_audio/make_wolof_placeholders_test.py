"""Tests of make_wolof_placeholders.py, offline and without torch:

  python3 -m unittest tool/placeholder_audio/make_wolof_placeholders_test.py
"""

import json
import sys
import tempfile
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


def entry(text, engine="nllb"):
    return {"fr": "x", "wo": text, "engine": engine}


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
        "wo_ajouter": entry("AAA"),
        "wo_ajouter_exemple": entry("BBB"),
        "wo_en_plus": entry("CCC"),
        "wo_en_plus_exemple": entry("DDD"),
        "wo_problem_mangues_donnees": entry("EEE"),
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
        again = make.rewrite_words(once, {**self.wolof, "wo_ajouter": entry("ZZZ")})
        self.assertIn("ZZZ (machine, à relire)", again)
        self.assertNotIn("AAA", again)

    def test_a_bar_in_the_translation_cannot_break_the_table(self):
        text = make.rewrite_words(WORDS, {"wo_ajouter": entry("a|b")})
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


class MarksTest(unittest.TestCase):
    def test_a_google_cell_carries_its_own_mark(self):
        text = make.rewrite_words(WORDS, {"wo_ajouter": entry("GGG", "google-web")})
        self.assertIn("| GGG (Google, à relire) |", text)

    def test_either_mark_lets_the_script_rewrite_a_cell(self):
        google = make.rewrite_words(WORDS, {"wo_ajouter": entry("GGG", "google-web")})
        again = make.rewrite_words(google, {"wo_ajouter": entry("NNN")})
        self.assertIn("| NNN (machine, à relire) |", again)

    def test_the_status_line_goes_under_a_status_with_a_no_break_space(self):
        text = make.with_status("# T\n\nStatut\u00a0: brouillon.\n\nSuite\n")
        lines = text.splitlines()
        self.assertTrue(lines[4].startswith("Wolof provisoire"))
        self.assertEqual(make.with_status(text), text)

    def test_math_words_asset_ignores_both_marks(self):
        sys.path.insert(0, str(make.ROOT / "tool"))
        import build_math_words as words

        row = ["", "", "", "", "", "", "texte A (machine, à relire)", "vrai texte"]
        self.assertEqual(words.help_of(row), {"example": "vrai texte"})
        row[6] = "texte B (Google, à relire)"
        self.assertEqual(words.help_of(row), {"example": "vrai texte"})


class LoopTest(unittest.TestCase):
    def test_a_looping_output_is_refused(self):
        source = "Partager des choses entre des personnes."
        self.assertIsNotNone(make.looks_wrong(source, "Sëriñ " * 64))
        self.assertIsNotNone(make.looks_wrong(source, "x" * 300))
        self.assertIsNotNone(make.looks_wrong(source, ""))
        self.assertIsNone(make.looks_wrong(source, "Séddoo yëf yi ak nit ñi."))


class TranslateTest(unittest.TestCase):
    items = [("wo_a", "Un."), ("wo_b", "Deux.")]

    def setUp(self):
        self.folder = tempfile.TemporaryDirectory()
        self.original = (make.CACHE, make.spell_numbers)
        make.CACHE = Path(self.folder.name) / "cache.json"
        make.spell_numbers = lambda text: text

    def tearDown(self):
        make.CACHE, make.spell_numbers = self.original
        self.folder.cleanup()

    def test_translates_once_and_caches(self):
        calls = []

        def fake(text):
            calls.append(text)
            return f"wo:{text}"

        first = make.translate(self.items, fake)
        self.assertEqual(first["wo_a"], {"fr": "Un.", "wo": "wo:Un.", "engine": "nllb"})
        make.translate(self.items, fake)
        self.assertEqual(calls, ["Un.", "Deux."])
        make.translate(self.items, fake, force=True)
        self.assertEqual(len(calls), 4)

    def test_a_changed_french_text_is_translated_again(self):
        make.translate(self.items, lambda t: "old")
        again = make.translate([("wo_a", "Un !"), ("wo_b", "Deux.")], lambda t: "new")
        self.assertEqual(again["wo_a"]["wo"], "new")
        self.assertEqual(again["wo_b"]["wo"], "old")

    def test_a_looping_cached_translation_is_made_again(self):
        make.save_cache({"wo_a": {"fr": "Un.", "wo": "Sëriñ " * 64, "engine": "nllb"}})
        done = make.translate([("wo_a", "Un.")], lambda t: "bon")
        self.assertEqual(done["wo_a"]["wo"], "bon")

    def test_a_refusal_stops_and_keeps_what_is_done(self):
        def fake(text):
            if text == "Deux.":
                raise ValueError("no usable translation")
            return "ok"

        with self.assertRaises(SystemExit) as stop:
            make.translate(self.items, fake)
        self.assertIn("wo_b", str(stop.exception))
        self.assertEqual(make.load_cache()["wo_a"]["wo"], "ok")


class FileEngineTest(unittest.TestCase):
    def setUp(self):
        self.folder = tempfile.TemporaryDirectory()
        self.original = (make.CACHE, make.spell_numbers)
        make.CACHE = Path(self.folder.name) / "cache.json"
        make.spell_numbers = lambda text: text
        self.items = make.extract()

    def tearDown(self):
        make.CACHE, make.spell_numbers = self.original
        self.folder.cleanup()

    def write(self, lines):
        path = Path(self.folder.name) / "wolof.txt"
        path.write_text("\n".join(lines) + "\n", encoding="utf-8")
        return path

    def test_110_lines_fill_the_cache_as_google_web(self):
        path = self.write([f"wolof {number}" for number in range(110)])
        done = make.translate_from_file(self.items, path)
        self.assertEqual(len(done), 110)
        first = done[self.items[0][0]]
        self.assertEqual(first["wo"], "wolof 0")
        self.assertEqual(first["engine"], "google-web")
        self.assertEqual(done[self.items[-1][0]]["wo"], "wolof 109")
        self.assertEqual(len(json.loads(make.CACHE.read_text(encoding="utf-8"))), 110)

    def test_a_wrong_line_count_is_refused(self):
        for count in (109, 111):
            path = self.write([f"wolof {number}" for number in range(count)])
            with self.assertRaises(SystemExit) as stop:
                make.translate_from_file(self.items, path)
            self.assertIn("110", str(stop.exception))
        self.assertFalse(make.CACHE.exists())

    def test_a_blank_line_is_refused(self):
        lines = [f"wolof {number}" for number in range(110)]
        lines[5] = ""
        with self.assertRaises(SystemExit):
            make.translate_from_file(self.items, self.write(lines))


class WavNotesTest(unittest.TestCase):
    def test_a_wav_is_current_only_with_the_same_text(self):
        with tempfile.TemporaryDirectory() as folder:
            original = make.WAV_DIR
            make.WAV_DIR = Path(folder)
            try:
                self.assertFalse(make.wav_is_current("wo_a", "x"))
                (Path(folder) / "wo_a.wav").write_bytes(b"")
                self.assertFalse(make.wav_is_current("wo_a", "x"))
                make._note("wo_a").write_text("x", encoding="utf-8")
                self.assertTrue(make.wav_is_current("wo_a", "x"))
                self.assertFalse(make.wav_is_current("wo_a", "y"))
            finally:
                make.WAV_DIR = original


class TablesAreTheSourceTest(unittest.TestCase):
    def test_every_text_of_the_pack_has_a_wolof_cell(self):
        cells = make.cells_of(make.extract())
        self.assertEqual(len(cells), 110)
        self.assertEqual([n for n, c in cells.items() if not c], [])

    def test_split_mark_tells_checked_from_provisional(self):
        self.assertEqual(make.split_mark("Waaw (Google, à relire)"), ("Waaw", " (Google, à relire)"))
        self.assertEqual(make.split_mark("Waaw (machine, à relire)")[0], "Waaw")
        self.assertEqual(make.split_mark("Waaw"), ("Waaw", ""))

    def test_an_edited_marked_cell_is_not_overwritten_by_the_cache(self):
        edited = WORDS.replace("| écrit à la main |", "| ma version (machine, à relire) |")
        text = make.rewrite_words(edited, {"wo_en_plus": entry("CCC")}, overwrite=False)
        self.assertIn("ma version (machine, à relire)", text)
        self.assertNotIn("CCC", text)

    def test_an_empty_cell_is_filled_even_without_overwrite(self):
        text = make.rewrite_words(WORDS, {"wo_ajouter": entry("AAA")}, overwrite=False)
        self.assertIn("AAA (machine, à relire)", text)

    def test_words_of_rules_are_never_spoken(self):
        rules = ["franc", "francs"]
        self.assertEqual(make.apply_rules("Dafa jar 100 francs, waaw.", rules), "Dafa jar 100, waaw.")
        self.assertEqual(make.apply_rules("Fukk Franc ak juróom", rules), "Fukk ak juróom")
        self.assertEqual(make.apply_rules("francophone", rules), "francophone")
        self.assertEqual(make.apply_rules("  a   b ", []), "a b")

    def test_rules_file_skips_comments_and_blank_lines(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / "rules.txt"
            path.write_text("# c\nfranc  # trailing\n\nFRANCS\n", encoding="utf-8")
            self.assertEqual(make.load_rules(path), ["franc", "francs"])
            self.assertEqual(make.load_rules(Path(folder) / "none.txt"), [])

    def test_the_shipped_rules_hold_the_currency_word(self):
        self.assertIn("franc", make.load_rules())

    def test_no_cached_nllb_text_loops(self):
        for name, entry_ in make.load_cache().items():
            if entry_.get("engine") == "nllb":
                self.assertIsNone(make.looks_wrong(entry_["fr"], entry_["wo"]), name)


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

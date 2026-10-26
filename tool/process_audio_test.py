"""Tests of tool/process_audio.py: python3 -m unittest tool/process_audio_test.py

The conversion test needs ffmpeg and is skipped without it.
"""

import json
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import process_audio as audio  # noqa: E402

KEYS = ["il_reste", "de_plus_que"]
PROBLEMS = ["mangues_donnees", "billes_recues"]


class ProblemRecordingsTest(unittest.TestCase):
    def test_problem_statement_has_one_file_and_no_example(self):
        self.assertEqual(
            audio.classify("wo_problem_mangues_donnees", "wo", KEYS, PROBLEMS),
            ("problem_mangues_donnees", "explanation"),
        )
        self.assertEqual(
            audio.classify("WO_Problem_Billes_Recues", "wo", KEYS, PROBLEMS),
            ("problem_billes_recues", "explanation"),
        )
        self.assertIsNone(
            audio.classify("wo_problem_mangues_donnees_exemple", "wo", KEYS, PROBLEMS)
        )
        self.assertIsNone(audio.classify("wo_problem_inconnu", "wo", KEYS, PROBLEMS))
        self.assertIsNone(
            audio.classify("wo_problem_mangues_donnees", "wo", KEYS)
        )

    def test_missing_lists_the_problems_after_the_words(self):
        found = {("il_reste", "explanation"): None, ("problem_billes_recues", "explanation"): None}
        self.assertEqual(
            audio.missing(found, KEYS, PROBLEMS),
            [
                ("il_reste", "example"),
                ("de_plus_que", "explanation"),
                ("de_plus_que", "example"),
                ("problem_mangues_donnees", "explanation"),
            ],
        )

    def test_manifest_and_pack_hold_the_problem_files(self):
        present = {("problem_mangues_donnees", "explanation")}
        self.assertEqual(
            audio.build_manifest("wo", KEYS, present, PROBLEMS),
            {
                "language": "wo",
                "format": "m4a",
                "words": {
                    "problem_mangues_donnees": {
                        "explanation": "wo_problem_mangues_donnees.m4a"
                    }
                },
            },
        )
        with tempfile.TemporaryDirectory() as folder:
            output = Path(folder) / "wo"
            output.mkdir()
            (output / "wo_problem_billes_recues.m4a").write_bytes(b"")
            self.assertEqual(
                audio.present_in(output, "wo", KEYS, PROBLEMS),
                {("problem_billes_recues", "explanation")},
            )

    def test_keys_come_from_the_audio_column_of_the_table(self):
        keys = audio.load_problem_keys()
        self.assertEqual(len(keys), 30)
        self.assertIn("mangues_donnees", keys)
        self.assertEqual(len(set(keys)), 30)


class ProvisionalTest(unittest.TestCase):
    present = {("il_reste", "explanation"), ("il_reste", "example")}

    def test_manifest_has_the_flag_only_when_provisional(self):
        flagged = audio.build_manifest("wo", KEYS, self.present, provisional=True)
        self.assertIs(flagged["provisional"], True)
        plain = audio.build_manifest("wo", KEYS, self.present)
        self.assertNotIn("provisional", plain)
        self.assertEqual(
            audio.build_manifest("wo", KEYS, self.present, provisional=False), plain
        )

    def test_requested_flag_always_wins(self):
        self.assertTrue(audio.is_provisional(True, False, self.present, self.present))
        self.assertTrue(audio.is_provisional(True, True, self.present, set()))

    def test_real_recordings_over_all_the_standins_clear_the_flag(self):
        self.assertFalse(audio.is_provisional(False, True, self.present, self.present))
        self.assertFalse(audio.is_provisional(False, False, self.present, set()))

    def test_partial_delivery_keeps_the_flag(self):
        converted = {("il_reste", "explanation")}
        self.assertTrue(audio.is_provisional(False, True, self.present, converted))

    def test_flag_is_read_from_the_manifest_on_disk(self):
        with tempfile.TemporaryDirectory() as folder:
            output = Path(folder)
            self.assertFalse(audio.read_provisional(output))
            manifest = output / "manifest.json"
            manifest.write_text('{"provisional": true, "words": {}}')
            self.assertTrue(audio.read_provisional(output))
            manifest.write_text('{"words": {}}')
            self.assertFalse(audio.read_provisional(output))
            manifest.write_text("not json")
            self.assertFalse(audio.read_provisional(output))


class ClassifyTest(unittest.TestCase):
    def test_explanation_and_example(self):
        self.assertEqual(audio.classify("wo_il_reste", "wo", KEYS), ("il_reste", "explanation"))
        self.assertEqual(
            audio.classify("wo_de_plus_que_exemple", "wo", KEYS), ("de_plus_que", "example")
        )

    def test_names_are_case_insensitive(self):
        self.assertEqual(audio.classify("WO_Il_Reste", "wo", KEYS), ("il_reste", "explanation"))
        self.assertEqual(
            audio.classify("Wo_de_plus_que_Exemple", "wo", KEYS), ("de_plus_que", "example")
        )

    def test_pack_is_what_the_output_folder_holds_and_index_follows_it(self):
        with tempfile.TemporaryDirectory() as folder:
            output = Path(folder) / "xx"
            output.mkdir()
            (output / "xx_il_reste.m4a").write_bytes(b"")
            self.assertEqual(
                audio.present_in(output, "xx", KEYS), {("il_reste", "explanation")}
            )
            audio.register_language("xx", output)
            index = json.loads((Path(folder) / "packs.json").read_text())
            self.assertEqual(index, {"languages": ["xx"]})

    def test_unknown_names(self):
        self.assertIsNone(audio.classify("wo_inconnu", "wo", KEYS))
        self.assertIsNone(audio.classify("fr_il_reste", "wo", KEYS))
        self.assertIsNone(audio.classify("il_reste", "wo", KEYS))

    def test_missing_and_manifest(self):
        present = {("il_reste", "explanation"), ("il_reste", "example")}
        self.assertEqual(
            audio.missing({slot: None for slot in present}, KEYS),
            [("de_plus_que", "explanation"), ("de_plus_que", "example")],
        )
        self.assertEqual(
            audio.build_manifest("wo", KEYS, present),
            {
                "language": "wo",
                "format": "m4a",
                "words": {
                    "il_reste": {
                        "explanation": "wo_il_reste.m4a",
                        "example": "wo_il_reste_exemple.m4a",
                    }
                },
            },
        )


@unittest.skipUnless(shutil.which("ffmpeg"), "ffmpeg is not installed")
class ConvertTest(unittest.TestCase):
    def test_trims_silence_and_converts_to_mono_m4a(self):
        with tempfile.TemporaryDirectory() as folder:
            source = Path(folder) / "wo_il_reste.wav"
            target = Path(folder) / "out.m4a"
            # 3 s of silence, 1 s of tone, 3 s of silence, in stereo.
            subprocess.run(
                [
                    "ffmpeg", "-y", "-loglevel", "error",
                    "-f", "lavfi", "-i", "anullsrc=r=44100:cl=stereo:d=3",
                    "-f", "lavfi", "-i", "sine=frequency=440:d=1",
                    "-f", "lavfi", "-i", "anullsrc=r=44100:cl=stereo:d=3",
                    "-filter_complex", "[1:a]aformat=channel_layouts=stereo[t];"
                    "[0:a][t][2:a]concat=n=3:v=0:a=1",
                    str(source),
                ],
                check=True,
            )
            seconds = audio.convert(source, target)
            self.assertLess(seconds, 2.5)
            self.assertGreater(seconds, 1.0)
            channels = subprocess.run(
                [
                    "ffprobe", "-v", "error", "-show_entries", "stream=channels",
                    "-of", "default=nw=1:nk=1", str(target),
                ],
                capture_output=True, text=True, check=True,
            ).stdout.strip()
            self.assertEqual(channels, "1")

    def test_converts_a_16_khz_wav_like_the_voice_makes(self):
        with tempfile.TemporaryDirectory() as folder:
            source = Path(folder) / "wo_il_reste.wav"
            target = Path(folder) / "out.m4a"
            subprocess.run(
                [
                    "ffmpeg", "-y", "-loglevel", "error",
                    "-f", "lavfi", "-i", "sine=frequency=300:sample_rate=16000:d=1",
                    "-ac", "1", "-c:a", "pcm_s16le", str(source),
                ],
                check=True,
            )
            self.assertGreater(audio.convert(source, target), 0.5)
            rate = subprocess.run(
                [
                    "ffprobe", "-v", "error", "-show_entries", "stream=sample_rate",
                    "-of", "default=nw=1:nk=1", str(target),
                ],
                capture_output=True, text=True, check=True,
            ).stdout.strip()
            self.assertEqual(rate, "32000")

    def test_scan_accepts_other_extensions(self):
        with tempfile.TemporaryDirectory() as folder:
            (Path(folder) / "wo_il_reste.mp3").write_bytes(b"")
            (Path(folder) / "wo_il_reste_exemple.wav").write_bytes(b"")
            (Path(folder) / "notes.txt").write_text("x")
            found, unrecognized, duplicates = audio.scan(Path(folder), "wo", KEYS)
            self.assertEqual(set(found), {("il_reste", "explanation"), ("il_reste", "example")})
            self.assertEqual([path.name for path in unrecognized], ["notes.txt"])
            self.assertEqual(duplicates, [])


if __name__ == "__main__":
    unittest.main()

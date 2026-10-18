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


class ClassifyTest(unittest.TestCase):
    def test_explanation_and_example(self):
        self.assertEqual(audio.classify("wo_il_reste", "wo", KEYS), ("il_reste", "explanation"))
        self.assertEqual(
            audio.classify("wo_de_plus_que_exemple", "wo", KEYS), ("de_plus_que", "example")
        )

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

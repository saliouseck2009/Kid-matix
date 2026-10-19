"""Prepares the recordings of a help language for the app (lot F28).

Takes the folder the owner delivered (any audio format: .m4a, .mp3, .wav,
.aac, .ogg, .opus, .flac, .amr, .3gp, .caf, .aiff; the extension is the one
of the recorder, never renamed) and writes the language pack of the app:

  assets/audio/<language>/wo_<key>.m4a            the explanation of a word
  assets/audio/<language>/wo_<key>_exemple.m4a    its example
  assets/audio/<language>/manifest.json           what the pack holds
  assets/audio/packs.json                         the list of languages

For each file it trims the silence at the start and at the end, keeping a
short margin, evens the volume out, and converts to mono AAC (32 kHz,
48 kbit/s, about 6 KB per second). It then checks that every key of
assets/math_words/math_words.json has its two files, and lists what is
missing. The manifest only holds the files that exist: the app hides the
button of a missing file.

Needs ffmpeg and ffprobe on the PATH (brew install ffmpeg). No Dart
package is involved.

Usage:
  python3 tool/process_audio.py INPUT_DIR [--language wo] [--output DIR]
  python3 tool/process_audio.py INPUT_DIR --check     names only, no ffmpeg

The file names keep the language code as a prefix (`wo_`), so the guide and
the table stay the reference. Exit status 1 when a file is missing or not
recognized.
"""

import argparse
import json
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
WORDS = ROOT / "assets" / "math_words" / "math_words.json"
PACKS = ROOT / "assets" / "audio"
PUBSPEC = ROOT / "pubspec.yaml"

INPUT_EXTENSIONS = {
    ".m4a", ".mp3", ".wav", ".aac", ".ogg", ".opus", ".flac", ".amr",
    ".3gp", ".caf", ".aiff", ".aif", ".mp4", ".webm", ".wma",
}
EXAMPLE_SUFFIX = "_exemple"
MARGIN_SECONDS = 0.25
SILENCE_THRESHOLD = "-45dB"
MAX_SECONDS = 15.0

# Trims the start, then the end (by reversing the sound), keeping a margin,
# then evens the volume out.
FILTER = ",".join(
    [
        f"silenceremove=start_periods=1:start_threshold={SILENCE_THRESHOLD}"
        f":start_silence={MARGIN_SECONDS}",
        "areverse",
        f"silenceremove=start_periods=1:start_threshold={SILENCE_THRESHOLD}"
        f":start_silence={MARGIN_SECONDS}",
        "areverse",
        "loudnorm=I=-16:TP=-1.5:LRA=11",
    ]
)


def load_keys():
    """Every word key of the content asset."""
    words = json.loads(WORDS.read_text(encoding="utf-8"))["words"]
    return [word["key"] for word in words]


def classify(stem, language, keys):
    """('key', 'explanation'|'example') for a file stem, or None."""
    stem = stem.lower()
    prefix = f"{language}_"
    if not stem.startswith(prefix):
        return None
    name = stem[len(prefix):]
    if name in keys:
        return name, "explanation"
    if name.endswith(EXAMPLE_SUFFIX) and name[: -len(EXAMPLE_SUFFIX)] in keys:
        return name[: -len(EXAMPLE_SUFFIX)], "example"
    return None


def scan(input_dir, language, keys):
    """(found {(key, kind): path}, unrecognized [path], duplicates [str])."""
    found = {}
    unrecognized = []
    duplicates = []
    for path in sorted(input_dir.iterdir()):
        if not path.is_file() or path.name.startswith("."):
            continue
        if path.suffix.lower() not in INPUT_EXTENSIONS:
            unrecognized.append(path)
            continue
        slot = classify(path.stem, language, keys)
        if slot is None:
            unrecognized.append(path)
        elif slot in found:
            duplicates.append(f"{slot[0]} ({slot[1]}): {found[slot].name}, {path.name}")
        else:
            found[slot] = path
    return found, unrecognized, duplicates


def missing(found, keys):
    """The (key, kind) slots no file fills, in table order."""
    return [
        (key, kind)
        for key in keys
        for kind in ("explanation", "example")
        if (key, kind) not in found
    ]


def file_name(language, key, kind):
    suffix = EXAMPLE_SUFFIX if kind == "example" else ""
    return f"{language}_{key}{suffix}.m4a"


def present_in(output, language, keys):
    """The (key, kind) slots whose converted file is in the output folder."""
    return {
        (key, kind)
        for key in keys
        for kind in ("explanation", "example")
        if (output / file_name(language, key, kind)).exists()
    }


def build_manifest(language, keys, present):
    """The manifest dict for the slots in `present`."""
    words = {}
    for key in keys:
        entry = {
            kind: file_name(language, key, kind)
            for kind in ("explanation", "example")
            if (key, kind) in present
        }
        if entry:
            words[key] = entry
    return {"language": language, "format": "m4a", "words": words}


def convert(source, target):
    """Trims, normalises and converts one file; returns its duration."""
    subprocess.run(
        [
            "ffmpeg", "-y", "-loglevel", "error", "-i", str(source),
            "-vn", "-af", FILTER, "-ac", "1", "-ar", "32000",
            "-c:a", "aac", "-b:a", "48k", "-movflags", "+faststart",
            str(target),
        ],
        check=True,
    )
    probe = subprocess.run(
        [
            "ffprobe", "-v", "error", "-show_entries", "format=duration",
            "-of", "default=nw=1:nk=1", str(target),
        ],
        check=True, capture_output=True, text=True,
    )
    return float(probe.stdout.strip() or 0)


def register_language(language, output):
    """Lists the language in packs.json; warns when pubspec lacks its folder."""
    index = output.parent / "packs.json"
    languages = []
    if index.exists():
        languages = json.loads(index.read_text(encoding="utf-8"))["languages"]
    if language not in languages:
        languages.append(language)
        index.write_text(
            json.dumps({"languages": languages}, indent=2) + "\n", encoding="utf-8"
        )
    declared = f"- assets/audio/{output.name}/"
    if output.parent == PACKS and declared not in PUBSPEC.read_text(
        encoding="utf-8"
    ):
        print(f"add '{declared}' to the assets of pubspec.yaml")


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("input_dir", type=Path)
    parser.add_argument("--language", default="wo")
    parser.add_argument("--output", type=Path)
    parser.add_argument("--check", action="store_true",
                        help="only check the names and the missing files")
    args = parser.parse_args()
    keys = load_keys()
    output = args.output or PACKS / args.language
    if output.resolve() == args.input_dir.resolve():
        raise SystemExit("the input folder and the output folder must differ")
    found, unrecognized, duplicates = scan(args.input_dir, args.language, keys)
    for path in unrecognized:
        print(f"not recognized: {path.name}")
    for text in duplicates:
        print(f"two files for {text}")
    if not args.check:
        if shutil.which("ffmpeg") is None or shutil.which("ffprobe") is None:
            raise SystemExit("ffmpeg and ffprobe are needed: brew install ffmpeg")
        output.mkdir(parents=True, exist_ok=True)
        for (key, kind), source in found.items():
            target = output / file_name(args.language, key, kind)
            seconds = convert(source, target)
            note = " (long: shorten it)" if seconds > MAX_SECONDS else ""
            print(f"{source.name} -> {target.name}  {seconds:.1f} s{note}")
        # The pack is what the output folder holds, so a second partial
        # delivery adds to the first instead of erasing it.
        found = {slot: None for slot in present_in(output, args.language, keys)}
        manifest = build_manifest(args.language, keys, set(found))
        (output / "manifest.json").write_text(
            json.dumps(manifest, indent=2) + "\n", encoding="utf-8"
        )
        register_language(args.language, output)
    gaps = missing(found, keys)
    for key, kind in gaps:
        print(f"missing: {file_name(args.language, key, kind)}")
    print(f"{len(found)} of {2 * len(keys)} files, {len(gaps)} missing")
    if gaps or unrecognized or duplicates:
        sys.exit(1)


if __name__ == "__main__":
    main()

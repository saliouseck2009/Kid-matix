"""Prepares the recordings of a help language for the app (lot F28).

Takes the folder the owner delivered (any audio format: .m4a, .mp3, .wav,
.aac, .ogg, .opus, .flac, .amr, .3gp, .caf, .aiff; the extension is the one
of the recorder, never renamed) and writes the language pack of the app:

  assets/audio/<language>/wo_<key>.m4a            the explanation of a word
  assets/audio/<language>/wo_<key>_exemple.m4a    its example
  assets/audio/<language>/wo_problem_<key>.m4a    the statement of a problem
  assets/audio/<language>/manifest.json           what the pack holds
                                                  ("provisional": the file names
                                                  converted with --provisional)
  assets/audio/packs.json                         the list of languages

For each file it trims the silence at the start and at the end, keeping a
short margin, evens the volume out, and converts to mono AAC (32 kHz,
48 kbit/s, about 6 KB per second). It then checks that every key of
assets/math_words/math_words.json has its two files, that every problem of
docs/product/problems.md has its one file (no example), and lists what is
missing. The manifest only holds the files that exist: the app hides the
button of a missing file.

Needs ffmpeg and ffprobe on the PATH (brew install ffmpeg). No Dart
package is involved.

Usage:
  python3 tool/process_audio.py INPUT_DIR [--language wo] [--output DIR]
  python3 tool/process_audio.py INPUT_DIR --check     names only, no ffmpeg
  python3 tool/process_audio.py INPUT_DIR --provisional   mark the pack as
      machine-made stand-ins (tool/placeholder_audio/): their names go in
      the manifest, the app shows a notice to adults and does not offer them
      to a child who never chose. It never overwrites a file that is not
      marked provisional, and fails on a file over 15 s. A later run without
      the option removes the names of the files it converts, and the list
      goes away when none is left.

The file names keep the language code as a prefix (`wo_`), so the guide and
the table stay the reference. Exit status 1 when a file is missing or not
recognized.
"""

import argparse
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
WORDS = ROOT / "assets" / "math_words" / "math_words.json"
PROBLEMS = ROOT / "docs" / "product" / "problems.md"
PACKS = ROOT / "assets" / "audio"
PUBSPEC = ROOT / "pubspec.yaml"

INPUT_EXTENSIONS = {
    ".m4a", ".mp3", ".wav", ".aac", ".ogg", ".opus", ".flac", ".amr",
    ".3gp", ".caf", ".aiff", ".aif", ".mp4", ".webm", ".wma",
}
EXAMPLE_SUFFIX = "_exemple"
PROBLEM_PREFIX = "problem_"
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


def load_problem_keys():
    """The key of every problem of the content table, in table order.

    A problem is recorded once, as wo_problem_<key>.m4a: its audio column
    names the file, so the keys are read from there.
    """
    text = PROBLEMS.read_text(encoding="utf-8")
    keys = []
    for key in re.findall(r"wo_problem_([a-z_]+)\.m4a", text):
        if key not in keys:
            keys.append(key)
    return keys


def slots(keys, problem_keys=()):
    """Every (key, kind) a complete pack holds: both recordings of a word,
    the statement of a problem (named problem_<key>, no example)."""
    result = [(key, kind) for key in keys for kind in ("explanation", "example")]
    result += [(PROBLEM_PREFIX + key, "explanation") for key in problem_keys]
    return result


def classify(stem, language, keys, problem_keys=()):
    """('key', 'explanation'|'example') for a file stem, or None."""
    stem = stem.lower()
    prefix = f"{language}_"
    if not stem.startswith(prefix):
        return None
    name = stem[len(prefix):]
    if name.startswith(PROBLEM_PREFIX):
        if name[len(PROBLEM_PREFIX):] in problem_keys:
            return name, "explanation"
        return None
    if name in keys:
        return name, "explanation"
    if name.endswith(EXAMPLE_SUFFIX) and name[: -len(EXAMPLE_SUFFIX)] in keys:
        return name[: -len(EXAMPLE_SUFFIX)], "example"
    return None


def scan(input_dir, language, keys, problem_keys=()):
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
        slot = classify(path.stem, language, keys, problem_keys)
        if slot is None:
            unrecognized.append(path)
        elif slot in found:
            duplicates.append(f"{slot[0]} ({slot[1]}): {found[slot].name}, {path.name}")
        else:
            found[slot] = path
    return found, unrecognized, duplicates


def missing(found, keys, problem_keys=()):
    """The (key, kind) slots no file fills, in table order."""
    return [slot for slot in slots(keys, problem_keys) if slot not in found]


def file_name(language, key, kind):
    suffix = EXAMPLE_SUFFIX if kind == "example" else ""
    return f"{language}_{key}{suffix}.m4a"


def present_in(output, language, keys, problem_keys=()):
    """The (key, kind) slots whose converted file is in the output folder."""
    return {
        (key, kind)
        for key, kind in slots(keys, problem_keys)
        if (output / file_name(language, key, kind)).exists()
    }


def build_manifest(language, keys, present, problem_keys=(), provisional=()):
    """The manifest dict for the slots in `present`.

    `provisional` is the set of file names that are machine-made stand-ins;
    when not empty it is written as a sorted list (the app treats a pack
    with a non-empty list as provisional), otherwise the key is omitted.
    """
    words = {}
    for key, kind in slots(keys, problem_keys):
        if (key, kind) in present:
            words.setdefault(key, {})[kind] = file_name(language, key, kind)
    manifest = {"language": language, "format": "m4a"}
    if provisional:
        manifest["provisional"] = sorted(provisional)
    manifest["words"] = words
    return manifest


def read_provisional(output):
    """The file names the manifest already in `output` marks as provisional.

    An old manifest with `"provisional": true` counts every file it lists.
    """
    manifest = output / "manifest.json"
    if not manifest.exists():
        return set()
    try:
        data = json.loads(manifest.read_text(encoding="utf-8"))
        flag = data.get("provisional")
        if flag is True:
            return {
                name for kinds in data.get("words", {}).values() for name in kinds.values()
            }
        if isinstance(flag, list):
            return {name for name in flag if isinstance(name, str)}
    except (ValueError, AttributeError):
        pass
    return set()


def provisional_after(requested, previous, converted, present):
    """The provisional file names of the new manifest.

    A run with --provisional adds the files it converted; a run without it
    removes them (they are real now); the files it did not touch keep their
    status, so two partial deliveries of real recordings clear the list
    only when together they replace every stand-in. Only files that are in
    the pack are listed.
    """
    names = set(previous) - set(converted)
    if requested:
        names |= set(converted)
    return names & set(present)


def refused_overwrites(requested, previous, targets):
    """The existing files a --provisional run would overwrite although they
    are not marked provisional (real recordings must never be replaced by
    stand-ins)."""
    if not requested:
        return []
    return [t for t in targets if t.exists() and t.name not in previous]


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
    parser.add_argument("--provisional", action="store_true",
                        help="flag the pack as machine-made stand-ins")
    parser.add_argument("--check", action="store_true",
                        help="only check the names and the missing files")
    args = parser.parse_args()
    keys = load_keys()
    problem_keys = load_problem_keys()
    output = args.output or PACKS / args.language
    if output.resolve() == args.input_dir.resolve():
        raise SystemExit("the input folder and the output folder must differ")
    found, unrecognized, duplicates = scan(args.input_dir, args.language, keys, problem_keys)
    for path in unrecognized:
        print(f"not recognized: {path.name}")
    for text in duplicates:
        print(f"two files for {text}")
    if not args.check:
        if shutil.which("ffmpeg") is None or shutil.which("ffprobe") is None:
            raise SystemExit("ffmpeg and ffprobe are needed: brew install ffmpeg")
        output.mkdir(parents=True, exist_ok=True)
        previous = read_provisional(output)
        converted = set(found)
        targets = {
            slot: output / file_name(args.language, *slot) for slot in found
        }
        protected = refused_overwrites(args.provisional, previous, targets.values())
        if protected:
            for target in protected:
                print(f"refused: {target.name} is not provisional", file=sys.stderr)
            raise SystemExit("--provisional never overwrites a real recording")
        too_long = []
        for slot, source in found.items():
            target = targets[slot]
            seconds = convert(source, target)
            note = " (long: shorten it)" if seconds > MAX_SECONDS else ""
            print(f"{source.name} -> {target.name}  {seconds:.1f} s{note}")
            if args.provisional and seconds > MAX_SECONDS:
                too_long.append(target)
        if too_long:
            # A stand-in that long is a failed synthesis: drop it so that the
            # next run makes it again.
            for target in too_long:
                target.unlink()
                print(f"failed: {target.name} is over {MAX_SECONDS:.0f} s",
                      file=sys.stderr)
            raise SystemExit(1)
        # The pack is what the output folder holds, so a second partial
        # delivery adds to the first instead of erasing it.
        found = {slot: None for slot in present_in(output, args.language, keys, problem_keys)}
        names = {file_name(args.language, *slot) for slot in found}
        provisional = provisional_after(
            args.provisional,
            previous,
            {file_name(args.language, *slot) for slot in converted},
            names,
        )
        if previous and not provisional:
            print("the pack is no longer provisional")
        elif provisional and not args.provisional:
            print(f"{len(provisional)} files are still stand-ins")
        manifest = build_manifest(
            args.language, keys, set(found), problem_keys, provisional
        )
        (output / "manifest.json").write_text(
            json.dumps(manifest, indent=2) + "\n", encoding="utf-8"
        )
        register_language(args.language, output)
    gaps = missing(found, keys, problem_keys)
    for key, kind in gaps:
        print(f"missing: {file_name(args.language, key, kind)}")
    print(f"{len(found)} of {len(slots(keys, problem_keys))} files, {len(gaps)} missing")
    if gaps or unrecognized or duplicates:
        sys.exit(1)


if __name__ == "__main__":
    main()

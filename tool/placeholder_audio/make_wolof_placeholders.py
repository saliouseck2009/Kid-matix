"""Builds the provisional, machine-made Wolof audio of Kid Matix.

The Wolof text and the voice here are produced by machines and never
reviewed: the text by Google Translate (deep-translator), the voice by Meta
MMS (facebook/mms-tts-wol, licence CC-BY-NC 4.0). They stand in for the
owner's real recordings so that the Wolof buttons and « Aide audio » can be
tried on a device. Replace them before any release (see
docs/product/audio-recording.md, « Fichiers provisoires »).

Steps, each one resumable (what is already made is skipped):

  1. extract    the French explanation and example of the 40 words
                (docs/product/math-words.md) and the French statement of the
                30 problems (docs/product/problems.md);
  2. translate  French -> Wolof, cached in wolof_machine.json (committed:
                a re-run needs no network);
  3. tables     the Wolof cells of both tables, each marked
                « (machine, à relire) », and a status line at the top;
  4. speak      one 16 kHz wav per text, with the MMS Wolof model (CPU);
  5. pack       tool/process_audio.py on the wav folder with --provisional,
                then tool/build_math_words.py.

Run it inside the virtualenv of this folder (see README.md):

  python make_wolof_placeholders.py                 every step
  python make_wolof_placeholders.py --until tables  translation only
  python make_wolof_placeholders.py --from speak    voice and pack only

Numbers are spelled in French before the translation (« 12 » becomes
« douze »): the voice cannot read digits. The mark « (machine, à relire) »
is never spoken.
"""

import argparse
import json
import re
import subprocess
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
WORDS_TABLE = ROOT / "docs" / "product" / "math-words.md"
PROBLEMS_TABLE = ROOT / "docs" / "product" / "problems.md"
CACHE = HERE / "wolof_machine.json"
WAV_DIR = HERE / "build" / "wav"

MODEL = "facebook/mms-tts-wol"
MODEL_PAGE = f"https://huggingface.co/{MODEL}"
SPEAKING_RATE = 0.9  # a little slower than the model default, for children
SEED = 0
MARK = " (machine, à relire)"
STATUS_PREFIX = "Wolof provisoire :"
STATUS_LINE = (
    f"{STATUS_PREFIX} les colonnes en wolof sont un texte provisoire, traduit "
    "par une machine (Google Translate) et non relu ; chaque cellule porte la "
    "mention « (machine, à relire) ». Les voix sont une synthèse automatique "
    "(Meta MMS) à remplacer par de vrais enregistrements (voir "
    "`tool/placeholder_audio/README.md` et `docs/product/audio-recording.md`)."
)
STEPS = ["extract", "translate", "tables", "speak", "pack"]


# ---------------------------------------------------------------- tables


def cells(line):
    """The cells of one table row, without the outer bars."""
    return [cell.strip() for cell in line.strip().strip("|").split("|")]


def is_row(line):
    return line.startswith("|") and not line.startswith("| ---")


def spell_numbers(text):
    """Writes the digits of [text] in French letters: the voice has no digits."""
    from num2words import num2words

    return re.sub(r"\d+", lambda m: num2words(int(m.group()), lang="fr"), text)


def word_rows(markdown):
    """Yields (line number, cells) for the rows of the words tables."""
    section = family = False
    for number, line in enumerate(markdown.splitlines()):
        if line.startswith("## "):
            section = line[3:].strip().startswith("1.")
            family = False
        elif line.startswith("### "):
            family = True
        elif section and family and is_row(line):
            row = cells(line)
            if len(row) >= 8 and row[0] != "Clé":
                yield number, row


def problem_rows(markdown):
    """Yields (line number, cells) for the rows of the statement tables."""
    for number, line in enumerate(markdown.splitlines()):
        if is_row(line):
            row = cells(line)
            if len(row) == 12 and row[0] != "Clé":
                yield number, row


def extract_words(markdown):
    """[(id, french)]: the explanation and the example of every word."""
    items = []
    for _, row in word_rows(markdown):
        key = row[0].strip("`")
        items.append((f"wo_{key}", row[2]))
        items.append((f"wo_{key}_exemple", row[4]))
    return items


def extract_problems(markdown):
    """[(id, french)]: the statement of every problem."""
    return [
        (f"wo_problem_{row[0].strip('`')}", row[9])
        for _, row in problem_rows(markdown)
    ]


def extract():
    items = extract_words(WORDS_TABLE.read_text(encoding="utf-8"))
    items += extract_problems(PROBLEMS_TABLE.read_text(encoding="utf-8"))
    return items


def with_mark(wolof):
    return wolof.replace("|", "/") + MARK


def is_ours(cell):
    """True for a cell this script may write: empty or already machine-made.
    A cell the owner wrote by hand is never touched."""
    return cell == "" or cell.endswith(MARK)


def fill(markdown, rows, columns_of, wolof_of):
    """The table text with the Wolof cells of [rows] filled.

    columns_of(row) lists (column, id) pairs to fill.
    """
    lines = markdown.splitlines()
    for number, row in rows:
        changed = False
        for column, name in columns_of(row):
            if name in wolof_of and is_ours(row[column]):
                row[column] = with_mark(wolof_of[name])
                changed = True
        if changed:
            lines[number] = "| " + " | ".join(row) + " |"
    return "\n".join(lines) + "\n"


def rewrite_words(markdown, wolof_of):
    """The words table with the Wolof columns (6 and 7) filled."""

    def columns(row):
        key = row[0].strip("`")
        return [(6, f"wo_{key}"), (7, f"wo_{key}_exemple")]

    return fill(markdown, list(word_rows(markdown)), columns, wolof_of)


def rewrite_problems(markdown, wolof_of):
    """The statement tables with the « Wolof : énoncé » column (10) filled."""

    def columns(row):
        return [(10, f"wo_problem_{row[0].strip('`')}")]

    return fill(markdown, list(problem_rows(markdown)), columns, wolof_of)


def with_status(markdown):
    """Puts the provisional-Wolof status line right under the status line."""
    lines = []
    for line in markdown.splitlines():
        if line.startswith(STATUS_PREFIX):
            # Also drop the blank line a previous run put before it.
            if lines and lines[-1] == "":
                lines.pop()
            continue
        lines.append(line)
    for index, line in enumerate(lines):
        if line.startswith("Statut :"):
            lines[index + 1 : index + 1] = ["", STATUS_LINE]
            break
    else:
        lines[1:1] = ["", STATUS_LINE]
    return "\n".join(lines) + "\n"


# ------------------------------------------------------------- translate


def load_cache():
    if CACHE.exists():
        return json.loads(CACHE.read_text(encoding="utf-8"))
    return {}


def save_cache(cache):
    CACHE.write_text(
        json.dumps(cache, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


def french_to_wolof():
    """GoogleTranslator(source='fr', target='wo').

    deep-translator checks the target against a list of languages that does
    not hold Wolof, although Google Translate serves it: when the check
    refuses « wo », the translator is built for another target and its
    target code is set afterwards.
    """
    from deep_translator import GoogleTranslator
    from deep_translator.exceptions import LanguageNotSupportedException

    try:
        return GoogleTranslator(source="fr", target="wo")
    except LanguageNotSupportedException:
        translator = GoogleTranslator(source="fr", target="en")
        translator._target = "wo"  # noqa: SLF001 - see the docstring
        return translator


def translate(items):
    """Fills the cache; returns {id: wolof}. Stops with a message when the
    translator refuses."""
    cache = load_cache()
    translator = None
    for name, french in items:
        source = spell_numbers(french)
        entry = cache.get(name)
        if entry and entry.get("fr") == source and entry.get("wo"):
            continue
        if translator is None:
            translator = french_to_wolof()
        wolof = None
        for attempt in range(4):
            try:
                wolof = translator.translate(source)
                break
            except Exception as error:  # noqa: BLE001 - network or quota
                print(f"  {name}: {error}; retry {attempt + 1}/3", file=sys.stderr)
                time.sleep(2 * (attempt + 1))
        if not wolof:
            save_cache(cache)
            raise SystemExit(
                f"Google Translate refused {name}: the pipeline stops here. "
                "Re-run later; what is translated is kept in wolof_machine.json."
            )
        if wolof.strip().lower() == source.lower():
            print(f"  {name}: the translation equals the French text", file=sys.stderr)
        cache[name] = {"fr": source, "wo": wolof.strip()}
        print(f"translated {name}")
        time.sleep(0.3)
    save_cache(cache)
    return {name: cache[name]["wo"] for name, _ in items}


# ----------------------------------------------------------------- speak

TOKEN_HELP = f"""\
The Wolof voice needs a Hugging Face account, because the model is gated:
  1. Create an account at https://huggingface.co/join
  2. Open {MODEL_PAGE} and accept the licence (CC-BY-NC 4.0).
  3. Run:  huggingface-cli login   (newer versions: hf auth login)
     or:   export HF_TOKEN=<your token>
Then run this script again: it resumes where it stopped."""


def hugging_face_token():
    from huggingface_hub import get_token

    token = get_token()
    if not token:
        raise SystemExit(TOKEN_HELP)
    return token


def speak(wolof_of):
    """Writes one wav per text, skipping the ones that exist."""
    todo = [name for name in wolof_of if not (WAV_DIR / f"{name}.wav").exists()]
    if not todo:
        print("all wav files exist")
        return
    token = hugging_face_token()
    import numpy
    import torch
    from scipy.io import wavfile
    from transformers import AutoTokenizer, VitsModel

    try:
        tokenizer = AutoTokenizer.from_pretrained(MODEL, token=token)
        model = VitsModel.from_pretrained(MODEL, token=token)
    except OSError as error:
        raise SystemExit(f"{error}\n\n{TOKEN_HELP}") from error
    model.speaking_rate = SPEAKING_RATE
    model.eval()
    WAV_DIR.mkdir(parents=True, exist_ok=True)
    for number, name in enumerate(todo, start=1):
        inputs = tokenizer(wolof_of[name], return_tensors="pt")
        if inputs["input_ids"].shape[-1] == 0:
            print(f"skipped {name}: nothing the voice can read", file=sys.stderr)
            continue
        torch.manual_seed(SEED)  # same text, same voice
        with torch.no_grad():
            wave = model(**inputs).waveform[0].numpy()
        pcm = (numpy.clip(wave, -1.0, 1.0) * 32767).astype("int16")
        wavfile.write(WAV_DIR / f"{name}.wav", model.config.sampling_rate, pcm)
        print(f"[{number}/{len(todo)}] {name}.wav")


# ------------------------------------------------------------------ pack


def pack():
    subprocess.run(
        [
            sys.executable, str(ROOT / "tool" / "process_audio.py"),
            str(WAV_DIR), "--provisional",
        ],
        check=True,
    )
    subprocess.run(
        [sys.executable, str(ROOT / "tool" / "build_math_words.py")], check=True
    )


# ------------------------------------------------------------------ main


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--from", dest="first", choices=STEPS, default=STEPS[0])
    parser.add_argument("--until", dest="last", choices=STEPS, default=STEPS[-1])
    args = parser.parse_args()
    wanted = STEPS[STEPS.index(args.first) : STEPS.index(args.last) + 1]

    items = extract()
    problems = sum(name.startswith("wo_problem_") for name, _ in items)
    print(f"{len(items)} texts ({problems} problems)")
    if "translate" in wanted:
        wolof_of = translate(items)
    else:
        cache = load_cache()
        wolof_of = {name: cache[name]["wo"] for name, _ in items if name in cache}
    if "tables" in wanted:
        words = rewrite_words(WORDS_TABLE.read_text(encoding="utf-8"), wolof_of)
        WORDS_TABLE.write_text(with_status(words), encoding="utf-8")
        statements = rewrite_problems(
            PROBLEMS_TABLE.read_text(encoding="utf-8"), wolof_of
        )
        PROBLEMS_TABLE.write_text(with_status(statements), encoding="utf-8")
        print("tables written")
    if "speak" in wanted:
        speak(wolof_of)
    if "pack" in wanted:
        pack()


if __name__ == "__main__":
    main()

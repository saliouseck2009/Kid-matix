"""Builds the provisional, machine-made Wolof audio of Kid Matix.

The Wolof text and the voice here are produced by machines and never
reviewed: the text by Meta NLLB-200 (CC-BY-NC 4.0), the voice by Meta
MMS Wolof, exported to ONNX (jaguaman09/mms-tts-wol-onnx, a public model,
licence CC-BY-NC 4.0: no account, no token). They stand in for the
owner's real recordings so that the Wolof buttons and « Aide audio » can be
tried on a device. Replace them before any release (see
docs/product/audio-recording.md, « Fichiers provisoires »).

Steps, each one resumable (what is already made is skipped):

  1. extract    the French explanation and example of the 40 words
                (docs/product/math-words.md) and the French statement of the
                30 problems (docs/product/problems.md);
  2. translate  French -> Wolof with Meta NLLB-200 (offline CTranslate2
                model), or from a Wolof file made by hand with
                --engine file --wolof FILE (see --print-french), cached in
                wolof_machine.json (committed: a re-run needs no network
                for the text);
  3. tables     the Wolof cells of both tables, each marked
                « (machine, à relire) », and a status line at the top;
  4. speak      one 16 kHz wav per text, with the MMS Wolof model
                (onnxruntime on the CPU, no torch);
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
import unicodedata
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
WORDS_TABLE = ROOT / "docs" / "product" / "math-words.md"
PROBLEMS_TABLE = ROOT / "docs" / "product" / "problems.md"
CACHE = HERE / "wolof_machine.json"
WAV_DIR = HERE / "build" / "wav"

MODEL_REPO = "jaguaman09/mms-tts-wol-onnx"  # public, CC-BY-NC 4.0
MODEL_REVISION = "3dcd72ae874e75d6c85bff18f8de3b20cf122477"
MODEL_DIR = HERE / "build" / "model"
MODEL_FILES = {
    "model.onnx": "onnx/model.onnx",
    "vocab.json": "vocab.json",
    "config.json": "config.json",
}
MARKS = {"nllb": " (machine, à relire)", "google-web": " (Google, à relire)"}
STATUS_PREFIX = "Wolof provisoire :"
STATUS_LINE = (
    f"{STATUS_PREFIX} les colonnes en wolof sont un texte provisoire, traduit "
    "par une machine (Meta NLLB-200 ou Google Translate) et non relu ; "
    "chaque cellule porte la mention « (machine, à relire) » ou "
    "« (Google, à relire) ». Les voix sont une synthèse automatique "
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


def with_mark(wolof, engine="nllb"):
    return wolof.replace("|", "/") + MARKS[engine]


def is_ours(cell):
    """True for a cell this script may write: empty or already machine-made
    (either mark). A cell the owner wrote by hand is never touched."""
    return cell == "" or cell.endswith(tuple(MARKS.values()))


def fill(markdown, rows, columns_of, wolof_of):
    """The table text with the Wolof cells of [rows] filled.

    columns_of(row) lists (column, id) pairs to fill; wolof_of maps an id to
    its cache entry ({"wo": text, "engine": engine}).
    """
    lines = markdown.splitlines()
    for number, row in rows:
        changed = False
        for column, name in columns_of(row):
            if name in wolof_of and is_ours(row[column]):
                row[column] = with_mark(wolof_of[name]["wo"], wolof_of[name]["engine"])
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
        if re.match(r"Statut\s:", line):
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


NLLB_REPO = "JustFrederik/nllb-200-distilled-600M-ct2-int8"  # public, CC-BY-NC 4.0
NLLB_REVISION = "302d78f00e6fdb50a1064059df7c392b735e9d05"
NLLB_FILES = ["model.bin", "config.json", "shared_vocabulary.txt", "sentencepiece.bpe.model"]
NLLB_DIR = HERE / "build" / "nllb"

# The model sometimes loops on one token (« Sëriñ » 64 times): decode with a
# repetition penalty and refuse such an output.
REPETITION_PENALTY = 1.2
NO_REPEAT_NGRAM = 3
MAX_LENGTH_RATIO = 3  # an output longer than 3 times the source is a loop
MAX_TOKEN_REPEATS = 3
RETRY_PENALTIES = (REPETITION_PENALTY, 1.5, 2.0)


def looks_wrong(source, output):
    """Why [output] cannot be a translation of [source], or None.

    Catches the loops of the model: an output over three times as long as
    the source, a word repeated more than three times in a row or in all.
    """
    if not output.strip():
        return "empty"
    if len(output) > MAX_LENGTH_RATIO * max(len(source), 20):
        return "too long"
    words = re.findall(r"\w+", output.lower())
    for word in set(words):
        if len(word) > 2 and words.count(word) > MAX_TOKEN_REPEATS + 1:
            return f"repeats {word!r}"
    for index in range(len(words) - MAX_TOKEN_REPEATS):
        window = words[index : index + MAX_TOKEN_REPEATS + 1]
        if len(set(window)) == 1:
            return f"repeats {window[0]!r}"
    return None


def download(repo, revision, name, folder):
    """Fetches one file of a public Hugging Face repository at a pinned
    revision, once (no account needed)."""
    import requests

    folder.mkdir(parents=True, exist_ok=True)
    target = folder / Path(name).name
    if target.exists() and target.stat().st_size > 0:
        return
    print(f"downloading {repo}@{revision[:7]}/{name} ...")
    url = f"https://huggingface.co/{repo}/resolve/{revision}/{name}"
    partial = target.with_suffix(target.suffix + ".part")
    with requests.get(url, stream=True, timeout=60) as r:
        r.raise_for_status()
        with partial.open("wb") as out:
            for chunk in r.iter_content(1 << 20):
                out.write(chunk)
    partial.rename(target)


class Nllb:
    """Meta NLLB-200 (distilled 600M, int8 CTranslate2 conversion), offline."""

    def __init__(self):
        import ctranslate2
        import sentencepiece

        for name in NLLB_FILES:
            download(NLLB_REPO, NLLB_REVISION, name, NLLB_DIR)
        self._model = ctranslate2.Translator(str(NLLB_DIR), device="cpu")
        self._sp = sentencepiece.SentencePieceProcessor(
            str(NLLB_DIR / "sentencepiece.bpe.model")
        )

    def translate(self, text, source="fra_Latn", target="wol_Latn", penalty=REPETITION_PENALTY):
        tokens = [source] + self._sp.encode(text, out_type=str) + ["</s>"]
        result = self._model.translate_batch(
            [tokens],
            target_prefix=[[target]],
            beam_size=4,
            max_decoding_length=min(200, 3 * len(tokens) + 10),
            repetition_penalty=penalty,
            no_repeat_ngram_size=NO_REPEAT_NGRAM,
        )
        return self._sp.decode(result[0].hypotheses[0][1:]).strip()

    def back(self, text):
        """Wolof back to French, to judge a translation."""
        return self.translate(text, source="wol_Latn", target="fra_Latn")

    def french_to_wolof(self, text):
        """Wolof for [text]; a looping output is decoded again with a
        stronger repetition penalty, and refused when it still loops."""
        why = None
        for penalty in RETRY_PENALTIES:
            wolof = self.translate(text, penalty=penalty)
            why = looks_wrong(text, wolof)
            if why is None:
                return wolof
            print(f"  rejected ({why}), penalty {penalty}", file=sys.stderr)
        raise ValueError(f"no usable translation: {why}")


def translate(items, translate_text, engine="nllb", force=False):
    """Fills the cache; returns {id: entry} with entry = {fr, wo, engine}.

    translate_text(french) -> wolof. Stops with a message naming the text
    when it cannot translate one; what is done stays in the cache.
    """
    cache = load_cache()
    for name, french in items:
        source = spell_numbers(french)
        entry = cache.get(name)
        looping = (
            entry is not None
            and entry.get("engine") == "nllb"
            and looks_wrong(source, entry.get("wo", "")) is not None
        )
        if (
            not force
            and not looping
            and entry
            and entry.get("fr") == source
            and entry.get("wo")
        ):
            continue
        try:
            wolof = translate_text(source)
        except Exception as error:  # noqa: BLE001 - reported with the name
            save_cache(cache)
            raise SystemExit(
                f"{name}: {error}. The pipeline stops here; what is done is "
                "kept in wolof_machine.json."
            ) from error
        if wolof.strip().lower() == source.lower():
            print(f"  {name}: the translation equals the French text", file=sys.stderr)
        cache[name] = {"fr": source, "wo": wolof.strip(), "engine": engine}
        print(f"translated {name}")
    save_cache(cache)
    return {name: cache[name] for name, _ in items}


def read_wolof_file(path, items):
    """The Wolof lines of a hand-made file, in the pack order.

    The owner pastes the French texts into translate.google.com by hand and
    pastes the Wolof back, one line per text; exactly len(items) lines, none
    blank. Returns [wolof] in the order of [items].
    """
    lines = [l.strip() for l in Path(path).read_text(encoding="utf-8").splitlines()]
    while lines and lines[-1] == "":
        lines.pop()
    if len(lines) != len(items):
        raise SystemExit(
            f"{path} has {len(lines)} lines, {len(items)} are expected: one "
            "per text, the word texts in math-words.md order (explanation, "
            "then example) then the problems in problems.md order."
        )
    blank = [str(number) for number, line in enumerate(lines, 1) if not line]
    if blank:
        raise SystemExit(f"{path}: blank line(s) {', '.join(blank)}")
    return lines


def translate_from_file(items, path):
    """Fills the cache from a hand-made Wolof file (engine google-web)."""
    wolof = read_wolof_file(path, items)
    cache = load_cache()
    for (name, french), text in zip(items, wolof):
        cache[name] = {"fr": spell_numbers(french), "wo": text, "engine": "google-web"}
    save_cache(cache)
    print(f"{len(wolof)} texts read from {path}")
    return {name: cache[name] for name, _ in items}


def french_texts(items):
    """The French texts to paste into the translator, one per line, in the
    order read_wolof_file expects."""
    return "\n".join(french for _, french in items)


def back_translate(count):
    """Prints [count] evenly spread translations with their back-translation
    to French (NLLB), so that the quality can be judged."""
    cache = load_cache()
    names = sorted(cache)
    step = max(1, len(names) // count)
    model = Nllb()
    for name in names[::step][:count]:
        entry = cache[name]
        print(f"{name}\n  FR   {entry['fr']}\n  WO   {entry['wo']}\n"
              f"  BACK {model.back(entry['wo'])}")


# ----------------------------------------------------------------- speak


def download_model():
    for name, remote in MODEL_FILES.items():
        download(MODEL_REPO, MODEL_REVISION, remote, MODEL_DIR)


# ----------------------------------------------------------------- speak


def token_ids(text, vocab):
    """The ids the voice reads for [text], as the MMS tokenizer builds them:
    lower case, only characters of the vocabulary, a blank (0) between and
    around them.

    The vocabulary has no é, ë, à, ó or ñ: such a letter is read without its
    mark (ñ as n); anything else unknown is dropped.
    """
    ids = [0]
    for char in text.lower().replace("’", "'"):
        if char not in vocab:
            plain = unicodedata.normalize("NFD", char)
            char = "".join(c for c in plain if not unicodedata.combining(c))
        for one in char:
            if one in vocab and one != "|":
                ids += [vocab[one], 0]
    return ids if len(ids) > 1 else []


def _note(name):
    # Hidden, so that process_audio.py does not list it as an unknown file.
    return WAV_DIR / f".{name}.txt"


def wav_is_current(name, text):
    """Whether the wav of [name] was made from [text]: a hidden
    `.<name>.txt` next to it holds the text it was spoken from."""
    wav = WAV_DIR / f"{name}.wav"
    note = _note(name)
    return wav.exists() and note.exists() and note.read_text(encoding="utf-8") == text


def speak(texts):
    """Writes one wav (and its `.txt`) per text, skipping the ones that
    exist from the same text; a changed text makes its wav again."""
    todo = [name for name, text in texts.items() if not wav_is_current(name, text)]
    if not todo:
        print("all wav files are current")
        return
    download_model()
    import numpy
    import onnxruntime
    from scipy.io import wavfile

    vocab = json.loads((MODEL_DIR / "vocab.json").read_text(encoding="utf-8"))
    rate = json.loads((MODEL_DIR / "config.json").read_text(encoding="utf-8"))[
        "sampling_rate"
    ]
    session = onnxruntime.InferenceSession(
        str(MODEL_DIR / "model.onnx"), providers=["CPUExecutionProvider"]
    )
    WAV_DIR.mkdir(parents=True, exist_ok=True)
    for number, name in enumerate(todo, start=1):
        ids = token_ids(texts[name], vocab)
        if not ids:
            print(f"skipped {name}: nothing the voice can read", file=sys.stderr)
            continue
        batch = numpy.array([ids], dtype=numpy.int64)
        wave = session.run(
            None, {"input_ids": batch, "attention_mask": numpy.ones_like(batch)}
        )[0][0]
        pcm = (numpy.clip(wave, -1.0, 1.0) * 32767).astype("int16")
        wavfile.write(WAV_DIR / f"{name}.wav", rate, pcm)
        _note(name).write_text(texts[name], encoding="utf-8")
        print(f"[{number}/{len(todo)}] {name}.wav {len(pcm) / rate:.1f} s")


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
    parser.add_argument("--engine", choices=["nllb", "file"], default="nllb",
                        help="nllb (default, offline) or file: a Wolof text file "
                        "made by hand with translate.google.com, see --wolof")
    parser.add_argument("--wolof", type=Path, metavar="FILE",
                        help="with --engine file: one Wolof line per text, in "
                        "pack order (see --print-french)")
    parser.add_argument("--print-french", action="store_true",
                        help="print the 110 French texts, one per line, in the "
                        "order --wolof expects, and stop")
    parser.add_argument("--retranslate", action="store_true",
                        help="translate again what the cache already holds")
    parser.add_argument("--back-translate", type=int, metavar="N",
                        help="print N cached translations with their back-translation")
    args = parser.parse_args()
    if args.back_translate:
        back_translate(args.back_translate)
        return
    items = extract()
    if args.print_french:
        print(french_texts([(n, spell_numbers(f)) for n, f in items]))
        return
    wanted = STEPS[STEPS.index(args.first) : STEPS.index(args.last) + 1]
    problems = sum(name.startswith("wo_problem_") for name, _ in items)
    print(f"{len(items)} texts ({problems} problems)")
    if "translate" in wanted:
        if args.engine == "file":
            if args.wolof is None:
                raise SystemExit("--engine file needs --wolof FILE")
            wolof_of = translate_from_file(items, args.wolof)
        else:
            wolof_of = translate(
                items, lambda text: Nllb_instance().french_to_wolof(text),
                "nllb", args.retranslate,
            )
    else:
        cache = load_cache()
        wolof_of = {name: cache[name] for name, _ in items if name in cache}
    if "tables" in wanted:
        words = rewrite_words(WORDS_TABLE.read_text(encoding="utf-8"), wolof_of)
        WORDS_TABLE.write_text(with_status(words), encoding="utf-8")
        statements = rewrite_problems(
            PROBLEMS_TABLE.read_text(encoding="utf-8"), wolof_of
        )
        PROBLEMS_TABLE.write_text(with_status(statements), encoding="utf-8")
        print("tables written")
    if "speak" in wanted:
        speak({name: entry["wo"] for name, entry in wolof_of.items()})
    if "pack" in wanted:
        pack()


_nllb = None


def Nllb_instance():  # noqa: N802 - lazy, so that a cached run loads no model
    global _nllb
    if _nllb is None:
        _nllb = Nllb()
    return _nllb


if __name__ == "__main__":
    main()

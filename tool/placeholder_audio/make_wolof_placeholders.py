"""Builds the provisional, machine-made Wolof audio of Kid Matix.

The source of truth is the Wolof columns of the two content tables
(docs/product/math-words.md, docs/product/problems.md). Their text today
comes from Google Translate, pasted by the owner by hand (--engine file) and
marked « (Google, à relire) »; a cell that is still empty is translated
offline by Meta NLLB-200 (CC-BY-NC 4.0) and marked « (machine, à relire) ».
Nobody who speaks Wolof has reviewed the text. The mark only tracks the
review of the text in the tables: removing it means « text checked », not
« real voice ».

The voice is Meta MMS Wolof exported to ONNX (jaguaman09/mms-tts-wol-onnx,
public, CC-BY-NC 4.0: no account, no token). Everything this script
synthesizes is a stand-in and goes through process_audio.py --provisional:
only process_audio.py run on real recordings takes a file out of the
provisional list of the manifest. Replace the stand-ins before any release
(docs/product/audio-recording.md, « Fichiers provisoires »).

Steps (the usual way to run them is bash tool/placeholder_audio/regenerate.sh):

  1. extract    the French explanation and example of the 40 words and the
                French statement of the 30 problems;
  2. translate  --engine file --wolof FILE imports a hand-made Wolof file
                (see --print-french); otherwise NLLB fills the empty cells;
  3. tables     the status line at the top of each table (only while a cell
                carries a mark);
  4. speak      one 16 kHz wav per text, with the MMS Wolof model
                (onnxruntime on the CPU, no torch); the text is the cell
                without its mark and without the words of rules.txt; only
                the cells whose spoken text changed are spoken again;
  5. pack       tool/process_audio.py --provisional on the changed wavs,
                then tool/build_math_words.py.

  python make_wolof_placeholders.py                 every step
  python make_wolof_placeholders.py --until tables  translation only
  python make_wolof_placeholders.py --from speak    voice and pack only

Numbers are spelled in French before an NLLB translation (« 12 » becomes
« douze »); a text typed or pasted in a cell is spoken as it is (whether the
voice reads digits is not verified). The marks are never spoken.
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
RULES = HERE / "rules.txt"
CONVERTED_DIR = HERE / "build" / "converted"
STAGE_DIR = HERE / "build" / "stage"
PACK_DIR = ROOT / "assets" / "audio" / "wo"
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


def fill(markdown, rows, columns_of, wolof_of, overwrite=True):
    """The table text with the Wolof cells of [rows] filled.

    columns_of(row) lists (column, id) pairs to fill; wolof_of maps an id to
    its cache entry ({"wo": text, "engine": engine}). With overwrite, a cell
    that is empty or marked as machine text is replaced; without it only an
    empty cell is filled (the table is the source of truth: a marked cell the
    owner edited stays as he left it).
    """
    lines = markdown.splitlines()
    for number, row in rows:
        changed = False
        for column, name in columns_of(row):
            if name not in wolof_of:
                continue
            if row[column] == "" or (overwrite and is_ours(row[column])):
                row[column] = with_mark(wolof_of[name]["wo"], wolof_of[name]["engine"])
                changed = True
        if changed:
            lines[number] = "| " + " | ".join(row) + " |"
    return "\n".join(lines) + "\n"


def rewrite_words(markdown, wolof_of, overwrite=True):
    """The words table with the Wolof columns (6 and 7) filled."""

    def columns(row):
        key = row[0].strip("`")
        return [(6, f"wo_{key}"), (7, f"wo_{key}_exemple")]

    return fill(markdown, list(word_rows(markdown)), columns, wolof_of, overwrite)


def rewrite_problems(markdown, wolof_of, overwrite=True):
    """The statement tables with the « Wolof : énoncé » column (10) filled."""

    def columns(row):
        return [(10, f"wo_problem_{row[0].strip('`')}")]

    return fill(markdown, list(problem_rows(markdown)), columns, wolof_of, overwrite)


def with_status(markdown):
    """Puts the provisional-Wolof status line right under the status line,
    only while a table cell carries a « à relire » mark (otherwise the line
    is removed)."""
    lines = []
    for line in markdown.splitlines():
        if line.startswith(STATUS_PREFIX):
            # Also drop the blank line a previous run put before it.
            if lines and lines[-1] == "":
                lines.pop()
            continue
        lines.append(line)
    marked = any(
        line.startswith("|") and any(m in line for m in MARKS.values())
        for line in lines
    )
    if not marked:
        return "\n".join(lines) + "\n"
    for index, line in enumerate(lines):
        if re.match(r"Statut\s:", line):
            lines[index + 1 : index + 1] = ["", STATUS_LINE]
            break
    else:
        lines[1:1] = ["", STATUS_LINE]
    return "\n".join(lines) + "\n"


def split_mark(cell):
    """(text, mark) of a table cell: the Wolof text without its mark, and the
    mark ('' when the owner removed it, meaning he checked the text)."""
    for mark in MARKS.values():
        if cell.endswith(mark):
            return cell[: -len(mark)], mark
    return cell, ""


def cells_of(items):
    """{id: cell} for every text of the pack, read from the two tables (the
    source of truth); '' when a cell is empty."""
    cells = {}
    words = WORDS_TABLE.read_text(encoding="utf-8")
    for _, row in word_rows(words):
        key = row[0].strip("`")
        cells[f"wo_{key}"] = row[6]
        cells[f"wo_{key}_exemple"] = row[7]
    problems = PROBLEMS_TABLE.read_text(encoding="utf-8")
    for _, row in problem_rows(problems):
        cells[f"wo_problem_{row[0].strip('`')}"] = row[10]
    return {name: cells.get(name, "") for name, _ in items}


def load_rules(path=None):
    """Words never spoken (one per line of rules.txt, # for comments)."""
    path = path or RULES
    if not Path(path).exists():
        return []
    words = []
    for line in Path(path).read_text(encoding="utf-8").splitlines():
        line = line.split("#", 1)[0].strip().lower()
        if line:
            words.append(line)
    return words


def apply_rules(text, words):
    """[text] without the words that are never spoken (« franc »): whole
    words, any case; the spaces and the punctuation are tidied."""
    if words:
        pattern = r"(?<!\w)(?:" + "|".join(re.escape(w) for w in words) + r")(?!\w)"
        text = re.sub(pattern, "", text, flags=re.IGNORECASE)
    text = re.sub(r"\s+", " ", text)
    text = re.sub(r"\s+([,.;:!?])", r"\1", text)
    return text.strip()


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


def _convert_state(name):
    return CONVERTED_DIR / f".{name}.txt"


def stage(provisional_names, texts):
    """Copies the wavs to convert into the staging folder; returns
    (folder, count).

    A slot is staged when its m4a is missing, or when it is a stand-in (in
    the provisional list) whose text changed since it was last converted.
    A slot whose m4a exists and is NOT in the provisional list is a real
    recording: it is never staged, whatever the text or the notes say.
    """
    import shutil

    shutil.rmtree(STAGE_DIR, ignore_errors=True)
    STAGE_DIR.mkdir(parents=True)
    count = 0
    for name, text in texts.items():
        wav = WAV_DIR / f"{name}.wav"
        if not wav.exists():
            continue
        m4a = PACK_DIR / f"{name}.m4a"
        if m4a.exists():
            if m4a.name not in provisional_names:
                continue  # a real recording
            note = _convert_state(name)
            if note.exists() and note.read_text(encoding="utf-8") == text:
                continue  # the stand-in is current
        shutil.copy(wav, STAGE_DIR / wav.name)
        count += 1
    return STAGE_DIR, count


def pack(texts):
    """Converts the changed wavs with process_audio.py --provisional (all that
    this script makes is a stand-in: only process_audio.py run on real
    recordings takes a file out of the provisional list), then rebuilds the
    math words asset."""
    sys.path.insert(0, str(ROOT / "tool"))
    import process_audio

    previous = process_audio.read_provisional(PACK_DIR)
    folder, count = stage(previous, texts)
    print(f"{count} recording(s) to convert")
    if count:
        subprocess.run(
            [sys.executable, str(ROOT / "tool" / "process_audio.py"),
             str(folder), "--provisional"],
            check=True,
        )
    CONVERTED_DIR.mkdir(parents=True, exist_ok=True)
    provisional = process_audio.read_provisional(PACK_DIR)
    for name, text in texts.items():
        if f"{name}.m4a" in provisional:
            _convert_state(name).write_text(text, encoding="utf-8")
    subprocess.run(
        [sys.executable, str(ROOT / "tool" / "build_math_words.py")], check=True
    )


# ------------------------------------------------------------------ main


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--from", dest="first", choices=STEPS, default=STEPS[0])
    parser.add_argument("--until", dest="last", choices=STEPS, default=STEPS[-1])
    parser.add_argument("--engine", choices=["nllb", "file"], default="nllb",
                        help="nllb (default): translates the cells still empty, "
                        "offline; file: imports a Wolof text file made by hand "
                        "with translate.google.com, see --wolof")
    parser.add_argument("--wolof", type=Path, metavar="FILE",
                        help="with --engine file: one Wolof line per text, in "
                        "pack order (see --print-french)")
    parser.add_argument("--print-french", action="store_true",
                        help="print the 110 French texts, one per line, in the "
                        "order --wolof expects, and stop")
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
            imported = translate_from_file(items, args.wolof)
            write_tables(imported, overwrite=True)
        else:
            cells = cells_of(items)
            empty = [(n, f) for n, f in items if not cells[n]]
            print(f"{len(empty)} cell(s) still empty")
            if empty:
                done = translate(
                    empty, lambda text: Nllb_instance().french_to_wolof(text), "nllb"
                )
                write_tables(done, overwrite=False)
    if "tables" in wanted:
        write_tables({}, overwrite=False)

    cells = cells_of(items)
    empty = [name for name, cell in cells.items() if not cell]
    if empty and ("speak" in wanted or "pack" in wanted):
        raise SystemExit(f"{len(empty)} Wolof cell(s) are empty, e.g. {empty[0]}")
    rules = load_rules()
    texts = {}
    for name, cell in cells.items():
        text, _ = split_mark(cell)
        texts[name] = apply_rules(text, rules)
    if "speak" in wanted:
        speak(texts)
    if "pack" in wanted:
        pack(texts)


def write_tables(entries, overwrite):
    """Writes [entries] in the empty (or, with overwrite, machine) cells of
    the two tables and puts the status line at the top of each."""
    words = rewrite_words(WORDS_TABLE.read_text(encoding="utf-8"), entries, overwrite)
    WORDS_TABLE.write_text(with_status(words), encoding="utf-8")
    statements = rewrite_problems(
        PROBLEMS_TABLE.read_text(encoding="utf-8"), entries, overwrite
    )
    PROBLEMS_TABLE.write_text(with_status(statements), encoding="utf-8")
    print("tables written")


_nllb = None


def Nllb_instance():  # noqa: N802 - lazy, so that a cached run loads no model
    global _nllb
    if _nllb is None:
        _nllb = Nllb()
    return _nllb


if __name__ == "__main__":
    main()

# Provisional Wolof audio

Machine-made stand-ins for the Wolof recordings of Kid Matix, so that the
Wolof buttons and « Aide audio » work on a device until the owner delivers
real recordings.

- **Text**: the French explanation and example of the 40 math words and the
  French statement of the 30 problems, translated to Wolof by Meta NLLB-200
  (`fra_Latn` to `wol_Latn`), run offline with `ctranslate2` on the public
  int8 conversion `JustFrederik/nllb-200-distilled-600M-ct2-int8` (about
  600 MB, downloaded once into `build/nllb/`, pinned to a revision). **The
  quality is poor** (numbers are often wrong, some sentences lose their
  meaning) and nobody who speaks Wolof has reviewed it. The text can also
  come from a file made by hand with translate.google.com (`--engine file`).
- **Voice**: the Meta MMS Wolof VITS model exported to ONNX
  (`jaguaman09/mms-tts-wol-onnx`, public, no account, pinned to a
  revision), run on the CPU with `onnxruntime` (no torch). About 114 MB,
  downloaded once into `build/model/`.
- **Result**: `assets/audio/wo/wo_<key>.m4a`, `wo_<key>_exemple.m4a`,
  `wo_problem_<key>.m4a` and `assets/audio/wo/manifest.json` whose
  `"provisional"` list names every stand-in file. While the list is not
  empty the app shows a notice to adults (teacher area, next to
  « Aide audio ») and never offers the pack by default to a child who did
  not choose a help language: an adult picks it under « Aide audio ».

> **Licences**: the translation model (NLLB-200) and the voice model
> (`jaguaman09/mms-tts-wol-onnx`, from Meta MMS) are both CC-BY-NC 4.0
> (non-commercial). The files are placeholders and must be replaced by real
> recordings before any release. `tool/build_release.sh` runs
> `tool/check_release_content.sh`, which refuses a build while the manifest
> lists a provisional file or a table holds « (machine, à relire) » or
> « (Google, à relire) ».

## Setup

```bash
python3 -m venv tool/placeholder_audio/.venv
source tool/placeholder_audio/.venv/bin/activate
pip install -r tool/placeholder_audio/requirements.txt   # pinned versions
brew install ffmpeg                                      # if not installed yet
```

`onnxruntime` and `ctranslate2` have wheels for Python 3.14; if `pip
install` fails, use `brew install python@3.12` and create the venv with
`python3.12 -m venv`. `.venv/` and `build/` are git-ignored. No Hugging Face
account or token is needed.

## The one command

```bash
bash tool/placeholder_audio/regenerate.sh
```

The Wolof cells of the two content tables are the source of truth (edit a
cell in any editor, remove its « (…, à relire) » mark once checked). The
script creates the virtualenv if missing, installs the pinned requirements,
fills the cells still empty with NLLB, speaks again only the cells whose
text changed (the spoken text is kept in `build/wav/.<name>.txt`), converts
the changed recordings (cells still marked go through `process_audio.py
--provisional`, checked cells without it, so the manifest lists exactly the
provisional files) and rebuilds `math_words.json`. `rules.txt` lists the
words never spoken (`franc`, `francs`). The owner's workflow in French is in
`docs/product/audio-recording.md`, section 11.

## Run

```bash
source tool/placeholder_audio/.venv/bin/activate
python tool/placeholder_audio/make_wolof_placeholders.py                  # everything
python tool/placeholder_audio/make_wolof_placeholders.py --until tables   # text only
python tool/placeholder_audio/make_wolof_placeholders.py --from speak     # voice + pack
python tool/placeholder_audio/make_wolof_placeholders.py --back-translate 10
```

Steps: `extract`, `translate`, `tables`, `speak`, `pack`. The script is
idempotent and resumable:

- NLLB translates only cells that are empty (cache `wolof_machine.json`,
  committed); a cell that has a text is never overwritten except by
  `--engine file`;
- NLLB is decoded with a repetition penalty and a no-repeat n-gram size; an
  output that is far longer than its source or repeats a word is decoded
  again with a stronger penalty, then refused (the run stops and names the
  text);
- the Wolof columns of `docs/product/math-words.md` and
  `docs/product/problems.md` get the cells filled by the script suffixed « (machine, à relire) »
  (NLLB) or « (Google, à relire) » (file engine), and a status line is set
  under « Statut » at the top of each file; a cell the owner wrote by hand
  is never overwritten; `tool/build_math_words.py` leaves both marks out of
  the asset;
- a wav in `build/wav/` is made again when its spoken text changed (a
  hidden `.<name>.txt` next to it holds it; the text is the cell without
  its mark and without the words of `rules.txt`);
- `pack` runs `tool/process_audio.py build/wav --provisional`, then
  `tool/build_math_words.py`. `--provisional` never overwrites a file that
  is not marked provisional and fails on a file over 15 s.

### Text from translate.google.com, by hand

```bash
python tool/placeholder_audio/make_wolof_placeholders.py --print-french > french.txt
# paste french.txt into translate.google.com (French to Wolof) and save the
# result, one line per text, as wolof.txt (110 lines, same order)
python tool/placeholder_audio/make_wolof_placeholders.py \
    --engine file --wolof wolof.txt
```

The import writes the Wolof cells too (marked « (Google, à relire) »). The
110 lines are the 80 word texts of `math-words.md` (explanation, then
example, per word) then the 30 problem statements of `problems.md`. A wrong
line count or a blank line is refused. The cache entries get
`engine: "google-web"`.

The vocabulary of the voice has no é, ë, à, ó or ñ: such a letter is read
without its mark (ñ as n). Digits are spelled in French (« 12 » becomes
« douze ») before the translation, because the voice cannot read digits. The
marks are never spoken.

## Replacing the stand-ins

See « Fichiers provisoires » in `docs/product/audio-recording.md`: record
the real files, run `tool/process_audio.py` on the folder; the files it
converts leave the `provisional` list, which goes away when it is empty.

## Tests

```bash
python3 -m unittest tool/placeholder_audio/make_wolof_placeholders_test.py
bash tool/check_release_content_test.sh
```

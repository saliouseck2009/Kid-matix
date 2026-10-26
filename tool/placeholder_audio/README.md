# Provisional Wolof audio

Machine-made stand-ins for the Wolof recordings of Kid Matix, so that the
Wolof buttons and « Aide audio » work on a device until the owner delivers
real recordings.

- **Text**: the French explanation and example of the 40 math words and the
  French statement of the 30 problems, translated to Wolof by Google
  Translate (`deep-translator`). Never reviewed by anybody who speaks Wolof.
- **Voice**: the Meta MMS Wolof VITS model exported to ONNX
  (`jaguaman09/mms-tts-wol-onnx`, public, no account), run on the CPU with
  `onnxruntime` (no torch). About 114 MB, downloaded once into `build/model/`.
- **Result**: `assets/audio/wo/wo_<key>.m4a`, `wo_<key>_exemple.m4a`,
  `wo_problem_<key>.m4a` and `assets/audio/wo/manifest.json` with
  `"provisional": true`. The app shows a notice in the teacher area and
  next to « Aide audio » while the pack carries that flag.

> **Licence**: the model is CC-BY-NC 4.0 (non-commercial, like Meta MMS).
> The files are placeholders and must be replaced by real recordings before
> any release.

## Setup

```bash
python3 -m venv tool/placeholder_audio/.venv
source tool/placeholder_audio/.venv/bin/activate
pip install -r tool/placeholder_audio/requirements.txt
brew install ffmpeg                                 # if not installed yet
```

`onnxruntime` has wheels for Python 3.14; if `pip install` fails, use
`brew install python@3.12` and create the venv with `python3.12 -m venv`.
`.venv/` and `build/` are git-ignored. No Hugging Face account or token is
needed.

## Run

```bash
source tool/placeholder_audio/.venv/bin/activate
python tool/placeholder_audio/make_wolof_placeholders.py            # everything
python tool/placeholder_audio/make_wolof_placeholders.py --until tables   # text only
python tool/placeholder_audio/make_wolof_placeholders.py --from speak     # voice + pack
```

Steps: `extract`, `translate`, `tables`, `speak`, `pack`. The script is
idempotent and resumable:

- translations are cached in `wolof_machine.json` (committed); a text is
  asked again only when its French source changed, so a re-run needs no
  network;
- the Wolof columns of `docs/product/math-words.md` and
  `docs/product/problems.md` get every cell suffixed « (machine, à relire) »
  and a status line is set at the top of each file; a cell the owner wrote
  by hand is never overwritten;
- a wav that already exists in `build/wav/` is not made again (delete it to
  redo one);
- `speak` downloads the model once; `pack` runs `tool/process_audio.py build/wav --provisional`, then
  `tool/build_math_words.py`.

The vocabulary of the voice has no é, ë, à, ó or ñ: such a letter is read
without its mark (ñ as n). Digits are spelled in French (« 12 » becomes « douze ») before the
translation, because the voice cannot read digits. The mark « (machine, à
relire) » is never spoken.

Google Translate may answer « too many requests » (HTTP 429) on a shared or
flagged network address. The script then stops before the tables and the
voice (it does not look for another way in): wait, or run from another
network, then run it again; what is translated is kept.

## Replacing the stand-ins

See « Fichiers provisoires » in `docs/product/audio-recording.md`: record
the real files, run `tool/process_audio.py` on the folder, and the
`provisional` flag goes away.

## Tests

```bash
python3 -m unittest tool/placeholder_audio/make_wolof_placeholders_test.py
```

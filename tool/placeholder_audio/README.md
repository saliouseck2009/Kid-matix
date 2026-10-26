# Provisional Wolof audio

Machine-made stand-ins for the Wolof recordings of Kid Matix, so that the
Wolof buttons and « Aide audio » work on a device until the owner delivers
real recordings.

- **Text**: the French explanation and example of the 40 math words and the
  French statement of the 30 problems, translated to Wolof by Google
  Translate (`deep-translator`). Never reviewed by anybody who speaks Wolof.
- **Voice**: Meta MMS Wolof (`facebook/mms-tts-wol`), run on the CPU.
- **Result**: `assets/audio/wo/wo_<key>.m4a`, `wo_<key>_exemple.m4a`,
  `wo_problem_<key>.m4a` and `assets/audio/wo/manifest.json` with
  `"provisional": true`. The app shows a notice in the teacher area and
  next to « Aide audio » while the pack carries that flag.

> **Licence**: the MMS models are CC-BY-NC 4.0 (non-commercial). These files
> are placeholders and must be replaced by real recordings before any
> release.

## Setup

The system Python of the project is 3.14. `torch` and `transformers` ship
wheels for it; if `pip install` fails on one of them, use Python 3.12:

```bash
brew install python@3.12        # only when 3.14 fails
python3.12 -m venv tool/placeholder_audio/.venv
```

```bash
python3 -m venv tool/placeholder_audio/.venv       # skip if made above
source tool/placeholder_audio/.venv/bin/activate
pip install -r tool/placeholder_audio/requirements.txt
brew install ffmpeg                                 # if not installed yet
```

`.venv/` and `build/` are git-ignored.

## The voice needs a Hugging Face login

The MMS model is gated. Once:

1. Create an account at <https://huggingface.co/join>.
2. Open <https://huggingface.co/facebook/mms-tts-wol> and accept the licence.
3. `huggingface-cli login` (newer versions: `hf auth login`), or
   `export HF_TOKEN=<your token>`.

Without it the script prints these steps and stops before the voice.

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
- `pack` runs `tool/process_audio.py build/wav --provisional`, then
  `tool/build_math_words.py`.

Digits are spelled in French (« 12 » becomes « douze ») before the
translation, because the voice cannot read digits. The mark « (machine, à
relire) » is never spoken.

Google Translate may answer « too many requests » (HTTP 429) on a shared or
flagged network address: wait, or run from another network, then run the
script again; what is translated is kept.

## Replacing the stand-ins

See « Fichiers provisoires » in `docs/product/audio-recording.md`: record
the real files, run `tool/process_audio.py` on the folder, and the
`provisional` flag goes away.

## Tests

```bash
python3 -m unittest tool/placeholder_audio/make_wolof_placeholders_test.py
```

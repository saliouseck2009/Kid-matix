"""Generates the sound effects of the app in assets/sounds/.

The sounds are short synthesized notes, so they belong to the project and
can be replaced by recorded ones later without touching the code.
Run: python3 tool/generate_sounds.py
"""

import math
import struct
import wave
from pathlib import Path

RATE = 22050
OUT = Path(__file__).resolve().parent.parent / "assets" / "sounds"


def note(frequency, seconds, volume=0.5, harmonics=(1.0, 0.3, 0.1)):
    """Samples of one soft note: a quick attack, then a gentle fade."""
    count = int(RATE * seconds)
    attack = int(RATE * 0.008)
    samples = []
    for index in range(count):
        time = index / RATE
        level = min(1.0, index / attack) if attack else 1.0
        level *= math.exp(-3.5 * index / count)
        value = sum(
            weight * math.sin(2 * math.pi * frequency * (rank + 1) * time)
            for rank, weight in enumerate(harmonics)
        )
        samples.append(volume * level * value / sum(harmonics))
    return samples


def write(name, samples):
    OUT.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUT / name), "wb") as file:
        file.setnchannels(1)
        file.setsampwidth(2)
        file.setframerate(RATE)
        file.writeframes(
            b"".join(
                struct.pack("<h", int(max(-1.0, min(1.0, s)) * 32767))
                for s in samples
            )
        )


def main():
    # Right answer: two bright notes going up (E5, A5).
    write("right.wav", note(659.25, 0.09) + note(880.0, 0.16))
    # Mistake: two soft low notes going down (A3, F3), quieter.
    soft = (1.0, 0.15)
    write(
        "wrong.wav",
        note(220.0, 0.12, 0.35, soft) + note(174.61, 0.2, 0.35, soft),
    )
    # Celebration: a rising arpeggio (C5, E5, G5) ending on a held C6.
    write(
        "celebration.wav",
        note(523.25, 0.1)
        + note(659.25, 0.1)
        + note(783.99, 0.1)
        + note(1046.5, 0.45),
    )


if __name__ == "__main__":
    main()

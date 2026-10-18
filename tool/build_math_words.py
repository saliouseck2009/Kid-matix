"""Builds the data asset of the math words from docs/product/math-words.md.

The content table is the source of truth: the owner edits it, this script
derives assets/math_words/math_words.json, which the app reads (the words,
their family and notion, the « Quelle opération ? » statements). The
Wolof columns are never copied: the app plays recordings, not Wolof text.
Keys never change once published.

Run: python3 tool/build_math_words.py
Check without writing: python3 tool/build_math_words.py --check
"""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "docs" / "product" / "math-words.md"
OUTPUT = ROOT / "assets" / "math_words" / "math_words.json"

FAMILIES = {
    "Ajouter": "add",
    "Enlever": "remove",
    "Comparer": "compare",
    "Grouper": "group",
    "Partager": "share",
    "Questions": "ask",
}
# The form of each word as it appears in its example sentence, so the app can
# make it touchable ("il reste" is written "reste" in "Il lui reste 6
# mangues"). Checked against the example by the build.
SURFACES = {
    "ajouter": "ajoute",
    "en_plus": "en plus",
    "en_tout": "en tout",
    "ensemble": "ensemble",
    "gagner": "gagne",
    "recevoir": "reçoit",
    "augmenter": "augmente",
    "enlever": "enlève",
    "il_reste": "reste",
    "retirer": "retire",
    "vendre": "vend",
    "donner": "donne",
    "perdre": "perd",
    "acheter": "achète",
    "de_plus_que": "de plus que",
    "de_moins_que": "de moins que",
    "autant_que": "autant",
    "le_plus_grand": "le plus grand",
    "le_plus_petit": "le plus petit",
    "difference": "différence",
    "egal": "égaux",
    "par_paquets_de": "par paquets de",
    "chacun": "chacun",
    "fois": "fois",
    "dans_chaque": "Dans chaque",
    "rangee": "rangées",
    "double": "le double",
    "partager": "partage",
    "partager_egalement": "partage également",
    "repartir": "répartit",
    "par_personne": "par personne",
    "diviser": "diviser",
    "moitie": "la moitié",
    "quart": "un quart",
    "combien": "combien",
    "combien_de_fois": "Combien de fois",
    "total": "le total",
    "au_depart": "Au départ",
    "a_la_fin": "À la fin",
    "apres": "Après",
}
OPERATIONS = {"+": "add", "−": "subtract", "×": "multiply", "÷": "divide"}
KEY_PATTERN = re.compile(r"^[a-z]+(_[a-z]+)*$")


def cells(line):
    """The cells of one table row, without the outer bars."""
    return [cell.strip() for cell in line.strip().strip("|").split("|")]


def keys_of(text):
    """The keys written between backticks in a cell."""
    return re.findall(r"`([a-z_]+)`", text)


def parse(markdown):
    section = ""
    family = ""
    words = []
    glossary = []
    statements = []
    for line in markdown.splitlines():
        if line.startswith("## "):
            section = line[3:].strip()
            family = ""
        elif line.startswith("### "):
            family = FAMILIES.get(line[4:].strip(), "")
        elif line.startswith("|") and not line.startswith("| ---"):
            row = cells(line)
            if section.startswith("1.") and family and len(row) >= 5:
                if row[0] == "Clé":
                    continue
                words.append(
                    {
                        "key": row[0].strip("`"),
                        "family": family,
                        "text": row[1],
                        "meaning": row[2],
                        "example": row[4],
                    }
                )
            elif section.startswith("2.") and row[0] != "Notion":
                glossary.append(keys_of(row[2]))
            elif section.startswith("3.") and row[0] != "Id":
                statements.append(
                    {
                        "id": row[0],
                        "text": row[1],
                        "operation": OPERATIONS[row[2]],
                        "keys": keys_of(row[3]),
                    }
                )
    return words, glossary, statements


def build(markdown):
    words, glossary, statements = parse(markdown)
    notion_of = {}
    for keys in glossary:
        for key in keys:
            notion_of[key] = keys[0]
    keys = [word["key"] for word in words]
    problems = []
    if len(set(keys)) != len(keys):
        problems.append("duplicate word key")
    for key in keys:
        if not KEY_PATTERN.match(key):
            problems.append(f"bad key {key}")
        if key not in notion_of:
            problems.append(f"{key} is in no notion of the glossary")
    for statement in statements:
        for key in statement["keys"]:
            if key not in keys:
                problems.append(f"{statement['id']} uses unknown key {key}")
    if problems:
        raise SystemExit("math-words.md is inconsistent:\n" + "\n".join(problems))
    for word in words:
        word["notion"] = notion_of[word["key"]]
        surface = SURFACES.get(word["key"])
        if surface is None:
            problems.append(f"{word['key']} has no surface in SURFACES")
        elif surface.lower() not in word["example"].lower():
            problems.append(
                f"the example of {word['key']} does not contain '{surface}'"
            )
        else:
            word["surface"] = surface
    if problems:
        raise SystemExit("math-words.md is inconsistent:\n" + "\n".join(problems))
    return {"words": words, "statements": statements}


def main():
    content = build(SOURCE.read_text(encoding="utf-8"))
    text = json.dumps(content, ensure_ascii=False, indent=2) + "\n"
    if "--check" in sys.argv:
        if not OUTPUT.exists() or OUTPUT.read_text(encoding="utf-8") != text:
            raise SystemExit(f"{OUTPUT} is stale: run tool/build_math_words.py")
        print("math_words.json is up to date")
        return
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(text, encoding="utf-8")
    print(f"{len(content['words'])} words, {len(content['statements'])} statements")


if __name__ == "__main__":
    main()

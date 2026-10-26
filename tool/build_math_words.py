"""Builds the data asset of the math words from docs/product/math-words.md.

The content table is the source of truth: the owner edits it, this script
derives assets/math_words/math_words.json, which the app reads (the words,
their family and notion, the « Quelle opération ? » statements). The
app plays recordings, not Wolof text: the Wolof columns are copied only
once the owner writes them, under "help" -> "wo", for the printable word
cards of the teacher (F31-07); an empty column adds nothing. Keys never
change once published.

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
OPERATIONS = {"+": "add", "−": "subtract", "×": "multiply", "÷": "divide"}
# Cells filled by tool/placeholder_audio/ end with one of these marks. They are
# provisional machine text, never copied into the asset (the printable word
# cards only carry what the owner wrote).
PROVISIONAL_MARKS = (" (machine, à relire)", " (Google, à relire)")
KEY_PATTERN = re.compile(r"^[a-z]+(_[a-z]+)*$")


def cells(line):
    """The cells of one table row, without the outer bars."""
    return [cell.strip() for cell in line.strip().strip("|").split("|")]


def help_of(row):
    """The Wolof texts of a word row (explanation, example) the owner wrote;
    an empty column, or a provisional machine text, is left out."""
    texts = {}
    for name, index in (("explanation", 6), ("example", 7)):
        if len(row) > index and row[index] and not row[index].endswith(
            PROVISIONAL_MARKS
        ):
            texts[name] = row[index]
    return texts


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
                word = {
                    "key": row[0].strip("`"),
                    "family": family,
                    "text": row[1],
                    "meaning": row[2],
                    "example": row[4],
                    "surface": row[5],
                }
                help_texts = help_of(row)
                if help_texts:
                    word["help"] = {"wo": help_texts}
                words.append(word)
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
        if word["surface"].lower() not in word["example"].lower():
            problems.append(
                f"the example of {word['key']} does not contain "
                f"'{word['surface']}' (column Forme dans l'exemple)"
            )
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

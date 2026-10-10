#!/usr/bin/env python3
"""Prints line coverage per `domain/` and `data/` folder of `lib/`.

Reads `coverage/lcov.info` (produced by `flutter test --coverage`) and groups
every source file under the closest `domain/` or `data/` ancestor folder.
Exits with status 1 when a `domain/` folder is under 90 % or a `data/` folder
is under 80 %, so it can gate a manual check. It is not wired into
`tool/check.sh` or CI.

Usage, from the repository root:
    flutter test --coverage
    python3 tool/coverage_report.py [path/to/lcov.info]
"""

import sys
from pathlib import Path

THRESHOLDS = {"domain": 90.0, "data": 80.0}
DEFAULT_LCOV = Path("coverage/lcov.info")


def layer_folder(source_path):
    """Returns (folder, layer) for a lib file inside domain/ or data/."""
    parts = Path(source_path).parts
    if "lib" not in parts:
        return None
    parts = parts[parts.index("lib"):]
    for index, part in enumerate(parts):
        if part in THRESHOLDS:
            return "/".join(parts[: index + 1]), part
    return None


def read_lcov(lcov_path):
    """Returns {source file: (lines found, lines hit)} from an lcov file."""
    files = {}
    current = None
    found = hit = 0
    for raw_line in lcov_path.read_text().splitlines():
        line = raw_line.strip()
        if line.startswith("SF:"):
            current = line[3:]
            found = hit = 0
        elif line.startswith("DA:"):
            found += 1
            if int(line[3:].split(",")[1]) > 0:
                hit += 1
        elif line == "end_of_record" and current is not None:
            files[current] = (found, hit)
            current = None
    return files


def main():
    lcov_path = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_LCOV
    if not lcov_path.is_file():
        print(f"ERROR: {lcov_path} not found; run `flutter test --coverage`.")
        return 2

    folders = {}
    for source, (found, hit) in read_lcov(lcov_path).items():
        match = layer_folder(source)
        if match is None:
            continue
        folder, layer = match
        total_found, total_hit, _ = folders.get(folder, (0, 0, layer))
        folders[folder] = (total_found + found, total_hit + hit, layer)

    failures = 0
    print(f"{'folder':<45} {'lines':>7} {'hit':>7} {'cover':>7}  min")
    for folder in sorted(folders):
        found, hit, layer = folders[folder]
        percent = 100.0 * hit / found if found else 100.0
        threshold = THRESHOLDS[layer]
        status = "ok" if percent >= threshold else "FAIL"
        if status == "FAIL":
            failures += 1
        print(
            f"{folder:<45} {found:>7} {hit:>7} {percent:>6.1f}%"
            f"  {threshold:.0f}% {status}"
        )

    if failures:
        print(f"{failures} folder(s) under the threshold.")
        return 1
    print("All domain/ and data/ folders meet the thresholds.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

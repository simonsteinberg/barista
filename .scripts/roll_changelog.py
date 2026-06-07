#!/usr/bin/env python
"""Roll CHANGELOG.md for a release.

Promotes the ``[Unreleased]`` section to a dated ``[X.Y.Z]`` section, opens a
fresh empty ``[Unreleased]``, and regenerates the GitHub compare/tag link
references at the bottom of the file.

Driven by ``.scripts/release.sh`` via environment variables:

- ``NEW_VERSION`` — the version being released, e.g. ``0.1.0``
- ``RELEASE_DATE`` — ISO date for the section heading, e.g. ``2026-06-07``
- ``SLUG`` — the GitHub ``owner/repo`` slug used to build links
"""

from __future__ import annotations

import os
import re
import sys
from pathlib import Path

CHANGELOG = Path("CHANGELOG.md")
LINK_RE = re.compile(r"^\[[^\]]+\]:\s")
VERSION_HEADING_RE = re.compile(r"^## \[([^\]]+)\]")


def build_link_block(slug: str, versions: list[str]) -> list[str]:
    """Build the reference-link lines for the changelog footer.

    Args:
        slug: GitHub ``owner/repo`` slug.
        versions: Released version strings, newest first.

    Returns:
        The link-reference lines, ``[Unreleased]`` first.
    """
    base = f"https://github.com/{slug}"
    lines: list[str] = []

    if versions:
        lines.append(f"[Unreleased]: {base}/compare/v{versions[0]}...HEAD")
    else:
        lines.append(f"[Unreleased]: {base}/commits/main")

    for i, version in enumerate(versions):
        older = versions[i + 1] if i + 1 < len(versions) else None
        if older is None:
            link = f"{base}/releases/tag/v{version}"
        else:
            link = f"{base}/compare/v{older}...v{version}"
        lines.append(f"[{version}]: {link}")

    return lines


def roll(text: str, new_version: str, release_date: str, slug: str) -> str:
    """Return the changelog text rolled for ``new_version``."""
    # Drop existing link references; they are regenerated from scratch.
    body_lines = [ln for ln in text.splitlines() if not LINK_RE.match(ln)]

    # Promote [Unreleased]: rename it to the new version and open a fresh one.
    rolled: list[str] = []
    promoted = False
    for line in body_lines:
        if not promoted and line.strip() == "## [Unreleased]":
            rolled.append("## [Unreleased]")
            rolled.append("")
            rolled.append(f"## [{new_version}] - {release_date}")
            promoted = True
            continue
        rolled.append(line)

    if not promoted:
        raise SystemExit("Error: no '## [Unreleased]' heading in CHANGELOG.md")

    versions = [
        m.group(1)
        for line in rolled
        if (m := VERSION_HEADING_RE.match(line)) and m.group(1) != "Unreleased"
    ]

    # Trim trailing blanks, then append the regenerated link block.
    while rolled and rolled[-1].strip() == "":
        rolled.pop()
    rolled.append("")
    rolled.extend(build_link_block(slug, versions))

    return "\n".join(rolled) + "\n"


def main() -> None:
    try:
        new_version = os.environ["NEW_VERSION"]
        release_date = os.environ["RELEASE_DATE"]
        slug = os.environ["SLUG"]
    except KeyError as exc:
        raise SystemExit(f"Error: missing environment variable {exc}") from exc

    text = CHANGELOG.read_text(encoding="utf-8")
    CHANGELOG.write_text(
        roll(text, new_version, release_date, slug), encoding="utf-8"
    )
    print(
        f"Rolled CHANGELOG.md for {new_version} ({release_date}).",
        file=sys.stderr,
    )


if __name__ == "__main__":
    main()

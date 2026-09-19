"""Small dependency-free static-site check used locally and in CI."""

from __future__ import annotations

import html.parser
import pathlib
import re
import sys
from urllib.parse import urlparse


ROOT = pathlib.Path(__file__).resolve().parents[1]
HTML_FILES = sorted(ROOT.rglob("*.html"))
IGNORE_PARTS = {".git", "node_modules"}


class PageParser(html.parser.HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.ids: set[str] = set()
        self.links: list[tuple[str, str]] = []
        self.images_without_alt: list[str] = []
        self.videos_without_controls: list[str] = []
        self.lang: str | None = None

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        attrs_dict = dict(attrs)
        if tag == "html":
            self.lang = attrs_dict.get("lang")
        if attrs_dict.get("id"):
            self.ids.add(attrs_dict["id"] or "")
        if tag == "a" and attrs_dict.get("href"):
            self.links.append(("a", attrs_dict["href"] or ""))
        if tag == "img" and "alt" not in attrs_dict:
            self.images_without_alt.append(self.get_starttag_text() or "img")
        if tag == "video" and "controls" not in attrs_dict:
            self.videos_without_controls.append(self.get_starttag_text() or "video")


def is_local_href(href: str) -> bool:
    parsed = urlparse(href)
    return not parsed.scheme and not href.startswith("//") and not href.startswith("mailto:") and not href.startswith("tel:")


def check() -> int:
    errors: list[str] = []
    warnings: list[str] = []
    known_routes = {"/", "/about/"} | {f"/projects/{p.name}/" for p in (ROOT / "projects").iterdir() if p.is_dir()}

    for page in HTML_FILES:
        if any(part in IGNORE_PARTS for part in page.parts):
            continue
        relative = page.relative_to(ROOT)
        text = page.read_text(encoding="utf-8", errors="replace")
        parser = PageParser()
        parser.feed(text)
        if parser.lang != "en":
            errors.append(f"{relative}: missing lang=\"en\"")
        if "name=\"viewport\"" not in text and "name='viewport'" not in text:
            errors.append(f"{relative}: missing viewport metadata")
        if "<title" not in text.lower():
            errors.append(f"{relative}: missing title")
        if parser.images_without_alt:
            errors.append(f"{relative}: image without alt text")
        if parser.videos_without_controls:
            errors.append(f"{relative}: video without controls")
        for _, href in parser.links:
            clean = href.split("#", 1)[0].split("?", 1)[0]
            if not clean or not is_local_href(clean):
                continue
            target = (page.parent / clean).resolve()
            if clean.endswith("/"):
                target = target / "index.html"
            if not target.exists():
                errors.append(f"{relative}: broken local link {href}")
        if "unpkg.com/lucide@latest" in text:
            errors.append(f"{relative}: unpinned Lucide dependency")
        if "<main" not in text and "role=\"main\"" not in text:
            warnings.append(f"{relative}: no semantic main element (shared JS adds a keyboard target)")

    if not (ROOT / "CNAME").read_text(encoding="utf-8").strip():
        errors.append("CNAME is empty")
    if not known_routes:
        errors.append("No canonical routes found")

    for warning in warnings:
        print(f"WARN: {warning}")
    for error in errors:
        print(f"ERROR: {error}")
    print(f"Checked {len(HTML_FILES)} HTML files")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(check())

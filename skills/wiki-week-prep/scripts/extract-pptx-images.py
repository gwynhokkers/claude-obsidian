#!/usr/bin/env python3
"""Extract images from a PPTX deck, optionally filtered by slide numbers."""

from __future__ import annotations

import argparse
import re
import zipfile
from pathlib import Path
from xml.etree import ElementTree as ET

REL_NS = "{http://schemas.openxmlformats.org/officeDocument/2006/relationships}"
MIN_BYTES = 5_000


def slide_paths(z: zipfile.ZipFile) -> list[str]:
    names = [n for n in z.namelist() if re.match(r"ppt/slides/slide\d+\.xml$", n)]
    return sorted(names, key=lambda x: int(re.search(r"slide(\d+)", x).group(1)))


def slide_images(z: zipfile.ZipFile, slide_path: str) -> list[str]:
    sn = int(re.search(r"slide(\d+)", slide_path).group(1))
    rel_path = slide_path.replace("slides/", "slides/_rels/") + ".rels"
    rels: dict[str, str] = {}
    if rel_path in z.namelist():
        root = ET.fromstring(z.read(rel_path))
        for rel in root:
            target = rel.get("Target")
            if target and "media/" in target:
                rels[rel.get("Id")] = "ppt/" + target.replace("../", "")
    root = ET.fromstring(z.read(slide_path))
    imgs: list[str] = []
    for blip in root.iter("{http://schemas.openxmlformats.org/drawingml/2006/main}blip"):
        embed = blip.get(f"{REL_NS}embed")
        if embed and embed in rels:
            imgs.append(rels[embed])
    return imgs


def main() -> None:
    parser = argparse.ArgumentParser(description="Extract images from PPTX slides")
    parser.add_argument("--pptx", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("--prefix", default="slide", help="Filename prefix, e.g. w6")
    parser.add_argument(
        "--slides",
        default="",
        help="Comma-separated slide numbers to include (default: all with images)",
    )
    args = parser.parse_args()

    wanted = {int(x.strip()) for x in args.slides.split(",") if x.strip()}
    args.out.mkdir(parents=True, exist_ok=True)

    extracted = 0
    with zipfile.ZipFile(args.pptx) as z:
        for slide_path in slide_paths(z):
            sn = int(re.search(r"slide(\d+)", slide_path).group(1))
            if wanted and sn not in wanted:
                continue
            for i, media_path in enumerate(slide_images(z, slide_path), 1):
                ext = Path(media_path).suffix.lower()
                if ext == ".wmf":
                    continue
                data = z.read(media_path)
                if len(data) < MIN_BYTES:
                    continue
                dest = args.out / f"{args.prefix}-slide{sn:02d}-{i}{ext}"
                dest.write_bytes(data)
                print(f"wrote {dest.name} ({len(data)} bytes)")
                extracted += 1

    print(f"extracted {extracted} images to {args.out}")


if __name__ == "__main__":
    main()

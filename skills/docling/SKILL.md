---
name: docling
description: "Convert PDF and Office binaries into structured Markdown before wiki ingest. Preserves reading order, tables, and layout that raw text extraction loses. Triggers on: docling, convert this pdf, convert this document, pre-ingest convert, convert for ingest, pdf to markdown, docx to markdown."
allowed-tools: Read Bash
---

# docling: Pre-Ingest Document Converter

Docling converts messy documents (PDFs, Word, PowerPoint, Excel) into structured Markdown with reading order, tables, and layout preserved. Use it as the extraction step before `wiki-ingest` synthesises wiki pages.

Docling does **not** create wiki pages, entities, or log entries. That stays with `/wiki-ingest`.

Upstream: [docling.ai](https://docling.ai/) · [CLI reference](https://docling-project.github.io/docling/reference/cli/)

---

## Install

Requires Python 3.10 or newer.

```bash
pip install docling
```

Verify:

```bash
which docling 2>/dev/null || echo "not installed"
docling --help >/dev/null 2>&1 && echo "ok"
```

Models download once on first convert, then run offline.

---

## Supported formats

| Extension | Use Docling? |
|-----------|--------------|
| `.pdf`, `.docx`, `.pptx`, `.xlsx` | Yes |
| `.png`, `.jpg`, … (standalone images) | No — use wiki-ingest Image / Vision |
| URLs / web articles | No — use defuddle |
| `.mhtml` | No — not supported; ingest via agent text-read |

Output for this skill: Markdown only (`--to md`).

---

## Derived-file convention

Never modify the user-dropped binary under `.raw/`. Write regenerable Markdown under `.raw/converted/`, mirroring the path relative to `.raw/`:

| Input | Output |
|-------|--------|
| `.raw/units/CSI6208/week-01/workshop.pdf` | `.raw/converted/units/CSI6208/week-01/workshop.md` |

`.raw/converted/` is agent-owned derived content (same class as `.raw/articles/` and `.raw/images/`). Re-run conversion when the original binary changes.

---

## Usage

### Convert a single file for ingest

Run from the vault root. `SRC` is vault-relative (must start with `.raw/`).

```bash
SRC=".raw/units/CSI6208/week-01/workshop.pdf"
REL="${SRC#.raw/}"
OUT_DIR=".raw/converted/$(dirname "$REL")"
BASE="$(basename "$REL")"
STEM="${BASE%.*}"
OUT_MD="$OUT_DIR/$STEM.md"

mkdir -p "$OUT_DIR"
HASH=$(md5 -q "$SRC" 2>/dev/null || md5sum "$SRC" | cut -d' ' -f1)

docling convert "$SRC" --to md --output "$OUT_DIR"

# Docling writes $OUT_DIR/$STEM.md; prepend frontmatter
BODY=$(cat "$OUT_MD")
{
  echo "---"
  echo "source_type: docling"
  echo "original_file: $SRC"
  echo "converter: docling"
  echo "converted: $(date +%Y-%m-%d)"
  echo "original_hash: $HASH"
  echo "---"
  echo ""
  printf '%s\n' "$BODY"
} > "$OUT_MD"

echo "Converted → $OUT_MD"
```

### Convert a directory

```bash
# Convert every supported file under a .raw/ subtree
find .raw/units/CSI6208 -type f \( -name '*.pdf' -o -name '*.docx' -o -name '*.pptx' -o -name '*.xlsx' \) | while read -r SRC; do
  # … same REL / OUT_DIR / convert / frontmatter steps as above …
done
```

Prefer converting one file at a time when following with immediate ingest, so failures stay isolated.

---

## When to Use

**Use Docling when:**
- Ingesting a PDF, DOCX, PPTX, or XLSX from `.raw/`
- Layout, tables, or multi-column reading order matter
- You want offline, local conversion before wiki synthesis

**Skip Docling when:**
- The source is already clean Markdown
- The source is a URL (use defuddle) or a standalone image (use vision ingest)
- The source is `.mhtml` (unsupported)
- You only need a canvas PDF preview (`/canvas add pdf`), not wiki ingest

---

## Fallback

If Docling is not installed:

```bash
which docling 2>/dev/null || echo "not installed"
```

Report: install with `pip install docling`, then retry. **Do not** invent document text from a failed or skipped convert. Do not fall back to dumping unreadable PDF bytes into the wiki.

---

## Integration with /wiki-ingest

The `/wiki-ingest` skill detects `.pdf` / `.docx` / `.pptx` / `.xlsx` and runs this conversion automatically when Docling is on `PATH`. You do not need to convert manually before `ingest [file]`.

To convert without ingesting yet:

1. Run the single-file recipe above
2. Later: `ingest .raw/converted/.../stem.md` (or ingest the original binary path; wiki-ingest will reuse the converted file when the hash matches)

---

## How to think (10-principle mapping)

When working on this skill, apply the 10-principle loop. See [`skills/think/SKILL.md`](../think/SKILL.md) for the canonical framework.

| # | Principle | Application here |
|---|-----------|-------------------|
| 1 | OBSERVE (ext) | Which binary? Extension supported? Already converted with matching hash? |
| 2 | OBSERVE (int) | Am I tempted to skip convert and "read" a PDF poorly? Extraction quality is the point. |
| 3 | LISTEN | Did the user ask only to convert, or convert-and-ingest? |
| 4 | THINK | Mirror path under `.raw/converted/`; never overwrite the original binary. |
| 5 | CONNECT (lat) | Defuddle is the web twin; vision ingest covers images; this covers Office/PDF. |
| 6 | CONNECT (sys) | Output lands in `.raw/converted/` for wiki-ingest; manifest keys on original hash. |
| 7 | FEEL | Tables and reading order should survive; garbled columns mean a bad convert. |
| 8 | ACCEPT | Some scans and odd layouts still fail. Flag and stop; do not invent content. |
| 9 | CREATE | Markdown under `.raw/converted/` with `source_type: docling` frontmatter. |
| 10 | GROW | Recurring failures suggest OCR flags, format gaps, or Docling upgrades — track as backlog. |

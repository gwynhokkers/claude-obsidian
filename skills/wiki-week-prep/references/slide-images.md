# Slide image extraction

## Script

```bash
cd /path/to/University-Vault
python3 skills/wiki-week-prep/scripts/extract-pptx-images.py \
  --pptx ".raw/units/MAN5902/week-06/Week 6 Extending....pptx" \
  --out "_attachments/man5902/week-06" \
  --prefix w6 \
  --slides 9,17,19,23,24,33,39,40,44,50,52,55,61,65,68,77
```

Omit `--slides` to extract all slides that contain images (skips WMF and files &lt; 5 KB).

## Manual curation (preferred)

After auto-extract, rename to semantic names:

| Slide topic | Example filename |
|-------------|----------------|
| Models integration | `w6-models-integration.png` |
| CRUD per class | `w6-crud-verify-use-cases.png` |
| CRUD matrix | `w6-crud-cross-check-matrix.png` |
| Activity notation | `w6-activity-diagram-notation.png` |
| SSD notation | `w6-ssd-notation.jpeg` |
| SMD example | `w6-smd-saleitem.png` |

## Obsidian embeds

```markdown
![[w6-crud-verify-use-cases.png]]
*Slide 17: CRUD per class (Satzinger)*
```

Filenames must be unique vault-wide. Obsidian resolves by basename.

## Where to embed

| Target | Images |
|--------|--------|
| Study note | All key figures per section |
| Concept pages | 1–3 most relevant each |
| Source pages | Optional thumbnail only |

## Skip

- Decorative backgrounds
- Duplicate slides (e.g. same image on slides 24 and 29)
- WMF vector fragments (poor Obsidian support)
- Images under 5 KB (likely icons)

---
name: wiki-week-prep
description: >
  End-to-end university week prep: ingest Canvas materials, create Linear tasks
  (L71 lean-hybrid), write a lesson study note, atomise concepts, extract slide
  images, and wire the unit MOC. Use when the user drops a week folder (e.g.
  MAN5902/6), asks to process week materials, wants Linear tasks plus a lesson,
  or says week prep / study note / concepts / slide images for a unit week.
---

# wiki-week-prep: University Week Prep

Orchestrates one teaching week from raw Canvas exports → executable Linear board + durable wiki knowledge.

**Vault**: run from an **instance vault** (e.g. University-Vault), not Quibble-Vault template.

**Sub-skills** (read when needed):
- [`wiki-ingest`](../wiki-ingest/SKILL.md) — source filing, manifest, locks
- [`save`](../save/SKILL.md) — frontmatter, log, hot, index
- [`docling`](../docling/SKILL.md) — Office/PDF pre-convert when installed

**References** (read before Linear + naming):
- [Linear L71 conventions](references/linear-l71.md)
- [Naming templates](references/naming.md)
- [Slide image extraction](references/slide-images.md)

---

## Trigger phrases

- "Process week N for {UNIT}"
- User attaches `~/Documents/ECU/{UNIT}/{n}` or `.raw/units/{UNIT}/week-{nn}/`
- "Add to Linear and give me a lesson"
- "Week prep" / "study note + concepts + images"

---

## Inputs

| Input | Example |
|-------|---------|
| Source folder | `~/Documents/ECU/MAN5902/6` |
| Unit code | `MAN5902` |
| Week number | `6` |
| Unit MOC | `wiki/mocs/MAN5902 MOC.md` |
| Linear parent | `INK-69` (see [linear-l71.md](references/linear-l71.md)) |

---

## Outputs (checklist)

Copy and track:

```
Week prep progress:
- [ ] 1. Sources copied to .raw/units/{UNIT}/week-{nn}/
- [ ] 2. Text extracted (mhtml + pptx/docx via docling or python)
- [ ] 3. Linear issues created (prep / class / submit×n)
- [ ] 4. Lesson study note written
- [ ] 5. Concept pages created or updated
- [ ] 6. Slide images extracted + embedded
- [ ] 7. Unit MOC + index + log + hot updated
- [ ] 8. Manifest + address_map updated
```

Deliver to user: activities table, Linear issue links, study note wikilink, concept list.

---

## Workflow

### Phase 0 — Orient

1. `cd` to **instance vault root** (`WIKI_VAULT_ROOT`).
2. Read `wiki/hot.md`, unit MOC, prior week study note (pattern).
3. Grep Linear / MOC for existing `{UNIT} W{n}` issues — **do not duplicate**.
4. Authenticate Linear MCP if needed: `plugin-linear-linear` → `mcp_auth`.

### Phase 1 — Ingest sources

1. Copy immutably to `.raw/units/{UNIT}/week-{nn}/` (preserve filenames).
2. Extract text:
   - **MHTML**: Python email parser → `.raw/converted/units/{UNIT}/week-{nn}/` (optional)
   - **PPTX/DOCX/PDF**: `docling` when available
3. Read **all** pages: Overview, Before Class, During Class, After Class, slides deck.
4. Record authoritative **deadlines** from After Class (not syllabus if they conflict).

### Phase 2 — Linear tasks

Create **3–5 child issues** under the unit parent. See [naming.md](references/naming.md).

| Issue | Label | Milestone |
|-------|-------|-----------|
| Before class prep | `{UNIT}`, `prep` | Phase by due date, or `Due —` if feeds major artefact |
| Class / workshop | `{UNIT}`, `class` | Same |
| FeedbackFruits draft | `{UNIT}`, `submit` | Phase (not artefact unless major graded pack) |
| Peer feedback | `{UNIT}`, `submit` | Phase; `blockedBy` draft |
| Final + Canvas/Portflow | `{UNIT}`, `submit` | Phase or `Due —` artefact |

**Project**: `ECU | L71 | Master of Management Information Systems`  
**Team**: `InkytheSquid` · **Assignee**: `me`

Issue descriptions: deadlines, file names, wiki wikilinks, CLO alignment, `blockedBy` chain for submit issues.

### Phase 3 — Lesson study note

**Path**: `wiki/notes/{UNIT} W{n} {Topic} Study Note.md`  
**Type**: `synthesis` · **Tags**: `{unit-lower}`, `week-{nn}`, `study-note`

Structure:

1. One-sentence version
2. Activities + deadlines table (authoritative dates)
3. Linear issue table
4. Lesson sections (teach the material; not just a summary)
5. Workshop / submission checklist
6. Self-check Q&A with answers
7. Sources + attachment index

Link to unit MOC, textbook note, case study, prior week notes.

### Phase 4 — Concept pages

Identify **atomic concepts** introduced this week (not every bullet). For each:

- **Create** `wiki/notes/{Concept Name}.md` if missing (`type: concept`)
- **Update** existing concepts with new cross-links only
- Typical Week 6-style atoms: CRUD technique, fully developed use cases, activity diagrams, SSD, SMD

Each concept page: definition, notation/rules, one example, links to study note + sources.

**Study note**: replace inline detail with `[[Concept]]` wikilinks; keep worked examples (e.g. CCIS-specific).

### Phase 5 — Slide images

1. Run `python3 skills/wiki-week-prep/scripts/extract-pptx-images.py` (see [slide-images.md](references/slide-images.md)).
2. Save to `_attachments/{unit-lower}/week-{nn}/w{n}-{topic}.png`.
3. Embed in study note + concept pages: `![[w6-crud-verify-use-cases.png]]` (unique filenames).
4. Caption with slide number + Satzinger attribution when from textbook slides.

Skip tiny icons, WMF, and duplicate slides.

### Phase 6 — Wire the vault

Under `wiki-lock` (sorted paths):

| File | Action |
|------|--------|
| `wiki/mocs/{UNIT} MOC.md` | Frontmatter `current_week` + `current_study_note`; replace `## Current week` body; upsert `### Week {n} — {topic}` at top of `## Weeks` (create `## Weeks` if missing); append new concepts to `## Concepts` |
| `wiki/index.md` | Week section with study note + concepts |
| `wiki/log.md` | Append-only entries (ingest, concepts, assets) |
| `wiki/hot.md` | Overwrite cache: active week, next deadlines |
| `.raw/.manifest.json` | Hash sources, address_map for new pages |
| Textbook / case study notes | Cross-links only if relevant |

MOC write rules (University-Vault LYT):

1. Set `current_week: {n}` and `current_study_note: "[[{UNIT} W{n} … Study Note]]"` on the unit MOC.
2. Replace the entire `## Current week` section body with the Current week card (Study note, Sources, Concepts, Linear, optional Figures/raw). Do not append a second Current week.
3. Under `## Weeks`, insert or refresh a single `### Week {n} — {short topic}` block at the **top** (newest first). Include Study note, Sources, Concepts, Linear, Class/Canvas in one block.
4. Do **not** create `## Week {n} Linear` or `## Week {n} source summaries` headings.
5. Add newly created concept pages to the MOC `## Concepts` list if missing.

Allocate addresses: `bash scripts/allocate-address.sh` per new page.

### Phase 7 — Teach the user

After filing, deliver in chat:

1. **Activities summary** (when / what / due)
2. **Linear table** with issue URLs
3. **Lesson** (full teaching prose — the study note is the vault copy; chat lesson helps immediate prep)

---

## Unit-specific patterns

### MAN5902 (weekly tutorial cycle)

Usually **5 Linear issues**: prep, class, FbF draft, peer feedback, Canvas pack.  
Parent: `INK-69`. Case study: [[CCIS case study]] for weeks 1–6.

### MAN6925 (Friday workshop)

Often **2 issues**: before class prep, workshop + Portflow. Parent: `INK-70`.

### CSI6208 (weekly explore + workshop)

Pattern varies; check prior week in unit MOC.

---

## Do NOT

- File personal content into Quibble-Vault template
- Modify `.raw/` sources after copy
- Create per-week Linear milestones
- Duplicate existing Linear issues for the same week
- Milestone FeedbackFruits / peer review / weekly Portflow on `Due —` pins
- Skip `wiki-lock` on multi-file writes

---

## Example invocation

```
Process MAN5902 week 6 from ~/Documents/ECU/MAN5902/6 —
Linear tasks, lesson study note, concepts, slide images.
```

Expected artefacts: `MAN5902 W6 Verifying Requirements Study Note`, concepts CRUD/SSD/SMD/etc., INK-178–182, `_attachments/man5902/week-06/w6-*.png`.

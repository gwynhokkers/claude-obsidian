# Naming templates (wiki-week-prep)

## Linear issue titles

```
{UNIT} W{n} — Before class: {short topic}
{UNIT} W{n} — Class: {activity name}
{UNIT} W{n} — FeedbackFruits draft {artefact}
{UNIT} W{n} — Peer feedback (FeedbackFruits)
{UNIT} W{n} — Final + Canvas pack
```

Examples:

- `MAN5902 W6 — Before class: Ch5 verifying requirements models`
- `MAN5902 W6 — Class: Verifying requirements models CCIS`

## Wiki pages

| Type | Path pattern |
|------|----------------|
| Study note | `wiki/notes/{UNIT} W{n} {Topic} Study Note.md` |
| Concept | `wiki/notes/{Concept Name}.md` |
| Source (optional) | `wiki/notes/{UNIT} Week {n} {Page}.md` |

Study notes are `type: synthesis`. Concepts are `type: concept`.

## Raw sources

```
.raw/units/{UNIT}/week-{nn}/
.raw/converted/units/{UNIT}/week-{nn}/
```

Week folder uses zero-padded `week-06` for sorting.

## Attachments

```
_attachments/{unit-lower}/week-{nn}/w{n}-{descriptive-name}.png
```

Prefix with `w{n}-` for uniqueness across the vault. Prefer `.png` / `.jpeg`; skip `.wmf`.

## MAN5902 submit file names

Read from After Class page. Typical pattern:

- `W{n}FbF_{Topic}Draft_Surname_SID.docx`
- `W{n}FbF_{Topic}Feedback_Surname_SID.docx`
- `W{n}_{Topic}Final_Surname_SID.docx`

Note naming inconsistencies in the study note if Canvas Task 5 copy-pastes wrong names.

## Frontmatter minimum

```yaml
type: synthesis | concept | source
title: "..."
address: c-0000xx
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [unit-lower, week-nn, ...]
status: developing
related: ["[[MAN5902 MOC]]", ...]
linear: "INK-xxx"   # study note: first issue of the week
```

Unit MOC (when week-prep wires the hub):

```yaml
current_week: {n}
current_study_note: "[[{UNIT} W{n} {Topic} Study Note]]"
```

# Risk skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Quibble-Vault skill named `risk` that drafts a two-page risk pack in chat, and files it into University-Vault or Work-Vault only after the user says `file it`.

**Architecture:** One skill, three modes (`plan`, `step`, `row`), one register shape. The method (process, strategies, effort grid, columns) lives in a reference file. The skill file is the session procedure and the refusal list. A contract test locks the wording the agent must follow. Instance vaults already symlink `skills/`, so no copy into University or Work.

**Tech Stack:** Agent Skill markdown, Python 3 stdlib contract test, existing `scripts/wiki-lock.sh` and `scripts/allocate-address.sh` when the target vault has them.

## Global Constraints

- Skill path: `skills/risk/SKILL.md` in Quibble-Vault. Do not file packs into Quibble-Vault.
- Modes: `risk plan`, `risk step <name>`, `risk row`. Step names: `ambiguity`, `volatility`, `identify`, `appetite`, `analyse`, `strategic`, `unknowns`, `respond`, `triggers`.
- Does not fire because a note mentions risk. The user calls it.
- Source gate: list pages, wait, do not read until the user confirms. Revise the list if they add or drop a page. Do not crawl. Do not read `.raw/` unless the user names that page.
- Write gate: chat only until the user says `file it`. "Looks good" does not write.
- Do not invent appetite, tolerance, owner, approver, or money. Missing facts stay questions.
- Do not score until tolerances exist.
- Effort grid: low probability and high impact is `monitor closely`, response ready. Do not switch grids silently. A stated low appetite may move a cell up.
- Pack is two pages: `{Project} risk plan` and `{Project} risk register`. Reserve is a section of the plan. Update an existing pair. Do not create `{Project} risk register 2`.
- Register columns, in order: statement (if-then-effect), threat or opportunity, category, probability, impact, effort, strategy, action, owner, approver, response cost, cost if the risk occurs, trigger, status. The spec's items 4 and 10 are stored as two columns each (probability and impact; response cost and cost if the risk occurs).
- Draft a response only when effort is `deep dive` or `some mitigation`. Every row with a response has a trigger.
- Frontmatter: `type: synthesis`, `status: developing`, `created`, `updated`, `tags` including `risk`, `related` to the pair page. Assign an address only if that vault has `scripts/allocate-address.sh`.
- University pages: `wiki/notes/`. If a unit was named, link the unit MOC. Also update index, log, and hot cache.
- Work pages: the named project area if it exists (example `wiki/areas/Leads/`), otherwise `wiki/projects/`. Link the project area page if one was named. Also update index, log, and hot cache.
- Never write `.raw/`. Never email, post, or export.
- Method text is original. Do not copy course prompt wording. Forbidden fingerprints: `As a project manager and`, `at least 15 years of experience`.
- Wiki writes acquire `scripts/wiki-lock.sh` then release it.
- A full plan follows plan, identify, analyse, plan responses. Implement and monitor, beyond triggers and status, are out of version one.
- British English in skill text. No em dashes.

## File map

- Create: `tests/test_risk_skill.py` — contract test. Fails if required phrases or files are missing.
- Create: `skills/risk/references/method.md` — process, strategies, effort grid, columns, acceptance tests.
- Create: `skills/risk/references/fixture.md` — fake brief for the manual check. Not a vault page.
- Create: `skills/risk/SKILL.md` — triggers, session, refusals, filing.
- Modify: `AGENTS.md` — skill table row.
- Modify: `CLAUDE.md` — plugin skill table row.

---

### Task 1: Method contract and method reference

**Files:**
- Create: `tests/test_risk_skill.py`
- Create: `skills/risk/references/method.md`
- Test: `tests/test_risk_skill.py`

**Interfaces:**
- Consumes: nothing
- Produces: `skills/risk/references/method.md` with the exact effort-grid line `Low probability and high impact: monitor closely`, the twelve column names in order, both strategy families, and the acceptance tests. Later tasks must not rename these.

- [ ] **Step 1: Write the failing test**

Create `tests/test_risk_skill.py`:

```python
#!/usr/bin/env python3
"""Contract test for the risk skill. No network, no vault writes.

Usage:
  python3 tests/test_risk_skill.py
"""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent
METHOD = ROOT / "skills" / "risk" / "references" / "method.md"

COLUMNS = [
    "statement",
    "threat or opportunity",
    "category",
    "probability",
    "impact",
    "effort",
    "strategy",
    "action",
    "owner",
    "approver",
    "response cost",
    "cost if the risk occurs",
    "trigger",
    "status",
]

REQUIRED_METHOD = [
    "Low probability and high impact: monitor closely",
    "avoid",
    "escalate",
    "transfer",
    "mitigate",
    "accept",
    "exploit",
    "share",
    "enhance",
    "deep dive",
    "some mitigation",
    "review regularly",
    "appropriate to the significance",
    "cost-effective",
    "realistic",
    "agreed",
    "owned",
]


def fail(msg):
    print(f"FAIL: {msg}")
    return 1


def test_method():
    errors = 0
    if not METHOD.is_file():
        return fail(f"missing {METHOD}")
    text = METHOD.read_text(encoding="utf-8")
    lower = text.lower()
    for phrase in REQUIRED_METHOD:
        if phrase.lower() not in lower:
            errors += fail(f"method.md missing {phrase!r}")
    for fingerprint in ("As a project manager and", "at least 15 years of experience"):
        if fingerprint in text:
            errors += fail(f"method.md contains forbidden fingerprint {fingerprint!r}")
    register = lower.split("## register columns", 1)
    if len(register) != 2:
        errors += fail("method.md missing Register columns section")
        return errors
    columns_text = register[1]
    positions = []
    for column in COLUMNS:
        idx = columns_text.find(column)
        if idx < 0:
            errors += fail(f"method.md missing column {column!r}")
        else:
            positions.append(idx)
    if positions != sorted(positions):
        errors += fail("method.md columns are not in the required order")
    return errors


if __name__ == "__main__":
    sys.exit(test_method())
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `python3 tests/test_risk_skill.py`

Expected: FAIL with `missing` and the path to `skills/risk/references/method.md`. Exit code is not 0.

- [ ] **Step 3: Write the method reference**

Create `skills/risk/references/method.md`:

```markdown
# Risk method

Original wording of the project-risk method used by the `risk` skill. Do not paste external prompt text into this file.

## Process

1. Plan: how risks will be found, scored, reported, and funded.
2. Identify: threats and opportunities.
3. Analyse: probability and impact, then an effort cell. Do not score until tolerances exist.
4. Plan responses: a strategy and an action only where the effort cell is deep dive or some mitigation.
5. Implement and monitor, beyond a named owner, a trigger, and a status, are out of version one.

Course moves used inside that process, not a second sequence: ambiguity, volatility, identify, appetite, analyse, strategic, unknowns, respond, triggers.

## Strategies

Threats: avoid, escalate, transfer, mitigate, accept.

Opportunities: exploit, escalate, share, enhance, accept.

A response is acceptable only when it is appropriate to the significance of the risk, cost-effective, realistic, agreed, and owned. If the response cost is not lower than the cost if the risk occurs, leave both money cells as questions.

## Effort grid

Named grid: section-3. Do not substitute another grid. A stated low appetite may move a cell up. It may not invent the appetite.

| Probability \ Impact | Low impact | Medium impact | High impact |
|----------------------|------------|---------------|-------------|
| High probability | Monitor closely | Some mitigation | Deep dive |
| Medium probability | Review regularly | Some mitigation | Deep dive |
| Low probability | Review regularly | Monitor closely | Monitor closely |

Low probability and high impact: monitor closely

That cell means accept for now, watch whether probability rises, and have the response ready. It is not a deep dive.

Definitions of low, medium, and high must be written on the plan page before any score is assigned.

## Register columns

Use these names, in this order. Do not add or drop columns.

1. statement (if-then-effect)
2. threat or opportunity
3. category
4. probability
5. impact
6. effort
7. strategy
8. action
9. owner
10. approver
11. response cost
12. cost if the risk occurs
13. trigger
14. status

Draft a strategy and an action only when effort is deep dive or some mitigation. Every row that has a response also has a trigger. Unknown owner, approver, or money stays the literal question `?`.
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `python3 tests/test_risk_skill.py`

Expected: no FAIL lines. Exit code 0.

- [ ] **Step 5: Commit**

```bash
git add tests/test_risk_skill.py skills/risk/references/method.md
git commit -m "$(cat <<'EOF'
Add the risk method reference and its contract test.

The skill needs one register shape and one effort grid before any session procedure is written.

EOF
)"
```

---

### Task 2: Fixture brief

**Files:**
- Modify: `tests/test_risk_skill.py`
- Create: `skills/risk/references/fixture.md`
- Test: `tests/test_risk_skill.py`

**Interfaces:**
- Consumes: `test_method()` from Task 1
- Produces: `skills/risk/references/fixture.md`, a fake brief with no tolerances and no client names. The manual check in Task 4 reads this file.

- [ ] **Step 1: Extend the test so it fails**

In `tests/test_risk_skill.py`, add `FIXTURE = ROOT / "skills" / "risk" / "references" / "fixture.md"` next to `METHOD`. Add:

```python
def test_fixture():
    errors = 0
    if not FIXTURE.is_file():
        return fail(f"missing {FIXTURE}")
    text = FIXTURE.read_text(encoding="utf-8")
    for phrase in ("North Quay kiosk", "no tolerances are stated", "not a vault page"):
        if phrase not in text:
            errors += fail(f"fixture.md missing {phrase!r}")
    for banned in ("Acme", "client", "confidential"):
        if banned.lower() in text.lower():
            errors += fail(f"fixture.md must not contain {banned!r}")
    return errors
```

Change the main block to:

```python
if __name__ == "__main__":
    sys.exit(test_method() or test_fixture())
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `python3 tests/test_risk_skill.py`

Expected: FAIL with `missing` and the path to `fixture.md`. `test_method` still passes, then `test_fixture` fails. Exit code is not 0.

- [ ] **Step 3: Write the fixture**

Create `skills/risk/references/fixture.md`:

```markdown
# Fixture: North Quay kiosk

This file is a fake brief for the risk skill manual check. It is not a vault page. It names no organisation and holds no private records. In this brief, no tolerances are stated.

## Delivery

A campus wants a small kiosk where students collect borrowed adapters. The project lasts ten weeks. Two staff know the current paper log. The build uses a badge reader the campus has not used before.

## Facts the brief does not contain

No appetite. No tolerance for cost, schedule, or privacy. No named owner. No budget figure. Do not invent them.
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `python3 tests/test_risk_skill.py`

Expected: exit code 0.

- [ ] **Step 5: Commit**

```bash
git add tests/test_risk_skill.py skills/risk/references/fixture.md
git commit -m "$(cat <<'EOF'
Add a fake brief so the risk skill can be checked without client data.

The fixture states no tolerances, which is what blocks scoring.

EOF
)"
```

---

### Task 3: Skill procedure

**Files:**
- Modify: `tests/test_risk_skill.py`
- Create: `skills/risk/SKILL.md`
- Test: `tests/test_risk_skill.py`

**Interfaces:**
- Consumes: `skills/risk/references/method.md` column order and effort grid. `skills/risk/references/fixture.md` is mentioned as the manual-check brief only.
- Produces: `skills/risk/SKILL.md`. Modes are the exact strings `risk plan`, `risk step`, and `risk row`. The write phrase is the exact string `file it`.

- [ ] **Step 1: Extend the test so it fails**

In `tests/test_risk_skill.py`, add `SKILL = ROOT / "skills" / "risk" / "SKILL.md"`. Add:

```python
REQUIRED_SKILL = [
    "risk plan",
    "risk step",
    "risk row",
    "ambiguity",
    "volatility",
    "identify",
    "appetite",
    "analyse",
    "strategic",
    "unknowns",
    "respond",
    "triggers",
    "file it",
    "Looks good",
    "wiki/notes/",
    "wiki/projects/",
    "wiki/areas/",
    "Do not file into Quibble-Vault",
    "Do not read a page the user has not confirmed",
    "Do not score until tolerances exist",
    "references/method.md",
    "type: synthesis",
    "wiki-lock.sh",
    "allocate-address.sh",
    "{Project} risk plan",
    "{Project} risk register",
    "Do not create a second register",
]


def test_skill():
    errors = 0
    if not SKILL.is_file():
        return fail(f"missing {SKILL}")
    text = SKILL.read_text(encoding="utf-8")
    for phrase in REQUIRED_SKILL:
        if phrase not in text:
            errors += fail(f"SKILL.md missing {phrase!r}")
    for fingerprint in ("As a project manager and", "at least 15 years of experience"):
        if fingerprint in text:
            errors += fail(f"SKILL.md contains forbidden fingerprint {fingerprint!r}")
    return errors
```

Change the main block to:

```python
if __name__ == "__main__":
    sys.exit(test_method() or test_fixture() or test_skill())
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `python3 tests/test_risk_skill.py`

Expected: FAIL with `missing` and the path to `skills/risk/SKILL.md`. Exit code is not 0.

- [ ] **Step 3: Write the skill**

Create `skills/risk/SKILL.md` with this content:

```markdown
---
name: risk
description: >
  Draft a project risk plan and register in chat, then file a two-page pack
  into University-Vault or Work-Vault only after the user says file it.
  Triggers on: risk plan, risk step, risk row, /risk.
  Does not trigger because a note merely mentions risk. Writing still requires the exact phrase file it.
---

# risk

One method, three modes. Read `references/method.md` before drafting. Use its effort grid and its register columns, in that order. Do not substitute another grid. Do not add or drop columns.

This skill does not fire because a note mentions risk. The user calls it.

| Call | What you draft in chat |
|------|------------------------|
| `risk plan` | The pack: a risk plan (appetite questions and a reserve section included), then a register |
| `risk step <name>` | One move |
| `risk row` | One register row |

Step names: `ambiguity`, `volatility`, `identify`, `appetite`, `analyse`, `strategic`, `unknowns`, `respond`, `triggers`. An unknown step name is a stop: list the names and ask which one.

A full plan follows plan, identify, analyse, then plan responses. The step names are moves inside that process, not a second sequence. Implement and monitor, beyond a trigger and a status, are out of version one.

## Session

1. Name the vault and the project. If the current folder is an instance vault, use it. If it is Quibble-Vault and no vault was named, stop and ask. Do not file into Quibble-Vault.
2. List the vault pages you want to read, including an existing `{Project} risk plan` or `{Project} risk register` if you know one by name. Do not read a page the user has not confirmed. Do not crawl. Do not open `.raw/` or an attachment unless the user named that page. If they add or drop a page, revise the list and wait again.
3. Draft in chat only.
   - `risk plan`: what the project delivers, then appetite and tolerance questions, then threats and opportunities. If tolerances are missing, draft the risks and the questions, and say scoring is blocked. Do not score until tolerances exist. After tolerances exist, assign probability, impact, and the effort cell from `references/method.md`. Draft a strategy and an action only when effort is deep dive or some mitigation. Every such row has a trigger.
   - `risk step`: draft only that move, using the same columns when the move produces rows.
   - `risk row`: draft one row. Same columns. Unknown owner, approver, or money is `?`.
4. The user edits in the chat. Silence is not approval. `Looks good` does not write.
5. Write only when the user says `file it`. State the two paths, then create or update those pages. If they already exist, update them. Do not create a second register.
6. A change of tolerance, risk, or strategy is a new call. Do not rewrite the pack on your own.

If a step cannot finish, say what is missing and stop that step. Leave the rest of the draft in the chat.

## Filing

Write two pages.

| Page | Contents |
|------|----------|
| `{Project} risk plan` | How risks will be found, scored, reported, and funded. Appetite and tolerances as a table. Unknown cells are questions. Contingency and management reserve are a section. Draft amounts are labelled draft. Name the effort grid: `section-3` from `references/method.md`. |
| `{Project} risk register` | One row per risk, columns from `references/method.md`. |

Frontmatter on both pages:

```yaml
---
type: synthesis
title: "{Project} risk plan"
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags:
  - risk
status: developing
related:
  - "[[{Project} risk register]]"
---
```

The register page points `related` at the plan page. Assign `address:` only when `scripts/allocate-address.sh` is executable and `.vault-meta/` exists in that vault. Run it from the vault root. Do not edit the address counter by hand.

| Vault | Path | Also update |
|-------|------|-------------|
| University | `wiki/notes/` | `wiki/index.md`, `wiki/log.md`, `wiki/hot.md`. If a unit was named, add a link on `wiki/mocs/{UNIT} MOC.md` |
| Work | The named project area if that directory exists (for example `wiki/areas/Leads/`). Otherwise `wiki/projects/` | `wiki/index.md`, `wiki/log.md`, `wiki/hot.md`. Link from the project area page if one was named |

Before each write, from the vault root, acquire a lock with `bash scripts/wiki-lock.sh acquire <vault-relative-path>`. Release it with `bash scripts/wiki-lock.sh release <vault-relative-path>` after the write. Acquire in sorted path order.

Never write `.raw/`.

## Refusals

These are stops, not warnings you then ignore.

- No named vault when the current folder is Quibble-Vault. Do not file into Quibble-Vault.
- Do not read a page the user has not confirmed.
- Do not invent appetite, tolerance, owner, approver, or money.
- Do not score until tolerances exist.
- Do not write before the phrase `file it`.
- Do not create a second register. Update the existing pair.
- Do not change the effort grid named on the plan page unless the user says so.
- Do not email, post, or export the pack.

## Manual check

`references/fixture.md` is not a vault page. Use it only to rehearse a chat draft. It states no tolerances. A rehearsal must refuse to score.
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `python3 tests/test_risk_skill.py`

Expected: exit code 0.

- [ ] **Step 5: Commit**

```bash
git add tests/test_risk_skill.py skills/risk/SKILL.md
git commit -m "$(cat <<'EOF'
Add the risk skill session, filing rules, and refusals.

Chat stays the draft until the user says file it, and packs never land in the template vault.

EOF
)"
```

---

### Task 4: Catalogue the skill

**Files:**
- Modify: `AGENTS.md`
- Modify: `CLAUDE.md`
- Test: `tests/test_risk_skill.py` (still green; this task does not change it)

**Interfaces:**
- Consumes: skill name `risk` and triggers `risk plan`, `risk step`, `risk row` from `skills/risk/SKILL.md`
- Produces: catalogue rows so agents that read `AGENTS.md` or `CLAUDE.md` can find the skill. The skill file remains the procedure.

- [ ] **Step 1: Confirm the contract test still passes before editing catalogues**

Run: `python3 tests/test_risk_skill.py`

Expected: exit code 0.

- [ ] **Step 2: Add the catalogue rows**

In `AGENTS.md`, in the Available Skills table, after the `wiki-query` row, add:

```markdown
| `risk` | `risk plan`, `risk step`, `risk row`, `/risk` |
```

In `CLAUDE.md`, in the Plugin Skills table, after the `/think` row, add:

```markdown
| `risk` | Draft a risk plan and register in chat. File into an instance vault only after `file it`. |
```

- [ ] **Step 3: Confirm the skill file was not required in two places**

Run: `ls -l skills .cursor/skills`

Expected: `.cursor/skills` is a symlink to `skills` (or to the repo `skills` directory). Do not copy `skills/risk` into a second tree.

- [ ] **Step 4: Commit**

```bash
git add AGENTS.md CLAUDE.md
git commit -m "$(cat <<'EOF'
List the risk skill in the agent catalogues.

The procedure stays in the skill file. The catalogues only show how to call it.

EOF
)"
```

---

### Task 5: Manual check against the fixture

**Files:**
- Read: `skills/risk/SKILL.md`
- Read: `skills/risk/references/method.md`
- Read: `skills/risk/references/fixture.md`
- Test: `python3 tests/test_risk_skill.py` must still exit 0

**Interfaces:**
- Consumes: the skill procedure and the fixture brief
- Produces: a written pass or fail for each check below. A fail means edit `skills/risk/SKILL.md` or `references/method.md`, re-run the contract test, and repeat the failed check. Do not file the fixture into a vault.

- [ ] **Step 1: Re-run the contract test**

Run: `python3 tests/test_risk_skill.py`

Expected: exit code 0.

- [ ] **Step 2: Walk the checks by reading the skill against the fixture**

Answer each item from the files. Do not invent a vault write.

| Check | Pass when the skill text says this |
|-------|-------------------------------------|
| Quibble-Vault, no vault named | Stop and ask. Do not file into Quibble-Vault |
| Two page names given | List them. Do not read until confirmed |
| Full plan, fixture has no tolerances | Draft risks and questions. Say scoring is blocked. Do not score |
| One row | Same columns as `references/method.md` |
| "Looks good" | Does not write |
| `file it` | Writes exactly two pages, plus index, log, and hot cache |
| Second `file it` | Updates those pages. Does not create a second register |
| University | `wiki/notes/`, and a unit MOC link when a unit was named |
| Work | Named project area if that directory exists, otherwise `wiki/projects/` |

- [ ] **Step 3: If any check fails, fix the skill text and re-run**

Run: `python3 tests/test_risk_skill.py`

Expected: exit code 0 after the fix.

- [ ] **Step 4: Commit only if Step 3 changed files**

```bash
git add skills/risk/SKILL.md skills/risk/references/method.md
git commit -m "$(cat <<'EOF'
Align the risk skill with the manual filing checks.

A failed check is a missing sentence in the procedure, not a vault write.

EOF
)"
```

If Step 3 changed nothing, do not commit.

---
type: design
title: "Risk skill"
created: 2026-09-14
updated: 2026-09-14
status: approved
tags: [risk, skill, university-vault, work-vault, design]
---

# Design: Risk skill

**Date:** 2026-09-14
**Vaults:** Quibble-Vault (skill home). Outputs go to University-Vault (LYT) or Work-Vault (PARA). Never to the template wiki.
**Approach:** One skill, three modes, one pack
**Status:** Approved in chat. Not implemented.

## Problem

The LinkedIn course *Project Management Foundations: Risk* (Bob McGannon) supplies a method, templates, and prompts. The useful part is the method: identify both threats and opportunities, score only after tolerances exist, choose a strategy, and justify the response cost against the cost if the risk occurs.

There is no shared way to apply that method in University-Vault or Work-Vault. Doing it by hand means pasting course prompts, inventing missing numbers, and filing differently in each vault.

## Goals

- One skill, `risk`, callable from University-Vault and Work-Vault
- Three ways in, one register shape: a full plan, one course step, or one register row
- Draft in chat until the user says `file it`
- Read only vault pages the user confirms
- File a two-page pack the user can review, routed by vault methodology

## Non-goals

- A live risk system, spreadsheet engine, or budget approval
- Email, export, or posting the pack
- Copying LinkedIn prompts or exercise-file wording into the skill
- Crawling a vault, or reading `.raw/` unless the user names that page
- Filing into Quibble-Vault
- Creating a second register for a project that already has one

## Decisions

| Decision | Choice |
|----------|--------|
| Shape | One skill, three modes. Not a chat playbook, and not a skill per move |
| Source gate | List the pages to read. Wait. Do not read until the user confirms. Revise the list if they add or drop a page |
| Write gate | Chat only until the user says `file it`. "Looks good" does not write |
| Missing facts | Appetite, tolerance, owner, approver, and money stay questions. Do not invent them |
| Scoring | Blocked until tolerances exist |
| Effort grid | Section 3 grid, named on the plan page. Low probability and high impact is "monitor closely", response ready. Do not switch grids silently. A stated low appetite may move a cell up |
| Pack | Two pages: risk plan and risk register. Reserve is a section of the plan |
| Method text | Written in our words. Exercise files stay where they already are, as pointers |

## Skill

**Path:** `skills/risk/SKILL.md` in Quibble-Vault, so instance vaults pick it up through the existing skills link.

**Does not fire** because a note mentions risk. The user calls it.

| Call | Drafts in chat |
|------|----------------|
| `risk plan` | The pack: plan (including appetite questions and a reserve section), then a register |
| `risk step <name>` | One move |
| `risk row` | One register row |

Step names: `ambiguity`, `volatility`, `identify`, `appetite`, `analyse`, `strategic`, `unknowns`, `respond`, `triggers`.

A full plan follows the six process steps (plan, identify, analyse, plan responses, implement, monitor). The named steps above are the course moves used inside that process, not a second sequence. A step or a row uses the same register columns, so a later `file it` appends to the existing pack. Implement and monitor, beyond triggers and status, are out of version one.

### References

- `skills/risk/references/method.md` holds the paraphrased method: process order, strategy names, acceptance tests, the effort grid, and the column list. No LinkedIn prompt text.
- `skills/risk/references/fixture.md` is a fake one-page brief with no client data, used only for the manual check. It is not a vault page.

## Filed pack

`file it` writes two pages.

| Page | Contents |
|------|----------|
| `{Project} risk plan` | How risks will be found, scored, reported, and funded. Appetite and tolerances as a table. Unknown cells are questions. Contingency and management reserve are a section, with draft amounts labelled draft. The effort grid in use is named here. |
| `{Project} risk register` | One row per risk |

If those pages already exist, `file it` updates them. It does not create `{Project} risk register 2`. A step or a row that is filed creates the pair if it is missing, and leaves unused parts as questions.

### Register columns

In this order:

1. Statement, if-then-effect
2. Threat or opportunity
3. Category
4. Probability and impact, each low, medium, or high, with the definition used
5. Effort: deep dive, some mitigation, monitor closely, or review regularly
6. Strategy
7. Action
8. Owner
9. Approver
10. Response cost, and cost if the risk occurs
11. Trigger
12. Status

A response is drafted only where the effort cell is deep dive or some mitigation. Every row that has a response also has a trigger.

Frontmatter is flat YAML: `type: synthesis`, `status: developing`, `created`, `updated`, `tags` including `risk`, and `related` links to the pair page. Assign an address only if that vault has `scripts/allocate-address.sh`.

## Where pages land

| Vault | Path | Also update |
|-------|------|-------------|
| University | `wiki/notes/` | Index, log, hot cache. If a unit was named, add a link on that unit MOC |
| Work | The named project area if it exists (for example `wiki/areas/Leads/`). Otherwise `wiki/projects/` | Index, log, hot cache. Link from the project area page if one was named |

Never write `.raw/`. Never file into Quibble-Vault.

## Session

1. **Name the vault and the project.** If the current folder is an instance vault, use it. If it is Quibble-Vault and no vault was named, stop and ask.
2. **List sources and wait.** Propose pages, including an existing plan or register if one is known by name. Do not read them until the user confirms. If they add or drop a page, revise the list and wait again.
3. **Draft in chat.** A full plan drafts delivery outcome, then appetite questions, then risks (threats and opportunities), then scores, then responses, then triggers. A step drafts only that move. A row drafts one register row. Stop and ask when a fact is missing.
4. **The user edits in chat.** Silence is not approval.
5. **`file it` writes.** State the two paths, create or update those pages, then update index, log, and hot cache, plus the unit map or project-area link when one was named.
6. **A change is a new call.** A new tolerance, risk, or strategy is another step or row, not an automatic rewrite.

A full plan with no tolerances drafts the risks and the questions, and says scoring is blocked.

Wiki writes use the vault's existing lock, then release it.

## Refusals

Hard stops, not warnings that are then ignored.

- No named vault when the current folder is Quibble-Vault
- No read of a page the user has not confirmed, including `.raw/`, attachments, and confidential notes they did not explicitly include
- No invented appetite, tolerance, owner, approver, or money
- No scoring until tolerances exist
- No write before the phrase `file it`
- No second pack for the same project
- No silent change of the effort grid named on the plan page
- No email, post, or export

If a step cannot finish, say what is missing and stop that step. Leave the rest of the draft in the chat.

## How we know version one works

Manual run against `skills/risk/references/fixture.md`. No client data. All of these must hold:

- Called from Quibble-Vault with no vault named, it stops and asks
- Given two page names, it lists them and does not read them until confirmed
- A full plan with no tolerances drafts risks and questions, and does not score the register
- A single row uses the same columns as a full plan
- "Looks good" does not write. `file it` writes exactly two pages, plus index, log, and hot cache
- A second `file it` for the same project updates those pages and does not create a second register
- University output is under `wiki/notes/` and links the unit map when a unit was named
- Work output is under the named project area, or `wiki/projects/` if there is none

## Out of scope for a later version

Spreadsheets, email, budget approval, and a live register outside the vault.

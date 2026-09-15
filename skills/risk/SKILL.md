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

1. Name the vault and the project. If the current folder is an instance vault, use it. If it is Quibble-Vault and no vault was named, stop and ask. Do not file into Quibble-Vault. Only University-Vault and Work-Vault are supported targets. Any other vault is a stop: say so and ask.
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

A filed `risk step` or `risk row` still writes both pages. Create the pair if it is missing. Leave the parts the call did not cover as questions, not as invented content.

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

On the register page, set `title` to `{Project} risk register` and point `related` at `[[{Project} risk plan]]`. Do not leave the register titled as the plan. Assign `address:` only when `scripts/allocate-address.sh` is executable and `.vault-meta/` exists in that vault. Run it from the vault root. Do not edit the address counter by hand.

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

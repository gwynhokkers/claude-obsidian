# Vault Template Guide

How to use Quibble-Vault as a master template and spawn domain-specific instance vaults.

---

## Template vs instance

| | Master template (Quibble-Vault) | Instance vault |
|---|---|---|
| **Purpose** | Skills, scripts, spawn tooling | Day-to-day notes for one life domain |
| **wiki/** | Minimal + `_template-examples/` | Your real knowledge base |
| **skills/, bin/, scripts/** | Canonical copies | Symlinks back to template |
| **Notes** | Do not file personal content here | All ingests and saves go here |

---

## Spawn a new vault

```bash
cd /Users/gwynforhockridge/Documents/Quibble-Vault

bash bin/spawn-vault.sh \
  --name Personal-Vault \
  --purpose "Personal life, goals, health, relationships" \
  --wiki-mode D \
  --methodology para \
  --dest ~/Documents/Vaults/Personal-Vault
```

### Flags

| Flag | Required | Values |
|------|----------|--------|
| `--name` | Yes | Vault display name (e.g. `Personal-Vault`) |
| `--dest` | Yes | Absolute or `~` path for the new vault |
| `--purpose` | Yes | One-sentence description |
| `--wiki-mode` | Yes | `C`, `D`, or `E` (see modes.md) |
| `--methodology` | Yes | `generic`, `lyt`, `para`, `zettelkasten` |
| `--no-git` | No | Skip `git init` in instance |
| `--template` | No | Override template path (default: this repo) |

### Recommended mapping

| Vault | `--wiki-mode` | `--methodology` |
|-------|---------------|-----------------|
| Personal-Vault | D | para |
| University-Vault | E | lyt |
| Work-Vault | C | para |

---

## Vault registry

`.vault-meta/vault-registry.json` in the template tracks all spawned vaults:

```json
{
  "schema_version": 1,
  "template": "/path/to/Quibble-Vault",
  "vaults": [
    {
      "name": "Personal-Vault",
      "path": "/Users/you/Documents/Vaults/Personal-Vault",
      "purpose": "Personal life second brain",
      "wiki_mode": "D",
      "methodology": "para",
      "created": "2026-07-08"
    }
  ]
}
```

---

## Cross-vault query routing

When using the multi-vault workspace or hub rule, route by topic:

| Topic signals | Vault |
|---------------|-------|
| personal, health, goals, relationships, journal | Personal-Vault |
| university, course, lecture, assignment, research, paper | University-Vault |
| work, client, project, meeting, stakeholder, deliverable | Work-Vault |
| template, spawn, skill development | Quibble-Vault (template only) |

If unsure, ask which vault to use.

---

## Cursor setup

1. **Template**: open Quibble-Vault for spawn script development only.
2. **Instances**: open one vault folder for focused work, or `~/Documents/Vaults/Vaults.code-workspace` for cross-domain.
3. **Code projects**: add `.cursor/rules/wiki-context.mdc` pointing at the registry (see plan).

Each instance gets `.cursor/rules/vault-instance.mdc` on spawn.

---

## Obsidian

After spawn: Manage Vaults → Open folder as vault → select instance folder.

Run `bash bin/setup-vault.sh` is called automatically during spawn for Obsidian config.

---

## Optional upgrades (per instance)

```bash
cd ~/Documents/Vaults/Personal-Vault
bash bin/setup-retrieve.sh      # hybrid search (50+ pages)
bash bin/setup-dragonscale.sh   # log folds, addresses, semantic lint
```

---

## Daily workflows

| Habit | Command |
|-------|---------|
| Capture | Drop in `.raw/` → `ingest [file]` |
| Query | `what do you know about X?` |
| Save session | `/save` |
| Health | `lint the wiki` (every 10–15 ingests) |

---

## Troubleshooting

**Skills not found in Cursor**: ensure `.cursor/skills` symlinks to template `skills/` (spawn does this).

**Wrong vault targeted**: check `WIKI_VAULT_ROOT` or run commands from the instance vault directory.

**Mode filing wrong folder**: re-run `bash bin/setup-mode.sh --mode para --dest /path/to/vault`.

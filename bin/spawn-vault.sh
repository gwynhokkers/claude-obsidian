#!/usr/bin/env bash
# spawn-vault.sh — create a slim instance vault from the Quibble-Vault template.
#
# Usage:
#   bash bin/spawn-vault.sh \
#     --name Personal-Vault \
#     --purpose "Personal life second brain" \
#     --wiki-mode D \
#     --methodology para \
#     --dest ~/Documents/Vaults/Personal-Vault
#
# Flags:
#   --name NAME           Vault display name (required)
#   --dest PATH           Destination directory (required)
#   --purpose TEXT        One-sentence purpose (required)
#   --wiki-mode C|D|E     Wiki structure mode (required)
#   --methodology MODE    generic|lyt|para|zettelkasten (required)
#   --template PATH       Template root (default: parent of bin/)
#   --no-git              Skip git init
#   -h|--help             Show help
#
# Exit codes: 0 success, 2 usage, 3 target exists, 4 invalid flag value

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$(dirname "$SCRIPT_DIR")"

NAME=""
DEST=""
PURPOSE=""
WIKI_MODE=""
METHODOLOGY=""
NO_GIT=false

usage() {
  sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'
}

die() { echo "ERR: $*" >&2; exit 2; }

while [ $# -gt 0 ]; do
  case "$1" in
    --name)        NAME="${2:-}"; shift 2 ;;
    --dest)        DEST="${2:-}"; shift 2 ;;
    --purpose)     PURPOSE="${2:-}"; shift 2 ;;
    --wiki-mode)   WIKI_MODE="${2:-}"; shift 2 ;;
    --methodology) METHODOLOGY="${2:-}"; shift 2 ;;
    --template)    TEMPLATE="${2:-}"; shift 2 ;;
    --no-git)      NO_GIT=true; shift ;;
    -h|--help)     usage; exit 0 ;;
    *) die "unknown flag: $1" ;;
  esac
done

[ -n "$NAME" ]        || die "--name is required"
[ -n "$DEST" ]        || die "--dest is required"
[ -n "$PURPOSE" ]     || die "--purpose is required"
[ -n "$WIKI_MODE" ]   || die "--wiki-mode is required"
[ -n "$METHODOLOGY" ] || die "--methodology is required"

case "$WIKI_MODE" in
  C|c) WIKI_MODE="C" ;;
  D|d) WIKI_MODE="D" ;;
  E|e) WIKI_MODE="E" ;;
  *) die "--wiki-mode must be C, D, or E" ;;
esac

case "$METHODOLOGY" in
  generic|lyt|para|zettelkasten) ;;
  *) die "--methodology must be generic, lyt, para, or zettelkasten" ;;
esac

DEST="${DEST/#\~/$HOME}"
mkdir -p "$(dirname "$DEST")"
DEST="$(cd "$(dirname "$DEST")" && pwd)/$(basename "$DEST")"
TEMPLATE="$(cd "$TEMPLATE" && pwd)"

if [ -e "$DEST" ]; then
  echo "ERR: destination already exists: $DEST" >&2
  exit 3
fi

TODAY="$(date +%Y-%m-%d)"
NOW_ISO="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

echo "Spawning vault: $NAME"
echo "  Destination:  $DEST"
echo "  Template:     $TEMPLATE"
echo "  Wiki mode:    $WIKI_MODE"
echo "  Methodology:  $METHODOLOGY"
echo ""

# ── Directories ─────────────────────────────────────────────────────────────
mkdir -p "$DEST"/{.raw,.vault-meta/locks,_templates,_attachments,.cursor/rules,wiki}
touch "$DEST/.vault-meta/locks/.gitkeep"

# Instance vaults keep sources and runtime caches local; wiki/ is what compounds in git.
cat > "$DEST/.gitignore" << 'EOF'
# Instance vault gitignore (private domain vault)
# Sources stay local; wiki/ is the committed knowledge base.

# Sources (immutable locally; do not publish)
.raw/

# Generated / large media
_attachments/
.trash/
.tmp*/

# Obsidian local state
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.obsidian/workspace-visual.json
.obsidian/plugins/*/data.json
Untitled*.canvas

# Vault runtime (Compound Vault / DragonScale)
.vault-meta/locks/*
!.vault-meta/locks/.gitkeep
.vault-meta/*.lock
.vault-meta/.wiki-lock.meta
.vault-meta/transport.json
.vault-meta/transport.*.tmp
.vault-meta/chunks/
.vault-meta/bm25/
.vault-meta/embed-cache.json
.vault-meta/embed-cache.*.tmp
.vault-meta/tiling-cache.json
.vault-meta/tiling-cache.*.tmp
.vault-meta/hook.log

# Large media if dropped in the vault
*.mp4
*.mov
*.mkv
*.avi

# System / tooling
.DS_Store
Thumbs.db
__pycache__/
*.pyc
.venv/
node_modules/
.env
.env.local
*.pem
*.key
credentials*
secrets.y*ml
auth.json
EOF

# Wiki mode subfolders
case "$WIKI_MODE" in
  C)
    WIKI_SUBDIRS=(stakeholders decisions deliverables intel comms)
    STARTER_PAGE="Project Overview"
    STARTER_TYPE="overview"
  ;;
  D)
    WIKI_SUBDIRS=(goals learning people areas resources)
    STARTER_PAGE="North Star"
    STARTER_TYPE="goal"
  ;;
  E)
    WIKI_SUBDIRS=(papers concepts entities thesis gaps)
    STARTER_PAGE="Research Overview"
    STARTER_TYPE="thesis"
  ;;
esac

for d in "${WIKI_SUBDIRS[@]}"; do
  mkdir -p "$DEST/wiki/$d"
  TITLE="$(echo "$d" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')"
  cat > "$DEST/wiki/$d/_index.md" << EOF
---
type: meta
title: "${TITLE} Index"
updated: ${TODAY}
tags: [meta, index, ${d}]
status: evergreen
---

# ${TITLE}

Index for \`wiki/${d}/\` pages.
EOF
done

# ── Manifest ──────────────────────────────────────────────────────────────────
cat > "$DEST/.raw/.manifest.json" << 'EOF'
{
  "version": 1,
  "created": "TODAY_PLACEHOLDER",
  "description": "Ingest delta tracker. Do not hand-edit; wiki-ingest maintains this.",
  "sources": {},
  "address_map": {}
}
EOF
sed -i '' "s/TODAY_PLACEHOLDER/${TODAY}/" "$DEST/.raw/.manifest.json" 2>/dev/null \
  || sed -i "s/TODAY_PLACEHOLDER/${TODAY}/" "$DEST/.raw/.manifest.json"

cat > "$DEST/.vault-meta/instance.json" << EOF
{
  "schema_version": 1,
  "name": "${NAME}",
  "template": "${TEMPLATE}",
  "purpose": "${PURPOSE}",
  "wiki_mode": "${WIKI_MODE}",
  "methodology": "${METHODOLOGY}",
  "created": "${TODAY}"
}
EOF

# ── Symlinks to template ─────────────────────────────────────────────────────
ln -s "$TEMPLATE/skills" "$DEST/skills"
ln -s "$TEMPLATE/bin" "$DEST/bin"
ln -s "$TEMPLATE/scripts" "$DEST/scripts"
mkdir -p "$DEST/.cursor"
ln -s "$TEMPLATE/skills" "$DEST/.cursor/skills"

# ── Wiki core pages ───────────────────────────────────────────────────────────
cat > "$DEST/wiki/index.md" << EOF
---
type: meta
title: "Wiki Index"
updated: ${TODAY}
tags: [meta, index]
status: evergreen
related:
  - "[[overview]]"
  - "[[hot]]"
  - "[[getting-started]]"
  - "[[${STARTER_PAGE}]]"
---

# Wiki Index

**${NAME}** — ${PURPOSE}

Navigation: [[overview]] | [[hot]] | [[getting-started]] | [[${STARTER_PAGE}]]

---

## Starter

- [[${STARTER_PAGE}]] — anchor page for this vault

## Domains

$(for d in "${WIKI_SUBDIRS[@]}"; do echo "- wiki/${d}/"; done)
EOF

cat > "$DEST/wiki/hot.md" << EOF
---
type: meta
title: "Hot Cache"
updated: ${NOW_ISO}
tags: [meta, hot-cache]
status: evergreen
related:
  - "[[index]]"
  - "[[${STARTER_PAGE}]]"
---

# Recent Context

Navigation: [[index]] | [[getting-started]]

## Last Updated

${TODAY}: Vault spawned from Quibble-Vault template. Ready for first ingest.

## Vault

- **Name**: ${NAME}
- **Purpose**: ${PURPOSE}
- **Wiki mode**: ${WIKI_MODE}
- **Methodology**: ${METHODOLOGY}

## Active Threads

- Add your first source to \`.raw/\` and run \`ingest [filename]\`
- Review [[${STARTER_PAGE}]] and customize it

## Next Step

See [[getting-started]] for daily workflows.
EOF

cat > "$DEST/wiki/log.md" << EOF
---
type: meta
title: "Wiki Log"
updated: ${TODAY}
tags: [meta, log]
status: evergreen
---

# Wiki Log

## ${TODAY} — Vault spawned

- **Operation**: spawn
- **Template**: ${TEMPLATE}
- **Created**: [[${STARTER_PAGE}]], [[index]], [[hot]], [[overview]], [[getting-started]]
EOF

cat > "$DEST/wiki/overview.md" << EOF
---
type: meta
title: "Overview"
updated: ${TODAY}
tags: [meta, overview]
status: evergreen
related:
  - "[[index]]"
  - "[[${STARTER_PAGE}]]"
---

# ${NAME} Overview

${PURPOSE}

Wiki mode **${WIKI_MODE}** with **${METHODOLOGY}** filing methodology.

Start at [[${STARTER_PAGE}]] or [[getting-started]].
EOF

# Starter anchor page
STARTER_DIR="wiki"
case "$WIKI_MODE" in
  C) STARTER_DIR="wiki/deliverables" ;;
  D) STARTER_DIR="wiki/goals" ;;
  E) STARTER_DIR="wiki/thesis" ;;
esac

cat > "$DEST/${STARTER_DIR}/${STARTER_PAGE}.md" << EOF
---
type: ${STARTER_TYPE}
title: "${STARTER_PAGE}"
status: active
created: ${TODAY}
updated: ${TODAY}
tags: [starter]
related:
  - "[[index]]"
  - "[[getting-started]]"
---

# ${STARTER_PAGE}

Customize this page as the anchor for **${NAME}**.

## Purpose

${PURPOSE}

## Current focus

- (add your priorities here)

## Open questions

- (what are you trying to learn or accomplish?)
EOF

cat > "$DEST/wiki/getting-started.md" << 'GETTINGEOF'
---
type: meta
title: "Getting Started"
updated: TODAY_PLACEHOLDER
tags: [meta, onboarding]
status: evergreen
related:
  - "[[index]]"
  - "[[overview]]"
---

# Getting Started

## Daily workflow

| You say | Agent does |
|---------|------------|
| `ingest [file]` | Creates 8–15 wiki pages from `.raw/` source |
| `what do you know about X?` | Queries wiki with citations |
| `/save` | Files conversation as wiki note |
| `lint the wiki` | Health check (every 10–15 ingests) |

## Capture

1. Drop a source into `.raw/` (PDF, markdown, transcript, article)
2. Say: `ingest [filename]`
3. Check `wiki/index.md` and Obsidian graph view

## Query

- `query quick: [question]` — hot cache only
- `what do you know about [topic]?` — index + relevant pages
- `query deep: [question]` — full drill-down

## Save sessions

End significant sessions with `/save` or `file this conversation`.

## Cross-vault

This vault is one of several. The template registry lives at:
`/Users/gwynforhockridge/Documents/Quibble-Vault/.vault-meta/vault-registry.json`

Template guide: `docs/vault-template-guide.md` in Quibble-Vault.
GETTINGEOF
sed -i '' "s/TODAY_PLACEHOLDER/${TODAY}/" "$DEST/wiki/getting-started.md" 2>/dev/null \
  || sed -i "s/TODAY_PLACEHOLDER/${TODAY}/" "$DEST/wiki/getting-started.md"

# ── CLAUDE.md ─────────────────────────────────────────────────────────────────
WIKI_TREE=""
for d in "${WIKI_SUBDIRS[@]}"; do
  WIKI_TREE="${WIKI_TREE}│   ├── ${d}/"$'\n'
done
WIKI_TREE="${WIKI_TREE}│   └── (domain folders)"

cat > "$DEST/CLAUDE.md" << EOF
# ${NAME}: LLM Wiki

Mode: ${WIKI_MODE}
Purpose: ${PURPOSE}
Template: ${TEMPLATE}
Created: ${TODAY}

## Structure

\`\`\`
vault/
├── .raw/       # immutable source documents
├── wiki/       # LLM-generated knowledge base
${WIKI_TREE}
└── CLAUDE.md   # this file
\`\`\`

Methodology: **${METHODOLOGY}** (see \`bash bin/setup-mode.sh --check\`)

## Conventions

- All notes use YAML frontmatter: type, status, created, updated, tags (minimum)
- Wikilinks use [[Note Name]] format
- \`.raw/\` contains source documents: never modify them
- \`wiki/index.md\` is the master catalog: update on every ingest
- \`wiki/log.md\` is append-only: never edit past entries
- New log entries go at the TOP of the file

## Operations

- Ingest: drop source in \`.raw/\`, say "ingest [filename]"
- Query: ask any question; agent reads hot cache and index first
- Lint: say "lint the wiki" for health check
- Save: \`/save\` to file conversations

## Cross-Project Access

Add to other projects' rules:

\`\`\`markdown
## Wiki Knowledge Base
Path: ${DEST}

1. Read wiki/hot.md first
2. Then wiki/index.md
3. Then relevant wiki pages
\`\`\`
EOF

# ── AGENTS.md (slim) ──────────────────────────────────────────────────────────
cat > "$DEST/AGENTS.md" << EOF
# ${NAME} — Vault Instance

Instance vault spawned from [Quibble-Vault](${TEMPLATE}).

- **Purpose**: ${PURPOSE}
- **Skills**: symlinked to \`${TEMPLATE}/skills\`
- **Registry**: \`${TEMPLATE}/.vault-meta/vault-registry.json\`

Read \`wiki/hot.md\` at session start. Follow skills for ingest, query, lint, save.
Never modify \`.raw/\`.
EOF

# ── Cursor instance rule ──────────────────────────────────────────────────────
cat > "$DEST/.cursor/rules/vault-instance.mdc" << EOF
---
description: "${NAME} vault instance — routing, conventions, path"
alwaysApply: true
---

# Vault: ${NAME}

Path: ${DEST}
Template: ${TEMPLATE}
Purpose: ${PURPOSE}
Methodology: ${METHODOLOGY}
Wiki mode: ${WIKI_MODE}

## Session start

1. Read wiki/hot.md
2. Read wiki/index.md if query needs more context

## Operations

- ingest, query, lint, save — follow skills in linked template
- Never modify .raw/
- Run commands from this vault directory so WIKI_VAULT_ROOT resolves correctly
EOF

# ── Obsidian setup ────────────────────────────────────────────────────────────
export WIKI_VAULT_ROOT="$DEST"
bash "$TEMPLATE/bin/setup-vault.sh" "$DEST"

# ── Methodology mode ──────────────────────────────────────────────────────────
bash "$TEMPLATE/bin/setup-mode.sh" \
  --mode "$METHODOLOGY" \
  --dest "$DEST" \
  --seed

# ── Transport ─────────────────────────────────────────────────────────────────
bash "$TEMPLATE/scripts/detect-transport.sh" --dest "$DEST" --quiet

# ── Git init ──────────────────────────────────────────────────────────────────
if ! $NO_GIT; then
  (cd "$DEST" && git init -q && git add -A && git commit -q -m "Initial vault spawn: ${NAME}" || true)
fi

# ── Update registry ───────────────────────────────────────────────────────────
REGISTRY="$TEMPLATE/.vault-meta/vault-registry.json"
python3 << PYEOF
import json
from pathlib import Path
from datetime import date

registry_path = Path("${REGISTRY}")
data = json.loads(registry_path.read_text(encoding="utf-8"))
entry = {
    "name": "${NAME}",
    "path": "${DEST}",
    "purpose": "${PURPOSE}",
    "wiki_mode": "${WIKI_MODE}",
    "methodology": "${METHODOLOGY}",
    "created": "${TODAY}",
}
vaults = data.get("vaults", [])
vaults = [v for v in vaults if v.get("path") != "${DEST}" and v.get("name") != "${NAME}"]
vaults.append(entry)
data["vaults"] = vaults
data["updated"] = str(date.today())
registry_path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
print(f"Updated registry: {registry_path}")
PYEOF

echo ""
echo "✓ Vault spawned: $DEST"
echo ""
echo "Next steps:"
echo "  1. Open in Obsidian: Manage Vaults → Open folder → $DEST"
echo "  2. Open in Cursor: File → Open Folder → $DEST"
echo "  3. Drop a source in .raw/ and say: ingest [filename]"
echo "  4. Customize [[${STARTER_PAGE}]]"

---
name: session-learn
description: >
  Meta-skill that analyzes past session transcripts to derive new skills,
  CLAUDE.md rules, and MEMORY.md entries from real usage patterns. Use when
  Use when user says "session learn", "derive skills", "learn from sessions",
  "what patterns", "analyze sessions", "extract rules", "what should I add
  to claude md", "improve my setup", or "what have I been doing repeatedly".
---

# Session Learn

Analyzes past session transcripts and extracts actionable improvements:
recurring workflows that should become skills, corrections that should become
CLAUDE.md rules, persistent facts for MEMORY.md, and gaps in existing skills.

## Phase 1: Gather Data

Run these in parallel:

```bash
# List recent sessions
session-recall --list 20

# Cross-session error/correction/retry analysis
session-recall --all 10 --report

# Correction and constraint patterns
session-recall --all 10 "correction|wrong|mistake|don't|never|always|stop"

# Repeated workflow patterns
session-recall --all 10 "deploy|send|check|create|build|update|push"
```

Also invoke MCP tools if available (they give richer structured output):
- `recall_report` - error/retry/correction analysis with stats
- `recall_decisions` - key decisions across sessions
- `recall_search` with keywords for targeted pattern search

## Phase 2: Classify Each Finding

For each finding, assign exactly one category:

| Category | Threshold | Target |
|----------|-----------|--------|
| **Skill candidate** | 3+ occurrences across sessions | New `~/.claude/skills/<name>/SKILL.md` |
| **CLAUDE.md rule** | 2+ occurrences, global constraint or correction | Append to `~/.claude/CLAUDE.md` |
| **MEMORY.md entry** | Any count, persistent fact or preference | Append to `~/.claude/projects/-root/memory/MEMORY.md` or topic file |
| **Existing skill update** | Any count, gap in current coverage | Edit existing `~/.claude/skills/<name>/SKILL.md` |

Cross-reference against existing skills before proposing new ones:

```bash
ls ~/.claude/skills/
```

Read the description field of potentially overlapping skills to check for
duplication before proposing a new skill.

## Phase 3: Present Findings

Format the report as a table per category. Do NOT apply anything yet.

```markdown
## Session Learning Report

### New Skill Candidates
| Workflow | Sessions seen | Current coverage gap | Proposed skill name |
|----------|--------------|----------------------|---------------------|
| ...      | ...          | ...                  | ...                 |

### New CLAUDE.md Rules
| Pattern observed | Evidence (sessions/count) | Proposed rule text |
|-----------------|--------------------------|-------------------|
| ...             | ...                       | ...               |

### MEMORY.md Updates
| Topic | Current state | Proposed addition |
|-------|--------------|-------------------|
| ...   | ...          | ...               |

### Existing Skill Improvements
| Skill | Gap found | Proposed change |
|-------|-----------|----------------|
| ...   | ...       | ...            |
```

Always state the evidence count. "Seen in 4 sessions" is valid.
"Seen once" is not sufficient for a CLAUDE.md rule (need 2+).

## Phase 4: Apply (after explicit approval)

Wait for explicit user approval. Apply only the approved items.

### Creating a new skill

```bash
mkdir -p ~/.claude/skills/<name>
# Write SKILL.md with YAML frontmatter (name + description) and body
```

Use imperative form in the body. Description must include trigger phrases.
Keep body under 500 lines. Move reference material to `references/` files.

### Appending to CLAUDE.md

Read the file first, then append at the bottom of the most relevant section.
NEVER cut or condense existing content. Only append or reorder.

```bash
# Read first, then edit with Edit tool - never overwrite
```

### Updating MEMORY.md

Check if a topic file already exists before adding to MEMORY.md directly.
Topic files live at `~/.claude/projects/-root/memory/<topic>.md`.
If MEMORY.md exceeds 200 lines, add to a topic file and reference it.

### Sync to moto repo (if applicable)

```bash
# Check if the skill directory is tracked by a setup repo
ls ~/moto/ 2>/dev/null || ls ~/claude-setup/ 2>/dev/null || ls ~/.claude-setup/ 2>/dev/null
# If it exists, copy new skill files there and commit
```

## Rules

- Present findings before applying. Never auto-apply.
- Require 3+ occurrences for new skill, 2+ for CLAUDE.md rule.
- Never cut existing CLAUDE.md content.
- Prioritize by severity: safety/correctness errors > workflow inefficiency > convenience.
- Cross-reference against all existing skills before proposing duplicates.
- Keep proposed rule text concise and imperative (mirrors CLAUDE.md style).

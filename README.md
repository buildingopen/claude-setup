# moto 🛵

### A terminal IDE for AI agents, extracted from 500+ real sessions

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude_Code-compatible-blueviolet)](https://docs.anthropic.com/en/docs/claude-code)

`moto` is a hacked-together but production-tested terminal IDE for AI agents: Claude as the control plane, Codex for backend/infra/debugging, opencode as an optional worker, subagent workflows, Docker-first runtime, CLAUDE.md / AGENTS.md-style context, safety hooks, 60+ skills, Gmail/WhatsApp integrations, memory, browser automation, and cost tracking.

This repo was formerly `buildingopen/claude-setup`. The old GitHub URL is kept for backwards compatibility through GitHub redirects after the rename.

---

## Who is this for?

- **Founders/operators** turning repeated work into software with agents
- **Claude Code / Codex users** who want a real operating environment instead of one-off prompts
- **Terminal-first builders** running multiple agents on a Mac + remote Linux box
- **Teams** standardizing agent rules, hooks, skills, memory, and remote runtime
- **Anyone burned** by agents running destructive commands, leaking secrets, or claiming success without fresh evidence

## What makes this different?

Most AI coding setups are a prompt file plus a pile of tools. `moto` is the full operating environment: context, hooks, skills, memory, terminal sessions, remote server runtime, browser automation, Docker sandboxes, and launcher commands for Claude, Codex, and opencode.

The philosophy is simple:

- context before prompting
- wireframes before UI code
- Docker before SaaS integrations
- subagents before monolithic chats
- cheap models for mechanical checks
- expensive models for judgment
- complexity only after real usage earns it

---

## Table of Contents

- [Quick Start](#quick-start)
- [Repo Boundary](#repo-boundary)
- [What's Included](#whats-included)
- [Mac iTerm Workflow](#mac-iterm-workflow)
- [CLAUDE.md Templates](#claudemd-templates)
- [Safety Hooks](#safety-hooks)
- [Skills (40+)](#skills-40)
- [Memory System](#memory-system)
- [Server Infrastructure](#server-infrastructure)
- [WhatsApp & Gmail Integration](#whatsapp--gmail-integration)
- [Architecture](#architecture)
- [Requirements](#requirements)
- [Configuration](#configuration)
- [Related Projects](#related-projects)

---

## Quick Start

```bash
git clone https://github.com/buildingopen/moto.git
cd moto
./install.sh          # Symlinks configs into ~/.claude/
```

That's it. The installer detects existing configs, backs them up, resolves `$HOME` paths in hook commands, and installs 17 hooks + 7 scripts + 60+ skills + memory template. Run `./install.sh --copy` for standalone files instead of symlinks.

For the full remote workstation from the same repo:

```bash
cp .env.example .env
$EDITOR .env
./install.sh mac
./install.sh server-remote
```

**After install:**
1. Edit `~/.claude/CLAUDE.md` to match your workflow (search for `<!-- Customize -->` comments)
2. Copy `claude/CLAUDE-project.md` into your project roots
3. Optionally copy `.env.example` to `.env` for API keys used by some hooks/scripts

---

## Repo Boundary

`moto` is the canonical home for your AI-agent operating environment. Install this repo locally and treat the resulting `~/.claude` as the source of truth for:

- `CLAUDE.md`, `settings.json`, and `.mcp.json`
- Hooks, scripts, skills, and memory templates
- The integrated Mac and server runtime in [`mac/`](mac/), [`server/`](server/), [`cron/`](cron/), [`whatsapp/`](whatsapp/), and [`gmail/`](gmail/)

It also includes the full `moto` command surface:

- Mac-side iTerm tab/session orchestration
- Reverse SSH tunnel + SSHFS wiring
- Opinionated remote server bootstrap and recovery
- `moto up`, `moto new`, `moto doctor`, and the full remote workflow
- `moto newx` for Codex sessions and `moto newo` for opencode sessions

Use `./install.sh` for local-only setups. Add `./install.sh mac` plus `./install.sh server-remote` when you want the full remote workstation from the same repo.

---

## What's Included

| Directory | Contents | Purpose |
|-----------|----------|---------|
| [`claude/`](claude/) | CLAUDE.md, hooks, scripts, skills, memory | Core Claude Code configuration |
| [`mac/`](mac/) | `moto` CLI, iTerm automation, shell aliases, launchd + SSH templates | Mac-side control plane for the integrated remote workflow |
| [`server/`](server/) | Systemd services, Docker stack, safety utils, browser automation, tmux | Linux-side runtime for the integrated remote workflow |
| [`whatsapp/`](whatsapp/) | OpenClaw gateway, verified send, SQLite contact lookup | WhatsApp messaging integration |
| [`gmail/`](gmail/) | IMAP checker, multi-account support | Email access for Claude |
| [`cron/`](cron/) | Job templates, health checks, safe-pipeline patterns | Recurring task automation |

---

## CLAUDE.md Templates

Two templates encoding months of iteration on making Claude Code reliable:

- **[`claude/CLAUDE.md`](claude/CLAUDE.md)** - Global config (`~/.claude/CLAUDE.md`). Drop-in template with engineering principles, self-audit checklist, error recovery, communication standards, and quality gates.
- **[`claude/CLAUDE-project.md`](claude/CLAUDE-project.md)** - Per-project config. Tech stack, key files, testing conventions, deploy config. Copy into any project root.

<details>
<summary><strong>Key patterns in the global CLAUDE.md</strong></summary>

| Pattern | What it does |
|---------|-------------|
| **Read First, Code Later** | 80% reading, 20% writing. No changes without understanding context first. |
| **Self-Audit** | No completion claims without fresh verification evidence. Bans unverified success claims. |
| **Rationalization Red Flags** | Table of thoughts that signal the agent is about to skip process. |
| **Error Recovery** | Data-driven rules from 10,000+ error analysis (e.g., never retry a blocked hook). |
| **Ripple Check** | After every change, audit the diff for env vars, dependencies, breaking changes. |
| **Quality Gate** | Do not return until genuinely 10/10. List flaws before scoring. |

</details>

---

## Safety Hooks

17 hooks wired into `settings.json` that prevent Claude from doing damage. They run automatically on every tool call.

| Hook | Trigger | What It Does |
|------|---------|-------------|
| `block-destructive.sh` | Bash | Blocks `rm -rf /`, `git reset --hard`, `DROP TABLE`, `curl\|bash` |
| `protect-sensitive-files.sh` | Write/Edit | Blocks writes to `.pem`, `.key`, `id_rsa`, credentials |
| `protect-config-files.sh` | Write/Edit | Blocks editing linter/formatter configs to bypass checks |
| `scan-secrets-before-push.sh` | Bash | Runs gitleaks before `git push` |
| `enforce-package-manager.sh` | Bash | Detects lock file, blocks wrong package manager |
| `enforce-server-routing.sh` | Bash | Blocks CPU-heavy tasks locally, routes to dev server |
| `suggest-compact.sh` | Edit/Write/Bash | Counts tool calls, suggests `/compact` at threshold |
| `post-compaction-recall.sh` | Any | Detects post-compaction state, suggests session-recall |
| `cost-tracker.sh` | Stop | Tracks token costs per model/session to `costs.jsonl` |
| `gemini-audit.sh` + `.py` | Stop | Opt-in Gemini quality gate: scores output, blocks if < 10 |
| `block-wa-send.sh` | Bash | Blocks unverified WhatsApp sends (optional, not wired by default) |
| `block-terminal-minimize.sh` | Bash | Blocks AppleScript commands that minimize or hide terminal windows |
| `cc-precompact-hook.sh` | PreCompact | Saves git diff, test results, and loop state before context compaction |
| `cc-postcompact-hook.sh` | PostCompact | Restores saved state into context after compaction |
| `enforce-hetzner-heavy-tasks.sh` | Bash | Blocks CPU-heavy tasks locally (Remotion, ffmpeg, Playwright), routes to dev server |
| `rate-limit-auto-resume.sh` | Stop | Detects rate limit messages and schedules automatic resume via macOS `at` |
| `sandbox-heavy-tasks.sh` | PreToolUse | Intercepts memory-hungry commands (whisper, ffmpeg, torch) and routes through sandbox |

All hooks are pure bash (no external deps beyond `jq`). See [`claude/hooks/README.md`](claude/hooks/README.md) for how hooks work, the JSON protocol, and how to wire them in `settings.json`.

![Hook blocking a destructive command](assets/hook-demo.gif)

**Scripts included:**

| Script | Purpose |
|--------|---------|
| `gemini-fetch.sh` | Fetch blocked URLs via Gemini API (WebFetch fallback) |
| `claude-auto-resume.sh` | Auto-retry on rate limits with exponential backoff |
| `claude-rate-limit-watcher.sh` | Background rate limit monitor daemon |
| `claude-switch.sh` | Switch between multiple Claude accounts |
| `sync-claude-config.sh` | Sync CLAUDE.md across machines via SCP |

---

## Skills (60+)

Slash commands that extend Claude's capabilities. Each skill is a `SKILL.md` file installed to `~/.claude/commands/`. Invoke with `/skill-name` or let Claude detect and use them automatically. Includes `session-learn`, a meta-skill that analyzes past session transcripts to derive new skills and CLAUDE.md rules from real usage patterns.

<details>
<summary><strong>Full skill list by category</strong></summary>

**Shipping & QA:**
`bouncer` (Gemini quality gate), `ship` (pre-merge workflow), `qa` (autonomous testing), `debug` (systematic debugging), `target-loop` (verified iteration engine), `gh-launch` (repo launch checklist)

**Planning & Review:**
`retro` (weekly retrospective), `compass` (strategic planning), `blast-radius` (impact analysis), `deep-audit` (full repo audit via Gemini), `cost` (token spend reporting), `negotiator` (BATNA/ZOPA analysis, message scoring), `product` (UX decision framework)

**Auditing:**
`ui-audit` (UX/product review + wireframe comparison with Playwright screenshots and CSS extraction), `ux-audit` (independent Gemini-powered UX scoring), `seo` (technical SEO 8-dimension audit), `geo` (geographic data validator for aviation/travel)

**Document Generation:**
`pdf`, `docx`, `pptx`, `xlsx` manipulation, `yc-pitch-deck` (investor pitch deck)

**Design & Content:**
`frontend-design`, `slide-design`, `canvas-design`, `algorithmic-art`, `linkedin-copy`, `cold-outreach`, `brand-guidelines` (Anthropic brand), `republic-design` (investor-grade design scoring), `theme-factory` (10 pre-set visual themes), `web-artifacts-builder` (React + shadcn/ui artifacts), `internal-comms` (company newsletters, 3P updates)

**Video & Media:**
`video-edit` (trim, concat, overlays, audio mix, voiceover), `review-video` (frame extraction + visual review), `yc-video` (plan/score/audit startup launch videos), `slack-gif-creator` (animated GIFs optimized for Slack)

**Infrastructure & Ops:**
`deploy` (multi-project), `docker-deploy` (self-hosted), `dns` (DNS API), `health` (system audit), `email-check` (IMAP), `wa` (WhatsApp read/send), `mcp-builder`, `webapp-testing`, `browse` (browser automation), `browser-use` (persistent browser daemon), `post-to-x` (cross-post to X/Twitter)

**Context & Recovery:**
`vault` (context vault ops), `morning` (daily briefing), `recall` (post-compaction recovery), `session-learn` (derive skills from sessions), `issue` (multi-account GitHub issues), `agents` (scan running Claude sessions), `food-finder` (restaurant discovery via Swiggy + Maps)

**Meta:**
`skill-creator` (create new skills), `subagent-templates`, `new-project` (scaffolding), `doc-coauthoring`, `workplan` (multi-step task planning)

</details>

See [`claude/skills/README.md`](claude/skills/README.md) for the full list, SKILL.md format, and how to create your own.

---

## Memory System

An external brain pattern that persists knowledge across Claude Code sessions:

- **`MEMORY.md`** - Concise index (< 200 lines) auto-loaded into every conversation
- **Topic files** - Detailed notes on specific subjects, read on demand
- Claude auto-updates these as it learns preferences, patterns, and corrections

This prevents Claude from repeating mistakes across sessions and lets it build on prior context. See [`claude/memory/README.md`](claude/memory/README.md) for the full pattern.

---

## Server Infrastructure

Templates for running Claude Code on a dedicated dev server (VPS/dedicated). Not needed for local-only setups.

> 🛵 **Remote stack:** the recommended path is `./install.sh mac` and `./install.sh server-remote`, which syncs the server runtime to `/opt/moto` by default for compatibility with the bundled helpers and systemd units.

<details>
<summary><strong>What's in server/</strong></summary>

- **Systemd services** - Chrome headless with CDP, SSHFS mounts, CDP keepalive, Docker-host proxy
- **Safety utilities** - `safe-pipeline` (flock + timeout + cgroup memory cap), `safe-run`, stale process cleanup
- **Browser automation** - Chrome CDP setup guide, bridge keeper for session persistence
- **Multi-account management** - GitHub, Render, Supabase account switching patterns
- **Terminal workflow** - tmux config, bashrc (999K history, aliases), background task queue system

</details>

---

## Mac iTerm Workflow

`moto` ships the full AX41-style tab workflow directly:

- [`mac/bin/moto`](mac/bin/moto) is the primary Mac CLI for opening, restoring, diagnosing, and managing remote sessions
- [`mac/bin/claude-tabs`](mac/bin/claude-tabs) remains as a compatibility wrapper for the older tab-only command surface
- [`mac/install.sh`](mac/install.sh) installs the Mac helper, aliases, SSH config, and reverse-tunnel launchd agent
- [`server/install.sh`](server/install.sh) installs the Linux-side runtime
- [`server/bin/cs`](server/bin/cs), [`server/bin/cx`](server/bin/cx), and [`server/bin/co`](server/bin/co) provide the tmux attach-or-create launchers on the server

Typical flow:

```bash
# once in the repo
cp .env.example .env
$EDITOR .env
./install.sh mac
./install.sh server-remote
source ~/.zshrc

# everyday usage
moto new myproj/feature
moto up
moto ls
```

See [`mac/README.md`](mac/README.md) for the full setup.

---

## WhatsApp & Gmail Integration

**WhatsApp** (via [OpenClaw](https://github.com/openclaw/openclaw) gateway):
- Docker-based WhatsApp Web bridge
- Verified send script with SQLite contact lookup (prevents wrong-number sends)
- Direct SQLite DB reading for message history

**Gmail** (via IMAP):
- Multi-account email checking
- Preserves read/unread status (`BODY.PEEK[]` instead of `RFC822`)
- Standalone Python script, stdlib only, no pip dependencies

---

## Architecture

```
~/.claude/
  CLAUDE.md          <- claude/CLAUDE.md (global config)
  settings.json      <- claude/settings.json (hooks + permissions, $HOME resolved)
  .mcp.json          <- claude/.mcp.json (MCP servers)
  hooks/             <- claude/hooks/ (12 safety hooks)
  scripts/           <- claude/scripts/ (5 utility scripts)
  commands/          <- claude/skills/ (40+ slash commands)
  metrics/           <- cost tracking output (costs.jsonl)
  projects/*/memory/ <- external brain (MEMORY.md + topic files)

your-project/
  CLAUDE.md          <- claude/CLAUDE-project.md (per-project config)
```

---

## Requirements

| Requirement | Required? | Used by |
|-------------|-----------|---------|
| [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) | Yes | Everything |
| `jq` | Yes | All hooks (JSON parsing) |
| `python3` | Optional | Gemini audit hook, email checker |
| `gitleaks` | Optional | Secret scanning hook |
| Gemini API key | Optional | `gemini-fetch.sh`, `gemini-audit` |

---

## Configuration

After running `install.sh`:

1. **Edit CLAUDE.md** - Search for `<!-- Customize -->` comments and replace placeholders with your setup (server names, tool routing rules, project paths)
2. **Add project configs** - Copy `claude/CLAUDE-project.md` to each project root and fill in the tech stack section
3. **API keys** (optional) - Copy `.env.example` to `.env` for hooks/scripts that need external APIs

The `settings.json` file has `$HOME` paths pre-resolved by the installer. If you update the repo's `settings.json`, re-run `./install.sh` to pick up changes.

For remote installs, the same `.env` drives the bundled remote workflow. `./install.sh server-remote` deploys the server runtime to `/opt/moto` by default so the helper scripts and systemd units resolve a stable runtime path.

---

## Related Projects

Other open-source tools from BuildingOpen:

| Project | Description |
|---------|-------------|
| **[bouncer](https://github.com/buildingopen/bouncer)** | Independent Gemini quality gate that audits Claude Code's output before it can stop |
| **[claude-code-stats](https://github.com/buildingopen/claude-code-stats)** | Spotify Wrapped for Claude Code. Visualize your AI coding stats, token usage, and costs |
| **[claude-wrapped](https://github.com/buildingopen/claude-wrapped)** | Visualize your Claude Code stats with `npx claude-entropy` |
| **[hook-stats](https://github.com/buildingopen/hook-stats)** | Analyze your Claude Code bash command log |
| **[session-recall](https://github.com/buildingopen/session-recall)** | Search and recover context after Claude's automatic compaction |
| **[browse](https://github.com/buildingopen/browse)** | Browser automation CLI with autonomous agent mode via CDP |
| **[openbrowser](https://github.com/buildingopen/openbrowser)** | Give AI your browser. Check email, track orders, download receipts. MCP server + CLI |
| **[openqueen](https://github.com/buildingopen/openqueen)** | Autonomous coding agent controlled by WhatsApp/Telegram. Gemini orchestrates Claude/Codex |
| **[openclaw-setup](https://github.com/buildingopen/openclaw-setup)** | WhatsApp gateway setup guide (subset of this repo's `whatsapp/` directory) |
| **[blast-radius](https://github.com/buildingopen/blast-radius)** | Find all files affected by your changes. One bash script, zero dependencies |
| **[dep-check](https://github.com/buildingopen/dep-check)** | Find dead imports in your project. One bash script |
| **[ai-error-analyzer](https://github.com/buildingopen/ai-error-analyzer)** | 6 rules to reduce wasted AI coding retries |

---

## License

[MIT](LICENSE)

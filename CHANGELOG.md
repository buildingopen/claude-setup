# Changelog

All notable changes to this project will be documented in this file.

## [0.0.2.0] - 2026-04-14

### Added

- `server/terminal/start-claude-sessions.sh`: boot script that auto-starts one tmux session per git repo in `/root` on server reboot. Each session cds into the repo and runs `happy claude` (swappable with `claude` if not using Happy). Install via `@reboot` cron. Idempotent — skips repos that already have a running session.
- `server/terminal/README.md`: documented Happy (mobile/web access to headless Claude Code sessions), the boot script, and installation steps for both.
- `server/README.md`: Quick Deploy steps 6 (auto-start on boot) and 7 (Happy mobile access).
- `mac/zshrc`: Mac-side shell template with `dev()` iTerm2 multi-tab function (opens one tab per server tmux session) and `devs` alias (list sessions without attaching).

## [0.0.1.0] - 2026-04-14

### Added

- `server/setup-claude-auth.sh`: one-command script that pushes Claude Code auth from a Mac to a headless Linux dev server. Extracts OAuth credentials from the macOS Keychain, copies them to the server as `~/.claude/.credentials.json`, removes any stale `ANTHROPIC_AUTH_TOKEN` from `~/.bashrc` (Claude Code reads the credentials file natively — that env var is for API keys only and causes 401 errors with OAuth), and marks onboarding complete in `~/.claude.json` so the theme picker never blocks startup. Replaces a painful multi-step manual process.
- `server/README.md`: Quick Deploy step 0 documenting the new auth setup flow for Max/Pro plan users, with an API key fallback note.

### Changed

- `claude/hooks/enforce-hetzner-heavy-tasks.sh`: added `dev` to the SSH alias allowlist and anchored the regex with a word boundary so `ssh developer` no longer matches.
- `CLAUDE.md`: added gstack skill routing rules (enables proactive skill dispatch in this repo).

### Security

- Credentials file written with `umask 0077` + `chmod 600` for defense-in-depth against world-readable exposure window.
- `mkdir -p` and credential write combined into a single SSH session to eliminate symlink TOCTOU.
- `sed` pattern scoped to `^export ANTHROPIC_AUTH_TOKEN=` to avoid clobbering unrelated `.bashrc` lines.
- `ConnectTimeout=10` added to all SSH calls to prevent hangs in automation contexts.
- `~/.claude.json` permissions set to `0o600` after write.
- Empty auth status response now caught explicitly with a clear error message.

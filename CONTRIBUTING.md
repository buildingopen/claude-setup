# Contributing

## Adding a New Hook

1. Create a `.sh` file in `hooks/`:
   ```bash
   #!/usr/bin/env bash
   set -euo pipefail
   # Read JSON context from stdin
   input=$(cat)
   # Your logic here
   exit 0  # allow
   # exit 2  # block
   ```
2. Make it executable: `chmod +x hooks/your-hook.sh`
3. Wire it into `.claude/settings.json` under the appropriate event (`PreToolUse`, `PostToolUse`, etc.):
   ```json
   {
     "hooks": {
       "PreToolUse": [
         { "matcher": "Bash", "hook": "/path/to/hooks/your-hook.sh" }
       ]
     }
   }
   ```
4. Document it in `hooks/README.md` with: purpose, trigger event, and block conditions.

## Adding a New Skill

1. Create a directory in `skills/your-skill-name/`.
2. Add a `SKILL.md` file inside it. This is the instruction file Claude reads when the skill is invoked.
3. Optionally add helper scripts the skill references.
4. Test by running `/your-skill-name` in a Claude Code session.
5. Document the skill's purpose and usage in `skills/README.md`.

## Reporting Issues

Use the GitHub issue templates:
- **Bug report**: Include Claude Code version, OS, component, reproduction steps.
- **Feature request**: Describe the feature, which component it affects, and the use case.

Search existing issues before opening a new one.

## Code Style

- All bash scripts start with `set -euo pipefail`.
- Hooks read JSON from stdin via `input=$(cat)` and parse with `jq`.
- Exit codes for hooks: `0` = allow, `2` = block. Any other exit code is treated as an error.
- Use `jq` for JSON parsing, not `grep`/`sed` on JSON.
- Keep scripts focused: one hook, one responsibility.
- Quote all variables: `"$var"`, not `$var`.

## Pull Requests

- One logical change per PR.
- Test your hook/skill locally before submitting.
- Include a brief description of what changed and why.

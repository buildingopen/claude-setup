---
name: gh-launch
description: >
  GitHub repo launch checklist and audit. Use when user says "launch", "go public",
  "publish repo", "audit repo for launch", "open source this", "make public",
  "launch checklist", or wants to prepare a private repo for public release.
  Also works for auditing already-public repos. Covers: secret scanning, README polish,
  SEO metadata, license, templates, visibility change, distribution, and post-launch verification.
---

# GitHub Repo Launch Checklist

8-phase workflow for launching a repo (private->public) or auditing an existing public repo.
Hard gate on secrets (Phase 1 blocks everything). Soft checks on everything else.

## Phase 0: Repo State Detection

```bash
# Visibility + basic stats
gh repo view --json visibility,stargazerCount,forkCount,description,repositoryTopics,url
```

- If `visibility: PUBLIC`: skip Phase 6 (Go Public), run all other audits
- If `visibility: PRIVATE`: full workflow including Phase 6
- Note the owner/repo for all subsequent commands

## Phase 1: Security Audit (HARD GATE)

**If ANY secrets found: STOP. List them. Do not proceed to Phase 2.**

### Source code scan

```bash
# Common secret patterns
grep -rn --include="*.{js,ts,py,sh,md,json,yml,yaml,toml,env}" \
  -E "(AIza|sk_|ghp_|gho_|vcp_|sbp_|glpat-|xox[bps]-|AKIA|shpat_|phc_|re_[A-Za-z0-9])" . \
  | grep -v node_modules | grep -v .git | head -30

# Passwords and tokens in config
grep -rn --include="*.{js,ts,py,sh,json,yml,yaml,toml,env}" \
  -iE "(password|passwd|secret|token|api_key|apikey|private_key)\s*[:=]" . \
  | grep -v node_modules | grep -v .git | grep -v ".example" | head -20

# Private IPs, emails, phone numbers
grep -rn -E "(10\.\d+\.\d+\.\d+|192\.168\.\d+\.\d+|172\.(1[6-9]|2[0-9]|3[01])\.\d+\.\d+)" . \
  | grep -v node_modules | grep -v .git | head -10
```

### Git history scan (last 50 commits)

```bash
git log -50 --all -p | grep -iE "password|api_key|secret|token|private_key" | head -20
```

### Gitleaks (if available)

```bash
command -v gitleaks &>/dev/null && gitleaks detect --source . --no-banner
```

### .gitignore coverage

Verify `.gitignore` includes: `.env*`, `*.pem`, `*.key`, `credentials*`, `node_modules/`, `.DS_Store`, `*.sqlite`, `*.db`

If missing entries, add them before proceeding.

**HARD GATE: If secrets found, list each one with file:line and stop. User must remediate.**

## Phase 2: Repository Hygiene

```bash
# Repo size and file count
du -sh --exclude=.git . 2>/dev/null || du -sh .
find . -not -path './.git/*' -not -path './node_modules/*' | wc -l

# Bloat check: large files
find . -not -path './.git/*' -not -path './node_modules/*' -size +1M -exec ls -lh {} \;

# TODO/FIXME with internal context
grep -rn "TODO\|FIXME\|HACK\|XXX" --include="*.js" --include="*.ts" --include="*.py" \
  --include="*.sh" --include="*.md" . | grep -v node_modules | head -20

# Files that shouldn't be public
find . -not -path './.git/*' -iname "*draft*" -o -iname "*internal*" -o -iname "*personal*" \
  -o -iname "*workplan*" -o -iname "*notes*" 2>/dev/null | head -10
```

### .env.example completeness

```bash
# Find all env var references in code
grep -rn --include="*.{js,ts,jsx,tsx}" "process\.env\." . | grep -v node_modules | \
  sed 's/.*process\.env\.\([A-Z_]*\).*/\1/' | sort -u

# Compare against .env.example
test -f .env.example && cat .env.example | grep -v "^#" | grep "=" | cut -d= -f1 | sort -u
```

Report any env vars referenced in code but missing from `.env.example`.

## Phase 3: Documentation Audit

Read `references/readme-checklist.md` for the full README quality checklist.

### Quick checks

```bash
# README exists and has content
test -f README.md && wc -l README.md

# LICENSE exists
test -f LICENSE && head -5 LICENSE

# Broken links in README
grep -oP 'https?://[^\)\" >]+' README.md 2>/dev/null | while read url; do
  status=$(curl -sL -o /dev/null -w "%{http_code}" --max-time 5 "$url" 2>/dev/null)
  [ "$status" != "200" ] && echo "BROKEN ($status): $url"
done

# Broken image references
grep -oP '!\[.*?\]\((.*?)\)' README.md 2>/dev/null | grep -oP '\((.+?)\)' | tr -d '()' | while read img; do
  [[ "$img" == http* ]] && continue
  [ ! -f "$img" ] && echo "MISSING IMAGE: $img"
done
```

### Templates

```bash
# Issue templates
ls .github/ISSUE_TEMPLATE/ 2>/dev/null || echo "No issue templates"

# Contributing guide
test -f CONTRIBUTING.md && echo "CONTRIBUTING.md exists" || echo "No CONTRIBUTING.md"
```

Suggest creating issue templates (bug report + feature request) if missing.

## Phase 4: GitHub SEO & Metadata

### Landscape check

```bash
# See what competing repos use for description and topics
gh search repos "<relevant keywords>" --limit 5 --json name,description,repositoryTopics
```

### Set metadata

```bash
# Description (< 160 chars, keyword-rich)
gh repo edit --description "<description>"

# Homepage URL (if applicable)
gh repo edit --homepage "<url>"

# Topics (5-10, steal relevant ones from top repos)
gh repo edit --add-topic "<topic1>" --add-topic "<topic2>"
```

Topic strategy:
- Include: tool/framework name, primary language, domain keywords
- Add "open-source" as a topic
- Look at what top 5 competing repos use

### Social preview

```bash
# Check if custom OG image is set
gh api repos/{owner}/{repo} --jq '.open_graph_image_url // "No custom image"'
```

If no custom image: recommend creating a 1280x640 social preview. Upload via GitHub Settings > Social preview.

## Phase 5: CI & Install Verification

```bash
# Check for CI
ls .github/workflows/ 2>/dev/null || echo "No CI workflows"

# If package.json exists: test install
test -f package.json && (cd /tmp && rm -rf test-launch && git clone "$(gh repo view --json url -q .url)" test-launch && cd test-launch && npm install && echo "Install OK" || echo "Install FAILED")

# If requirements.txt: test install
test -f requirements.txt && pip install -r requirements.txt --dry-run 2>&1 | tail -5

# If install script exists: test it
test -f install.sh && (cd /tmp && rm -rf test-launch && git clone "$(gh repo view --json url -q .url)" test-launch && cd test-launch && bash install.sh && echo "Install OK" || echo "Install FAILED")

# Dependency audit
test -f package.json && npm audit 2>/dev/null | tail -10
```

## Phase 6: Go Public (skip if already public)

### Final secret scan (repeat Phase 1 one last time)

Run the same secret scan commands from Phase 1. If anything new appeared, STOP.

### Make public

```bash
gh repo edit --visibility public
```

### Enable features

```bash
# Enable Discussions (optional, suggest for community projects)
gh api repos/{owner}/{repo} -X PATCH -f has_discussions=true
```

### Create release

```bash
gh release create v1.0.0 --title "v1.0.0" --notes "$(cat <<'EOF'
## What's included
- [List key features from README]

## Quick start
```
[Install command from README]
```

## Requirements
[List from README]
EOF
)"
```

## Phase 7: Distribution & Discovery

Identify concrete targets:

1. **Awesome lists**: search GitHub for `awesome-<domain>` repos. Open a PR to add the repo.
2. **Communities**: identify 2-3 where the target audience is:
   - Reddit: r/programming, r/webdev, r/commandline, r/selfhosted, etc.
   - Hacker News: Show HN post
   - Discord servers for the framework/language
   - LinkedIn (if B2B/professional audience)
3. **Cross-reference**: if part of an org (e.g., BuildingOpen), add to other repos' "Related Projects" sections.

Draft announcement copy: what it does (1 sentence), why it exists (1 sentence), link.

## Phase 8: Post-Launch Verification

```bash
# Test clone from HTTPS
git clone "$(gh repo view --json url -q .url)" /tmp/test-clone && ls /tmp/test-clone && rm -rf /tmp/test-clone

# Verify metadata
gh repo view

# Check traffic (after 24-48h)
gh api repos/{owner}/{repo}/traffic/clones --jq '.clones[] | [.timestamp,.count] | @tsv'
gh api repos/{owner}/{repo}/traffic/views --jq '.views[] | [.timestamp,.count] | @tsv'

# Early engagement
gh issue list
gh api repos/{owner}/{repo} --jq '.stargazers_count'
```

Verify README renders correctly on GitHub (no broken images, formatting issues).
Test social preview by sharing the URL and checking OG image renders.

## Output Format

Present results as a checklist:

```
## Launch Audit: {repo-name}
Visibility: PUBLIC/PRIVATE | Stars: N | Forks: N

### Phase 1: Security [PASS/FAIL]
- [x] No secrets in source code
- [x] No secrets in git history
- [x] .gitignore covers sensitive files

### Phase 2: Hygiene [PASS/WARN]
- [x] No bloat files
- [ ] 3 TODOs found (non-blocking)

... (continue for all phases)
```

## Rules

- Phase 1 (Security) is a HARD GATE. If it fails, nothing else matters. Fix secrets first.
- All other phases are soft: report issues, suggest fixes, but don't block.
- For private->public: run Phase 6 only after Phases 1-5 pass.
- For already-public repos: skip Phase 6, run everything else as an audit.
- Never auto-publish or auto-make-public. Always confirm with user before `gh repo edit --visibility public`.
- Clean up /tmp/test-* directories after install verification.

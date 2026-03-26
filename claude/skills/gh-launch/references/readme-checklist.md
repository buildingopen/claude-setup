# README Quality Checklist

Score each item: PASS / FAIL / N/A. A launch-ready README needs all applicable items to PASS.

## Header (first 5 lines)

- [ ] **Title**: clear project name as H1
- [ ] **One-liner**: what it does in one sentence, immediately after title
- [ ] **Badges**: license, build status, version, or relevant shields.io badges
- [ ] **No generic "Welcome to X"** filler

## Problem & Value

- [ ] **What problem it solves**: stated in 1-2 sentences
- [ ] **Who it's for**: target audience is clear
- [ ] **Why this over alternatives**: differentiator stated (skip for unique tools)

## Quick Start

- [ ] **Install in 3 commands or fewer**: clone/install/run
- [ ] **Copy-pasteable commands**: no placeholders the user has to figure out
- [ ] **Works on first try**: tested fresh clone + install flow
- [ ] **Prerequisites listed**: Node version, OS, dependencies

## Usage

- [ ] **Code examples**: at least one real usage example with code block
- [ ] **Expected output**: show what the user will see
- [ ] **Common use cases**: 2-3 examples covering primary scenarios
- [ ] **CLI flags/options**: documented if CLI tool

## Structure (if > 100 lines)

- [ ] **Table of contents**: with anchor links
- [ ] **Logical section order**: install > usage > config > API > contributing > license
- [ ] **Collapsible sections**: use `<details>` for verbose content

## Technical Quality

- [ ] **No broken links**: all URLs return 200
- [ ] **No broken images**: all `![](path)` references exist
- [ ] **No stale information**: version numbers, URLs, feature lists are current
- [ ] **No typos or grammar errors** in first 3 paragraphs (first impression)

## Metadata

- [ ] **LICENSE file exists**: correct year, correct author/org
- [ ] **License section in README**: states license type with link
- [ ] **.env.example**: if project uses env vars, example file exists with all vars listed

## Community (if accepting contributions)

- [ ] **CONTRIBUTING.md**: how to contribute, code style, PR process
- [ ] **Issue templates**: bug report + feature request in `.github/ISSUE_TEMPLATE/`
- [ ] **Code of Conduct**: linked or included (for community projects)

## Visual Assets

- [ ] **Screenshot or demo GIF**: if visual tool, show it in action
- [ ] **Architecture diagram**: if complex system, show how pieces connect
- [ ] **Social preview image**: 1280x640 for GitHub OG card

## Anti-Patterns (FAIL if present)

- [ ] No "TODO" or "Coming soon" in published README
- [ ] No internal jargon, private URLs, or personal references
- [ ] No placeholder text ("Lorem ipsum", "Your Name Here")
- [ ] No auto-generated boilerplate left unedited (create-react-app README, etc.)
- [ ] No walls of text without formatting (use tables, bullets, code blocks)

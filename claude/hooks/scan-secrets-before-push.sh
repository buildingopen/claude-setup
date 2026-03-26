#!/bin/bash
# PreToolUse hook for Bash - scan for secrets before git push
# Blocks pushes if gitleaks detects secrets in commits being pushed.
# Requires: gitleaks (https://github.com/gitleaks/gitleaks)
# Install: brew install gitleaks / go install github.com/gitleaks/gitleaks/v8@latest
#
# Wire in ~/.claude/settings.json:
# {
#   "hooks": {
#     "PreToolUse": [{
#       "matcher": "Bash",
#       "hooks": [{
#         "type": "command",
#         "command": "/path/to/scan-secrets-before-push.sh",
#         "timeout": 30,
#         "statusMessage": "Scanning for secrets"
#       }]
#     }]
#   }
# }

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only run on git push commands
if ! echo "$COMMAND" | grep -qE "git push"; then
    echo '{"decision": "approve"}'
    exit 0
fi

# Check if gitleaks is available
if ! command -v gitleaks &>/dev/null; then
    echo '{"decision": "approve", "reason": "gitleaks not installed, skipping scan"}'
    exit 0
fi

# Scan commits reachable from HEAD (the full branch being pushed)
# Uses --log-opts="HEAD" to scan only reachable commits, not dangling objects
RESULT=$(gitleaks detect --source . --no-banner --log-opts="HEAD" 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "{\"decision\": \"block\", \"reason\": \"Secrets detected in commits being pushed. Run: gitleaks detect --source . --log-opts=HEAD\"}"
    exit 0
fi

echo '{"decision": "approve"}'
exit 0

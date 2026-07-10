#!/bin/bash
# PreToolUse Bash: kill the killer items (Gawande) — the git mistakes that
# are most dangerous and most tempting to skip past.
cd "${CLAUDE_PROJECT_DIR:-.}"
cmd=$(jq -r '.tool_input.command // empty')
[ -z "$cmd" ] && exit 0
sg() { grep "^$1=" .factory/state | cut -d= -f2-; }
[ "$(sg phase)" = "off" ] && exit 0
block() { echo "BLOCKED: $1" >&2; exit 2; }

echo "$cmd" | grep -q -- '--no-verify' && block "--no-verify is never allowed"

if echo "$cmd" | grep -qE '(^|[;&|][[:space:]]*)git[[:space:]]+commit'; then
  [ "$(git branch --show-current)" = "main" ] && \
    block "no commits on main — /refine-ticket creates the ticket branch"
  [ "$(sg suite)" = "red" ] && \
    block "suite is red — finish the TDD cycle (green) before committing"
fi

if echo "$cmd" | grep -qE '(^|[;&|][[:space:]]*)git[[:space:]]+push'; then
  [ "$(sg verdict)" = "PASS" ] || \
    block "push locked until review verdict=PASS — run /final-review"
fi
exit 0

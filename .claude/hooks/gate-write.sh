#!/bin/bash
# PreToolUse Write|Edit: source files are read-only unless phase is
# implementing (or the escape hatch is open). Artifacts, docs, and the
# factory's own config stay writable in every phase.
cd "${CLAUDE_PROJECT_DIR:-.}"
path=$(jq -r '.tool_input.file_path // empty')
[ -z "$path" ] && exit 0
case "$path" in
  */work/*|*/.factory/*|*/.claude/*|*.md) exit 0 ;;
esac
phase=$(grep '^phase=' .factory/state | cut -d= -f2)
case "$phase" in implementing|off) exit 0 ;; esac
echo "BLOCKED (phase=$phase): source files are writable only in 'implementing'. Route: idle→/refine-ticket, refined→/plan-ticket, planned→/tdd-implement, reviewing→/final-review. Escape hatch for trivial fixes: bash .claude/hooks/set-state.sh phase off" >&2
exit 2

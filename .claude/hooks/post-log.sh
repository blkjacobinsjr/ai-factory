#!/bin/bash
# PostToolUse Write|Edit: evidence for every TDD cycle. During implementing,
# each source change runs the suite and records red/green (Grove's paired
# indicator: activity × quality). Outside implementing, just log the edit.
cd "${CLAUDE_PROJECT_DIR:-.}"
path=$(jq -r '.tool_input.file_path // empty')
[ -z "$path" ] && exit 0
ts=$(date +%FT%T)
phase=$(grep '^phase=' .factory/state | cut -d= -f2)
if [ "$phase" = "implementing" ] && [[ "$path" != *.md ]]; then
  if mise x ruby@3.3 -- bin/rails test >/dev/null 2>&1; then s=green; else s=red; fi
  bash .claude/hooks/set-state.sh suite "$s" >/dev/null
  echo "{\"ts\":\"$ts\",\"path\":\"$path\",\"suite\":\"$s\"}" >> .factory/log.jsonl
else
  echo "{\"ts\":\"$ts\",\"path\":\"$path\"}" >> .factory/log.jsonl
fi
exit 0

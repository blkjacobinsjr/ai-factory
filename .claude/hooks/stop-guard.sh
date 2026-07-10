#!/bin/bash
# Stop: a turn may not end mid-cycle. Red suite while implementing means
# finish the cycle (green + commit) or revert to the last green commit.
cd "${CLAUDE_PROJECT_DIR:-.}"
input=$(cat)
# avoid infinite stop loops: if we already blocked once this turn, let go
echo "$input" | jq -e '.stop_hook_active == true' >/dev/null 2>&1 && exit 0
sg() { grep "^$1=" .factory/state | cut -d= -f2-; }
if [ "$(sg phase)" = "implementing" ] && [ "$(sg suite)" = "red" ]; then
  echo "Suite is red mid-implementation: make it green and commit, or revert to the last green commit (git checkout .) before ending the turn." >&2
  exit 2
fi
exit 0

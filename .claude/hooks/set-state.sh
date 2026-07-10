#!/bin/bash
# usage: set-state.sh <key> <value>
# Sole mutator of .factory/state. Skills call this at phase transitions —
# nothing else may write the file (Grove: auditable transitions).
set -euo pipefail
cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}"
key="$1"; val="${2:-}"
f=.factory/state
if grep -q "^${key}=" "$f"; then
  sed -i '' "s|^${key}=.*|${key}=${val}|" "$f"
else
  echo "${key}=${val}" >> "$f"
fi
echo "state: ${key}=${val}"

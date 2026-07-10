#!/bin/bash
# UserPromptSubmit: every prompt carries the current factory state —
# Grove's "black box with windows"; the session always knows where it is.
cd "${CLAUDE_PROJECT_DIR:-.}"
echo "FACTORY: $(tr '\n' ' ' < .factory/state)"
exit 0

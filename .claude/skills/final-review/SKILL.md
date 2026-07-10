---
name: final-review
description: Independent verification — parallel reviewer agents plus a Playwright drive of the live app against each acceptance criterion; PASS unlocks push and PR. Use when phase is reviewing.
---

# final-review

**Precondition:** phase=reviewing. Else stop, name the correct skill.

## Steps (READ-DO)
1. **Fan-out — one message, both reviewer agents in parallel** (they are read-only by tool config, not by trust):
   - `code-reviewer`: correctness, plan conformance, test quality on `git diff main...HEAD`
   - `security-reviewer`: OWASP lens on changed files
2. **Playwright acceptance drive** (tests prove code; this proves the product):
   - ensure server: `mise x ruby@3.3 -- bin/rails server -d` (or confirm :3000 responds)
   - via Playwright MCP (load tools with ToolSearch if deferred): walk each acceptance criterion in the real browser at localhost:3000 — perform the action, verify the visible outcome, screenshot each.
   - **MCP not connected** (ToolSearch finds no playwright tools — happens when the server wasn't approved at session start): don't skip the drive. Script the same walk with the playwright npm package (template: `work/001/drive.mjs`), screenshots into `work/<id>/screenshots/`. Turbo swaps pages async — every assertion must auto-wait (`locator.waitFor`), never instant-count.
3. Write `work/<id>/review.md`: per criterion PASS/FAIL + evidence (screenshot/step), reviewer findings (file:line), verdict.
4. **PAUSE (human gate):** show review.md summary. The verdict is the human's call.
5. **On PASS:**
   ```
   bash .claude/hooks/set-state.sh verdict PASS   # opens the push gate — MUST be its own Bash call:
                                                  # the gate reads state when a command starts, so
                                                  # `set-state && git push` in one command stays blocked
   git push -u origin ticket/<id>
   gh pr create --fill --body "Closes #<issue>. $(see PR handoff below)"
   ```
   The PR body must start with `Closes #<issue-number>` (from ticket.md's GitHub line) so ticket and PR are linked on GitHub and the issue auto-closes on merge.
   Then hand off exactly: `Pushed — please review: <PR URL>` + 3 bullets *what changed* + 3 bullets *what to look out for* (risk spots, tradeoffs taken, decisions that are the human's), written for a reader who won't parse the syntax.
6. **On FAIL (OODA re-orientation):** convert each finding into a new step in plan.md, `set-state verdict FAIL`, `set-state phase planned`, route back to `/tdd-implement`. Never patch ad-hoc.
7. **After the human merges:** append a row to `.factory/metrics.md` (cycles, review fails, merged ✓), then back to main — hooks leave `.factory/state` + `log.jsonl` dirty, which blocks checkout, so:
   ```
   git stash push .factory/log.jsonl .factory/state -m "factory bookkeeping"
   git checkout main && git pull && git stash pop
   ```
   then `set-state phase idle`, `set-state ticket ""`, `set-state verdict ""`, delete the merged local branch.

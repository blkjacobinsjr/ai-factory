---
name: tdd-implement
description: Execute the approved plan step by step with red-green-refactor; one failing test, minimal code, one commit per step. Use when phase is planned.
---

# tdd-implement

**Precondition:** phase=planned and approved `work/<id>/plan.md` exists. Else stop, name the correct skill.

## Steps (READ-DO)
1. `bash .claude/hooks/set-state.sh phase implementing` — this unlocks source writes; hooks now run the suite after every edit and record red/green.
2. Per plan step, strictly in order (OODA micro-loop):
   - **Red:** write the step's failing test. Run `bin/rails test` — confirm it fails for the expected reason (wrong failure = wrong test; fix the test first).
   - **Green:** minimal implementation — only the files the step names. With teaching comments (see rules).
   - **Commit:** `git commit` with the step's message from plan.md. (Hook blocks red commits — if blocked, the cycle isn't done.)
3. Never start step N+1 on red. Stuck after 2 honest attempts → stop, revert to last green commit, report which step and why.
   **Don't write step N+1's implementation while writing step N's** (tickets 005 and 007 both did this — writing a whole controller's actions or a whole model's associations in one pass before their own steps' tests existed). The tell: a later step's test goes green with a diff of *zero production lines*. That's not a lucky "born green" (scoping coincidence, e.g. an association already correctly excluding another user's rows) — it's evidence the code was written before the test that was supposed to drive it. Before implementing a step, re-read that step's own bullet in plan.md and touch only what it names, even when the next step's code is obvious and sitting right there.
4. All steps done → full suite once more → `bash .claude/hooks/set-state.sh phase reviewing` (this re-locks source files). Next command: `/final-review`. **Applies equally to re-orientation steps appended after a review FAIL** (ticket 004 skipped this on its second pass — went straight from the last fix commit to re-verifying and updating review.md without ever setting phase back to `reviewing`. Harmless there since the push gate keys on `verdict` not `phase`, but it breaks the state file's audit trail — always close the transition, even mid-ticket re-entries).

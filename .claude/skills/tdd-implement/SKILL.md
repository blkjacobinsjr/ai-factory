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
4. All steps done → full suite once more → `bash .claude/hooks/set-state.sh phase reviewing` (this re-locks source files). Next command: `/final-review`.

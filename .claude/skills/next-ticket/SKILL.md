---
name: next-ticket
description: The factory's loop driver — look at .factory/state and the GitHub queue, then invoke whatever skill comes next. Use when the user says "next", "continue", or wants the factory to keep going without naming a phase.
---

# next-ticket

One command that always knows what's next. Never does work itself — it only dispatches.

## Steps (READ-DO)
1. Read `.factory/state`.
2. Dispatch on phase:
   - `refined` → invoke `plan-ticket`
   - `planned` → invoke `tdd-implement`
   - `implementing` → resume `tdd-implement` at the first unfinished plan step
   - `reviewing` → invoke `final-review` (or, if verdict=PASS and a PR is open, remind the human to merge; if merged, run final-review's close-loop step)
   - `idle` → pick up new work, next step
3. When idle: `gh issue list --state open --json number,title` — filter to intake issues (body contains "Intake for the AI factory" or clear feature asks). Present the queue one line each with the dependency order noted in the issue bodies; recommend the top unblocked one; on the human's pick (or standing approval), invoke `refine-ticket` with `#<n>`.
4. WIP guard: never start refining if a ticket is mid-flight (phase != idle) — the phase dispatch above already guarantees this.

---
name: plan-ticket
description: Research the codebase with parallel sub-agents, then write a TDD plan where each step covers one acceptance criterion. Use when phase is refined.
---

# plan-ticket

**Precondition:** phase=refined and `work/<id>/ticket.md` exists (id from state). Else stop, name the correct skill.

## Steps (READ-DO)
1. **Fan-out — one message, 3 Explore agents in parallel** (never sequential):
   - existing patterns: controllers/models/views relevant to the ticket
   - test conventions: how tests in `test/` are structured, fixtures, helpers
   - data layer: schema, migrations, associations touched by the ticket
2. Write `work/<id>/plan.md`:
   - **Criteria (verbatim)** — copy acceptance criteria word-for-word from ticket.md (Gawande read-back; drift here is a defect).
   - **Steps** — one step per criterion, in dependency order. Each step: test file + test name → expected failure → minimal implementation sketch (files touched) → commit message.
   - **Research notes** — ≤5 lines of what the fan-out found that shaped the plan.
3. Killer-item self-check: every criterion has exactly one step? · no step touches files it doesn't need? · criteria copied verbatim? · steps ordered so each builds on green?
4. **PAUSE (human gate):** show the plan. Ask: approve / edit. Do not proceed without approval.
5. On approval: `bash .claude/hooks/set-state.sh phase planned`. Next command: `/tdd-implement`.

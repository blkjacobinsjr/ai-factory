---
name: refine-ticket
description: Turn a rough feature idea into a ticket with test-verifiable acceptance criteria, get human approval, open the ticket branch. Use when the user gives a feature idea and phase is idle (or done).
---

# refine-ticket

**Precondition:** `.factory/state` phase=idle. If not, stop and name the correct skill. WIP check: if 3 tickets already sit in `work/` unimplemented, refuse (Goldratt cap) — the constraint is the human; don't pile inventory.

## Steps (READ-DO)
1. `id` = next zero-padded number after existing `work/*` dirs (001, 002…).
   **Issue as source:** if the argument is `#<n>`, an issue URL, or "issue <n>", fetch it first — `gh issue view <n> --json title,body` — and treat title+body as the rough idea. The refined criteria usually differ from what the issue author wrote; that's the point of this phase.
2. Draft `work/<id>/ticket.md`:
   - **Title** (imperative, ≤8 words)
   - **Context** (≤2 lines: why this exists)
   - **Acceptance criteria** — 3–6, each one *verifiable by a single automated test*, phrased "Given/When/Then". No criterion may require human judgment to evaluate.
   - **Out of scope** (explicit non-goals)
3. Killer-item self-check before showing: every criterion test-verifiable? · fits one TDD session? · out-of-scope stated? · title matches criteria?
4. **PAUSE (human gate):** show the full ticket text. Ask: approve / edit. Do not proceed without explicit approval; apply edits verbatim.
5. On approval:
   ```
   git checkout -b ticket/<id>
   gh issue create --title "<title>" --body-file work/<id>/ticket.md
   # …or, when the ticket came FROM an existing issue, update it instead of duplicating:
   # gh issue edit <n> --title "<title>" --body-file work/<id>/ticket.md
   bash .claude/hooks/set-state.sh ticket <id>
   bash .claude/hooks/set-state.sh phase refined
   ```
   Record the issue URL at the top of ticket.md (`GitHub: <url>`) and give the user the link — the ticket is now visible on GitHub, not only in local files.
6. Tell the user the single next command: `/plan-ticket`.

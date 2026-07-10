# The AI Factory — refined with Goldratt · Grove · Gawande · Boyd

A single Claude session follows instructions *probabilistically*. The factory makes the process hold anyway: **skills** own the phases, **rules** own the discipline, **hooks** own enforcement (deterministic bash, zero tokens), **sub-agents** own parallel research and independent verification. The human owns every text.

## Pipeline
```
idle ─refine→ refined ─plan→ planned ─implement→ implementing ─review→ reviewing ─PASS→ done
        │ticket.md      │plan.md         │green commits          │review.md   └FAIL→ back to plan
```
State lives in `.factory/state`; artifacts in `work/<id>/`. A fresh session reads those two things and continues — nothing important lives in conversation history.

## Lifecycle (H=human · M=model · SA=sub-agents · 🔒=hook)
1. H: `/refine-ticket "<rough idea>"`
2. M drafts test-verifiable acceptance criteria → **H approves ticket.md** → branch + phase=refined 🔒
3. H: `/plan-ticket` → SA fan-out ×3 (patterns/tests/data, one parallel batch) → plan: 1 step = 1 criterion = 1 TDD cycle → **H approves plan.md** → phase=planned
4. H: `/tdd-implement` → red→green→commit per step; 🔒 suite runs on every edit, red commits blocked, can't end turn red
5. H: `/final-review` → SA fan-out ×2 (code-reviewer, security-reviewer, read-only) + Playwright drives each criterion in the real browser → review.md with evidence → **H owns the verdict**
6. PASS 🔒opens push → PR + link + plain-English briefing → H merges → metrics row → phase=idle

## What the books changed
- **The Goal:** the human is the bottleneck — "an hour lost at a bottleneck" is lost to the whole system. WIP caps (≤3 refined, ≤1 implementing); while the human reviews, the factory refines/plans the next ticket, never implements. Measure throughput × review-fail-rate, not activity.
- **High-Output Management:** kill defects at the "lowest-value stage possible" — strictest checklist at refine (cheap), widest lens at review (expensive). Hooks are the highest-leverage artifact: written once, enforce forever, zero runtime tokens. Paired indicators in `.factory/metrics.md`. State + log = "black box with windows".
- **Checklist Manifesto:** checklists only at pause points (phase transitions); 5–7 killer items each; READ-DO lists inside skills for the model, DO-CONFIRM lists in RUNBOOK.md for the human; the first ticket is the flight test — revise checklists after it.
- **OODA:** micro loop = one TDD cycle (Observe test output → Orient vs plan → Decide → Act). Macro loop = the ticket. Review-FAIL is re-orientation: findings become plan steps, never ad-hoc patches. Tempo beats perfection: small batches.

## When NOT to use the factory
Typo-class changes: `bash .claude/hooks/set-state.sh phase off`, fix, set back to `idle`. The pipeline earns its overhead only when work has real phases.

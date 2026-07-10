# RUNBOOK — your DO-CONFIRM checklists

You type one command per phase; Claude does the work; you confirm at three pause points. That's the whole job.

## Start
- new terminal (mise loads Ruby automatically) → `cd ~/Documents/GitHub/spiced/ai-factory`
- see the app: `bin/rails server` → http://localhost:3000
- start Claude Code here; approve the project hooks prompt once
- check where things stand: `cat .factory/state`

## Pause point 1 — ticket (after `/refine-ticket "idea"`)
Confirm before saying "approved":
- [ ] I understand each acceptance criterion in plain English
- [ ] each criterion is a yes/no fact a test can check (no "looks good")
- [ ] nothing I care about is missing; nothing extra snuck in
- [ ] "Out of scope" matches my intent

## Pause point 2 — plan (after `/plan-ticket`)
- [ ] criteria at the top are word-for-word from my ticket
- [ ] one step per criterion, each ends in a commit
- [ ] steps small: none says "and also…"

## Pause point 3 — verdict (after `/final-review`)
- [ ] every criterion shows PASS with Playwright evidence (screenshot of the real app doing it)
- [ ] reviewer findings: none high-severity, or I explicitly accept them
- [ ] FAIL anything unclear — one sentence why is enough; findings become new plan steps automatically

## Reviewing the PR (you don't need to read syntax)
1. Open the PR link Claude gives you.
2. Read the briefing: *what changed* / *what to look out for*.
3. In changed files, read the **teaching comments** — they state what each piece does, the risk if wrong, and the tradeoff taken.
4. Cross-check: does the Playwright evidence show each ticket criterion working?
5. Merge — or reply FAIL with one sentence; the factory re-orients.

## If something is blocked
The BLOCKED message names the skill to run. Run it. Never work around a gate.
Trivial fix outside the process: `bash .claude/hooks/set-state.sh phase off` → fix → set `idle` back.

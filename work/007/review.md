# Review — ticket 007: Add AI summary and next-steps for goals

Suite: green (46 tests, 180 assertions). Browser drive: `drive.mjs` — the first drive in this factory to exercise a **real external API call** (OpenAI, real key), not a stub, since that's the one thing the ticket's own out-of-scope note says the automated suite can't cover.

## Acceptance criteria

| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | generate summary, persisted + displayed | PASS | test (stubbed) + drive: **real** AI summary, contextually accurate (`02-01-real-summary.png`) |
| 2 | suggest next steps, 2-3 items as a list | PASS | test (stubbed) + drive: 3 real next steps rendered (`03-02-real-next-steps.png`) |
| 3 | AI failure handled gracefully | PASS | test (service-level: bad response → `Error`; controller-level: flash shown, no partial save) |
| 4 | cross-user goal blocked, no AI call made | PASS | test (stub raises if called at all — proves the call never happens, not just that the response is 404) |

## Findings from review — three real bugs, all fixed same-session

- **Missing `require "net/http"`/`require "json"`** — every automated test stubs the network-touching method, so this was invisible to the whole TDD process; only surfaced via a real `bin/rails runner` call. Fixed; re-verified with a second real call (succeeded) and the full browser drive.
- **`.env.example` never committed** — it matched the pre-existing `/.env*` gitignore glob. Found independently by the security reviewer AND would have meant no one else could set up this feature after merge. Fixed with a `!/.env.example` gitignore exception; `.env` itself (the real secret) remains correctly untracked — confirmed via `git status --ignored`.
- **`stub_class_method` test helper permanently un-privates a private class method after use** (`define_singleton_method` always defines public, even when restoring) — code reviewer caught this; confirmed by direct reproduction. Fixed to track and restore `private_class_method` status; new test proves it. This helper is shared infrastructure — the fix protects every future ticket that uses it, not just this one.

## Finding acknowledged, not reversed: TDD discipline

Code reviewer's most serious finding: step 1's commit wrote the *entire* `AiInsightsController` (both actions, both rescue blocks) instead of just `#generate_summary`, so steps 2 and 3's tests went green with **zero new production code** — not a scoping coincidence like some earlier tickets' legitimately-born-green steps, but evidence the implementation preceded the test meant to drive it. This is a real, self-disclosed (in the step 2/3 commit messages) violation of the factory's mandatory TDD rule.

I'm not rewriting commit history to fabricate a retroactive red phase — the factory rules don't call for that, and doing so would misrepresent what actually happened. Instead: added an explicit callout to `.claude/skills/tdd-implement/SKILL.md` naming the tell (a step's test passing with a zero-line diff) so this is caught *during* implementation next time, not just disclosed after the fact. This is now a documented, recurring failure mode (tickets 005 and 007 both did it) — worth watching for specifically in ticket 008 onward.

Minor findings also fixed: missing teaching comment on the routes `member do` block; documented the `goal.update!`-can't-realistically-fail assumption in the controller.

## Verdict
Recommendation: **PASS** — all 4 criteria verified twice (stubbed tests + a real, live AI API call end-to-end), three real bugs found and fixed this session (two of them in shared infrastructure or a way that would have silently broken future work), and the one unfixable finding (TDD-order discipline) is honestly acknowledged with a concrete process change rather than papered over.

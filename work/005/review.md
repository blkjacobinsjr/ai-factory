# Review — ticket 005: Add Goals and LearningSessions CRUD

Suite: green (42 tests, 164 assertions). Browser drive: `drive.mjs`, two independent real signed-in sessions (user A / user B), screenshots in `screenshots/`.

## Acceptance criteria

| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | create Goal, scoped index | PASS | test + drive `01-c1-goal-created.png` |
| 2 | edit/delete own Goal | PASS | test |
| 3 | cross-user Goal → 404 | PASS | test (born green — scoping from step 2 already correct) + drive `03-c3-cross-user-goal-blocked.png` (real second account, real 404) |
| 4 | create LearningSession, shows on goal page | PASS | test + drive `02-c4-session-logged.png` |
| 5 | cross-user LearningSession destroy → 404 | PASS | test (born green) |
| 6 | status filter | PASS | test + drive `04-c6-status-filter.png` |

## Findings

Code reviewer (PASS): two minors — `LearningSessionsController#create` has no error handling if the session fails to save (silently redirects, 0 rows; not required by any criterion); create-direction scoping had no test (fixed same-session, see below). Confirmed both "born green" steps (3, 5) are legitimate — the scoping code from steps 2/4 already covered them, not skipped work. Confirmed the mid-step self-correction (a premature `has_many :learning_sessions` added in step 1, removed in step 2 once it broke `destroy`) is an honest fix, not sloppiness.

Security reviewer (PASS): verified every lookup in both controllers goes through `Current.user.goals` / `Current.user.learning_sessions` (through `:goals`) — no bare `Goal.find`/`LearningSession.find` anywhere reachable from user input; strong params permit only intended fields; the status filter's `where` runs on an already-scoped relation (verified empirically: invalid status → 0 rows, no exception, no full-table leak); shallow routes restrict the session surface to create/destroy only; CSRF protection intact.

One gap both reviewers independently surfaced: the **create** direction of learning-session scoping (`goal_id` from params) had a passing implementation but no test — only destroy was covered. Added `test "blocks creating a learning session under another user's goal with 404"` in the same session (confirmed green — the code was already correct, this closes a real verification gap on the ticket's most security-sensitive surface).

## Verdict
**PASS** — all 6 criteria verified twice (automated tests + real two-account browser drive); the one coverage gap surfaced by review was closed same-session rather than deferred, given this ticket is the app's first per-user data boundary.

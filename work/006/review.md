# Review — ticket 006: Convert bookmarks to goal-linked Resources

Suite: green (38 tests, 149 assertions). Browser drive: `drive.mjs`, two independent real signed-in accounts, screenshots in `screenshots/`.

## Acceptance criteria

| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | attach + display Resource, badged by type | **FAIL** (test is vacuous, see F1) | drive confirms the real behavior works (`02-01-resource-attached.png`); the automated test doesn't actually prove it |
| 2 | validation reused, visible error | PASS | test + drive `03-02-invalid-resource-error.png` |
| 3 | cross-user Resource blocked | PASS | test + drive `04-03-cross-user-blocked.png` (real second account, real 404) |
| 4 | root moved, pipeline strip, tailwind linked once | PASS | test + drive `01-00-homepage-is-goals.png` |

## Findings

- **F1 (major, code reviewer)** `test/controllers/resources_controller_test.rb` — `assert_match "doc", response.body` passes even if the resource badge is never rendered, because the attach form's `<select>` always contains the literal option text "doc". Doesn't actually prove criterion 1's "badged by type." Fix: `assert_select ".phase-badge", text: "doc"`.
- **F2 (major, code reviewer)** No happy-path test that a user can delete their **own** resource — only the cross-user-blocked case is tested. The deleted `bookmarks_controller_test.rb` had exactly this coverage for Bookmark and it wasn't rebuilt for Resource.
- **F3 (major, security reviewer, independently confirmed)** `Resource.resource_type=` raises `ArgumentError` for any value outside the enum (confirmed via `bin/rails runner`) — a crafted POST with `resource_type=garbage` 500s instead of failing cleanly. **This is not unique to Resource** — I confirmed the identical bug already exists on `Goal#status` (merged in ticket 005, review didn't catch it there): `User.first.goals.build(status: "garbage")` also raises. Fixing both from a shared place rather than patching Resource alone and leaving Goal's copy of the same bug live.
- Minor/informational (code reviewer, not actioned): the pipeline partial's render call landed in step 1 slightly ahead of its driving test in step 4 (full suite covers it by the final commit, so no live gap); `main.container`/form-styling assertions from the old bookmark tests weren't rebuilt (no dedicated resource page exists to test them against — matches the plan's own research note).

## Verdict round 1 (human): FAIL
F1 (major, test-only) + F2 (major, coverage gap) + F3 (major, cross-cutting crash bug, also affects already-merged ticket 005 code) → plan steps 5–7.

# Review — ticket 004: Add auth and profile management

Suite: green (33 tests, 126 assertions) — but green here is misleading, see F1. Browser drive: `drive.mjs`, screenshots in `screenshots/`.

## Acceptance criteria

| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | anonymous → redirect to sign-in | PASS | test + drive `01-c1-redirect-to-signin.png` |
| 2 | sign-up creates+signs-in+redirects | **FAIL** | drive: real form submit → 422 (see F1); unit test passes but tests the wrong param shape |
| 3 | sign-out ends session | PASS | test + drive `03-c3-signed-out.png` |
| 4 | profile page scoped to owner | PASS (partial) | test proves cross-user isolation; drive only reached the nil-profile guard (no browser path creates a Profile — model-level persistence is unit-tested, C5) |
| 5 | Profile persists via user.profile | PASS | unit test |

## Findings

- **F1 (blocker — found by browser drive, not the reviewers)** `app/controllers/registrations_controller.rb:14` — `params.permit(:email_address, :password)` reads top-level params, but `form_with model: @user` (the actual sign-up form) posts nested `params[:user][:email_address]`. Real sign-up 422s with "Unpermitted parameters" (confirmed in `log/development.log`). `registrations_controller_test.rb` posts *flat* params matching the bug, so it passes while the real UI is broken — the test verifies the wrong contract. Fix: `params.require(:user).permit(:email_address, :password)` + rewrite the test to post through the nested shape a real form uses.
- **F2 (major — security reviewer)** `app/models/user.rb` — no `uniqueness` validation on `email_address`. DB has a unique index, so a duplicate signup doesn't silently succeed, but it raises unhandled `ActiveRecord::RecordNotUnique` (confirmed via `bin/rails runner`) instead of a normal validation failure — a 500, not a form re-render.
- **F3 (minor — security reviewer)** `RegistrationsController#create` has no `rate_limit`, unlike `SessionsController#create`/`PasswordsController#create` (both `10, within: 3.minutes`) — sign-up is unthrottled.
- **F4 (minor — security reviewer)** No minimum password length; `has_secure_password` only enforces bcrypt's 72-char cap.
- **F5 (low — code reviewer)** `test/controllers/profile_controller_test.rb` tests `ProfilesController` (plural) — filename/class name is a naming leftover from the initial singular attempt. Pure rename, no behavior change — folding into the fix pass rather than a dedicated step.
- Accepted, not actioned (outside the ticket's stated criteria, backlog candidates): no test for the nil-profile view branch; no test for registration failure path; commit `df74fee` carries prior-ticket factory tooling into this branch (same accepted pattern as ticket 001's retro commit).

Code reviewer: RECOMMEND PASS (didn't catch F1 — it only reviewed diff/tests statically; the mismatch only shows up when a real form's param shape is exercised, which is exactly what the browser drive is for).
Security reviewer: RECOMMEND FAIL (F2).

## Verdict (human's call)
Recommendation: **FAIL** — F1 means criterion 2 doesn't actually work outside the test suite; F2 is a real crash path. Both are small, well-understood fixes.

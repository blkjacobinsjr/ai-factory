GitHub: https://github.com/blkjacobinsjr/ai-factory/issues/13

# Add auth and profile management

## Context
Brief feature 2 (issue #13). Rails 8's built-in `bin/rails generate authentication` (no Devise, no new gems) plus a Profile per user. Everything after this ticket (Goals, Resources, AI actions) scopes to the signed-in user.

## Acceptance criteria
1. Given no session, When a visitor GETs `/`, Then they are redirected to the sign-in page (homepage requires authentication).
2. Given valid new-account params (email + password), When a visitor submits sign-up, Then a User is created, they are signed in, and redirected to the homepage.
3. Given a signed-in user, When they submit sign-out, Then their session ends and the next request to `/` redirects to sign-in again.
4. Given a signed-in user, When they GET their profile page, Then it shows their own name, cohort, and focus_area tags — and does not query or expose any other user's profile data.
5. Given a signed-up user, When a Profile is created for them (name, cohort, focus_areas), Then it persists and `user.profile` returns it.

## Out of scope
- Password reset / email confirmation flows
- Editing the profile (view-only this ticket; edit is a natural follow-up, not required by the brief)
- Scoping existing Bookmark records to users (explicitly deferred to the Resource-conversion ticket, #15)
- OAuth / third-party sign-in

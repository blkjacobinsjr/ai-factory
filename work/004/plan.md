# Plan — ticket 004: Add auth and profile management

## Criteria (verbatim)
1. Given no session, When a visitor GETs `/`, Then they are redirected to the sign-in page (homepage requires authentication).
2. Given valid new-account params (email + password), When a visitor submits sign-up, Then a User is created, they are signed in, and redirected to the homepage.
3. Given a signed-in user, When they submit sign-out, Then their session ends and the next request to `/` redirects to sign-in again.
4. Given a signed-in user, When they GET their profile page, Then it shows their own name, cohort, and focus_area tags — and does not query or expose any other user's profile data.
5. Given a signed-up user, When a Profile is created for them (name, cohort, focus_areas), Then it persists and `user.profile` returns it.

## Steps (dependency order — generator first, Profile model before Profile page)

### Step 1 → criterion 1 (auth required on `/`)
- Test: `test/controllers/bookmarks_controller_test.rb` — `test "anonymous visitor is redirected to sign-in"` (`get root_url; assert_redirected_to new_session_path`)
- Expected failure: currently 200, not a redirect
- Implementation: `bin/rails generate authentication` (Rails 8.1 built-in — no Devise). This uncomments+installs `bcrypt`, generates `User`/`Session`/`Current` models, `SessionsController`, `PasswordsController`, the `Authentication` concern (included in `ApplicationController`, which puts `before_action :require_authentication` on **every** controller by default), routes (`resource :session`, `resources :passwords`), migrations for `users`/`sessions`, sign-in/password-reset views, and its own test helper (`sign_in_as`) + fixtures (`test/fixtures/users.yml`, password `"password"`). Run `bin/rails db:migrate`.
  - **Required follow-up, not scope creep:** every controller now requires auth by default, so the 11 existing `bookmarks_controller_test.rb` tests (written pre-auth) start failing (redirected instead of 200). Add `setup { sign_in_as users(:one) }` to that test class — necessary to keep the suite green, not a new feature.
- Commit: `ticket-004: install Rails 8 authentication, require sign-in`

### Step 2 → criterion 2 (sign-up)
- Test: `test/controllers/registrations_controller_test.rb` — `test "sign-up creates a user, signs them in, redirects home"` (`assert_difference("User.count")`, `post sign_up_path, params: {...}`, `assert_redirected_to root_path`, then `get root_url` and `assert_response :success` — proving the session actually started, not just the redirect)
- Expected failure: `ActionController::RoutingError` (no sign-up route/controller — confirmed absent from the generator by design; DHH's stated rationale is registration is app-specific)
- Implementation: routes `get "sign_up" => "registrations#new"`, `post "sign_up" => "registrations#create"`; `RegistrationsController` (`allow_unauthenticated_access`, `create` builds `User.new(params.permit(:email_address, :password))`, on save calls the concern's `start_new_session_for(user)` then redirects to `root_path`, else re-renders `:new`); `app/views/registrations/new.html.erb` (styled with existing `.input`/`.label`/`.btn` components)
- Commit: `ticket-004: add sign-up (registration)`

### Step 3 → criterion 3 (sign-out)
- Test: same file area, `test/controllers/sessions_controller_test.rb` (generator-provided, extended) — `test "sign-out ends the session"` (sign in, `delete session_path`, then `get root_url`, `assert_redirected_to new_session_path`)
- Expected failure: likely **none** — the generator's `SessionsController#destroy` already exists and this may go green immediately (same as ticket 002's step 2). If so, document it as a verification step, not a fabricated red.
- Implementation: none expected beyond the test; if red, the only gap would be a missing `destroy` route/action, added minimally.
- Commit: `ticket-004: verify sign-out ends session`

### Step 4 → criterion 5 (Profile model)
- Test: `test/models/profile_test.rb` — `test "persists and is accessible via user.profile"` (create a `User`, `Profile.create!(user:, name:, cohort:, focus_areas:)`, assert `user.reload.profile == profile`)
- Expected failure: `NameError: uninitialized constant Profile`
- Implementation: migration `CreateProfiles` (`user:references`, `name:string`, `cohort:string`, `focus_areas:string` — comma-separated, simplest form per ticket wording, no serialization); `app/models/profile.rb` (`belongs_to :user`); add `has_one :profile, dependent: :destroy` to the generated `app/models/user.rb`
- Commit: `ticket-004: Profile model belongs to User`

### Step 5 → criterion 4 (Profile page, scoped)
- Test: `test/controllers/profile_controller_test.rb` — `test "shows only the signed-in user's own profile data"` (two users, each with a `Profile`; sign in as user one; `get profile_path`; assert response includes user one's name/cohort/focus areas; assert it does **not** include user two's name)
- Expected failure: no route/controller for profile
- Implementation: route `resource :profile, only: [:show]` (singular, no `:id` — there is no URL parameter to swap to see another user's profile, which is what makes the scoping structural rather than a runtime check); `ProfileController#show` (`@profile = Current.user.profile`); `app/views/profile/show.html.erb` (name, cohort, focus_areas split into badge-styled tags reusing `.btn-ghost`)
- Commit: `ticket-004: profile page scoped to the signed-in user`

## Re-orientation steps (from review FAIL — work/004/review.md)

### Step 6 → finding F1 (sign-up broken through the real form; blocker)
- Test: rewrite `registrations_controller_test.rb` to post through the SAME nested shape `form_with model: @user` actually generates — `post sign_up_path, params: { user: { email_address:, password: } }` — this is what exposes the bug (flat params were masking it)
- Expected failure: 422 "Unpermitted parameters" (reproduces the real-world break)
- Implementation: `registrations_controller.rb` — `params.require(:user).permit(:email_address, :password)`. Fold in F5 (rename `test/controllers/profile_controller_test.rb` → `profiles_controller_test.rb`, pure rename, no behavior change, no separate step needed)
- Commit: `ticket-004: fix sign-up param nesting (real form was broken)`

### Step 7 → finding F2 (crash on duplicate email; major)
- Test: `test/models/user_test.rb` (generator-provided, extend) — `test "is invalid with a duplicate email address"` (create one user, attempt a second with the same email, assert `invalid?` + error on `:email_address`, NOT an exception)
- Expected failure: `ActiveRecord::RecordNotUnique` raised instead of a normal validation failure
- Implementation: `app/models/user.rb` — `validates :email_address, presence: true, uniqueness: true` (normalizes already downcases, so this is effectively case-insensitive)
- Commit: `ticket-004: User requires a unique email address`

### Step 8 → findings F3+F4 (unthrottled sign-up + no minimum password length; minor, folded)
- Test: `registrations_controller_test.rb` — two cheap additions: a `rate_limit`-style throttle isn't unit-testable without time travel, so this step covers only F4: `test "rejects a too-short password"` (3-char password → 422, error on `:password`)
- Expected failure: 3-char password currently succeeds
- Implementation: `app/models/user.rb` — `validates :password, length: { minimum: 8 }, allow_nil: true` (has_secure_password already requires presence on create); `registrations_controller.rb` — add `rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_sign_up_path, alert: "Try again later." }` matching SessionsController's existing pattern (not separately unit-tested — same untested-by-design as the existing rate limits on Sessions/Passwords)
- Commit: `ticket-004: harden sign-up (min password length, rate limit)`

## Research notes
- Rails 8.1.3's `generate authentication` produces User/Session/Current/SessionsController/PasswordsController/Authentication concern, wires `before_action :require_authentication` into `ApplicationController` (global by default — opt out per-action via `allow_unauthenticated_access`), and ships its own `sign_in_as` test helper + `users.yml` fixture (password `"password"`). Deliberately excludes sign-up (confirmed: no RegistrationsController, no view, no route) — that's on us.
- `Current.user` is already public (delegates to `Current.session.user`); no extra plumbing needed to read "the signed-in user" anywhere in the app.
- Session is a real DB row (revocable), not just a cookie — cookie carries only the signed session id.
- Installing the generator will break all 11 existing bookmark tests (global auth) until they sign in — addressed inside step 1, not a separate step, since it's a direct consequence of criterion 1, not a new criterion.
- Profile route as `resource :profile` (no id) makes "can't see another user's profile" a structural fact, not just a behavior we assert once and hope holds.

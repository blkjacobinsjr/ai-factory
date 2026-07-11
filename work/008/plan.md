# Plan — ticket 008: Add dashboard with ORM aggregations

## Criteria (verbatim)
1. Given a signed-in user's own goals across multiple statuses, When they visit the dashboard, Then it shows a count of goals per status, computed via `group(:status).count`.
2. Given a signed-in user's own learning sessions with different `tags` values, When they visit the dashboard, Then it shows total logged hours per tags value, computed via `group(:tags).sum(:duration)`.
3. Given a signed-in user's own learning sessions across different weeks, When they visit the dashboard, Then it shows total logged hours per week, computed via `group(...).sum(:duration)` (SQLite date truncation, not a Ruby loop).
4. Given another user's goals and learning sessions exist, When the signed-in user visits the dashboard, Then none of that other user's data appears in any of the three aggregations.

## Steps (each step adds exactly ONE instance variable to the SAME `DashboardController#index` action + its view fragment — not a new action ahead of its own step, avoiding ticket 007's front-loading lapse)

### Step 1 → criterion 1 (goal counts per status)
- Test: new `test/controllers/dashboard_controller_test.rb` — `test "shows goal counts per status"` (create goals in 2+ statuses, `get dashboard_path`, assert each status/count pair appears)
- Expected failure: no route/controller
- Implementation: route `get "dashboard" => "dashboard#index"`; `app/controllers/dashboard_controller.rb` with `@goals_by_status = Current.user.goals.group(:status).count` (confirmed via `bin/rails runner` that Rails' enum-aware grouping already returns string keys like `"planned"`, not raw integers — no extra mapping needed); `app/views/dashboard/index.html.erb` (simple table); link to it from `goals/index.html.erb`
- Commit: `ticket-008: dashboard shows goal counts per status`

### Step 2 → criterion 2 (hours per tags value)
- Test: same file — `test "shows total hours per tags value"` (sessions with different `tags` strings, assert hours shown per value — confirmed via `bin/rails runner` that `group(:tags).sum(:duration)` groups by the exact stored string, matching the ticket's own out-of-scope note about not splitting multi-tag combos)
- Expected failure: no `@hours_by_tag`, table section missing
- Implementation: add `@hours_by_tag = Current.user.learning_sessions.group(:tags).sum(:duration)` to the same action; view gets a second table (minutes summed by SQL, divided to hours only for display — a formatting step, not the aggregation itself)
- Commit: `ticket-008: dashboard shows total hours per tag`

### Step 3 → criterion 3 (hours per week)
- Test: same file — `test "shows total hours per week"` (sessions across 2+ weeks, assert distinct week totals shown)
- Expected failure: no `@hours_by_week`, table section missing
- Implementation: add `@hours_by_week = Current.user.learning_sessions.group("strftime('%Y-%W', date)").sum(:duration)` (confirmed working via `bin/rails runner`; SQLite-specific, matches this app's DB — same class of raw-SQL-fragment-inside-group as any Rails app without the `groupdate` gem); view gets a third table
- Commit: `ticket-008: dashboard shows total hours per week`

### Step 4 → criterion 4 (cross-user scoping)
- Test: same file — `test "excludes other users' goals and sessions from every aggregation"` (goal + session under `users(:two)`, signed in as `users(:one)`, assert that other user's status/tag/week values never appear)
- Expected failure: **may already be green** — every query in the action goes through `Current.user.goals`/`Current.user.learning_sessions`, same scoping as every other controller in this app. Document rather than fabricate a red if so.
- Implementation: none expected beyond the test
- Commit: `ticket-008: verify dashboard excludes other users' data`

## Research notes
- Verified via `bin/rails runner` (not assumed, given this session's history of assumption bugs): Rails' enum attributes ARE grouping-aware — `goals.group(:status).count` returns `{"planned"=>2, "in_progress"=>1}` (string keys), not raw integers.
- Verified `learning_sessions.group("strftime('%Y-%W', date)").sum(:duration)` and `.group(:tags).sum(:duration)` both work correctly against this app's SQLite database with real data.
- No new gem (`groupdate` etc.) — a raw SQL fragment inside `.group(...)` is the standard, minimal way to truncate a date to a week without one.
- `duration` is stored in minutes; conversion to hours happens once in the view per aggregation row (division, not iteration over individual `LearningSession` records) — the grouping/summing itself is 100% ActiveRecord/SQL.

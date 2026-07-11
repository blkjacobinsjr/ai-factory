GitHub: https://github.com/blkjacobinsjr/ai-factory/issues/17

# Add dashboard with ORM aggregations

## Context
Brief feature 6 (issue #17). A dashboard page showing goal counts per status and session hours per tag/per week, all computed via ActiveRecord `group`/`sum` (no Ruby-side loops over individual records) and scoped to the signed-in user.

## Acceptance criteria
1. Given a signed-in user's own goals across multiple statuses, When they visit the dashboard, Then it shows a count of goals per status, computed via `group(:status).count`.
2. Given a signed-in user's own learning sessions with different `tags` values, When they visit the dashboard, Then it shows total logged hours per tags value, computed via `group(:tags).sum(:duration)`.
3. Given a signed-in user's own learning sessions across different weeks, When they visit the dashboard, Then it shows total logged hours per week, computed via `group(...).sum(:duration)` (SQLite date truncation, not a Ruby loop).
4. Given another user's goals and learning sessions exist, When the signed-in user visits the dashboard, Then none of that other user's data appears in any of the three aggregations.

## Out of scope
- Splitting a multi-tag session (e.g. `"rails, reading"`) into two separate per-tag totals — `tags` is a plain comma-separated string (same simplification as `Profile#focus_areas`), so criterion 2 groups by the exact stored string, not by individual tag word. A real per-tag breakdown would need a normalized tags table, which is a bigger schema change than this ticket's scope.
- Making the dashboard the root route (the brief says "could" — goals index stays root; a link from there is enough)
- Charts/graphs — simple tables are enough, per the brief
- Any date range picker or filtering — always all-time totals for the signed-in user

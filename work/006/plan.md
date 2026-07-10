# Plan — ticket 006: Convert bookmarks to goal-linked Resources

## Criteria (verbatim)
1. Given a signed-in user's own Goal, When they attach a Resource (title, url, type) via the goal detail page, Then it persists linked to that goal and appears there badged by its type.
2. Given a Resource attachment with a blank title or a non-http(s) url, When submitted, Then it is rejected with a visible error (the same validations Bookmark had).
3. Given a Resource under a Goal owned by a DIFFERENT user, When the signed-in user requests to view (via that goal) or delete it directly, Then they are blocked (404) — the record untouched.
4. Given any signed-in user, When they GET `/`, Then they see their goals index (root moved off the old bookmarks page) with the factory pipeline strip still rendering above it, and the Tailwind stylesheet linked exactly once.

## Steps (largest refactor so far — renames a live model/table/controller/views/routes; each step names exactly what moves, gets deleted, or is new)

### Step 1 → criterion 1 (evolve Bookmark → Resource, attach + display on goal page)
- Test: new `test/controllers/resources_controller_test.rb` — `test "attaches a resource that appears on the goal's page, badged by type"`
- Expected failure: no route/model
- Implementation:
  - Migration `ConvertBookmarksToResources`: delete existing rows (dev/test-only data, no user/goal owner — documented, not silently dropped), `rename_table :bookmarks, :resources`, `add_reference :resources, :goal, null: false, foreign_key: true`, `add_column :resources, :resource_type, :integer, default: 0, null: false` (named `resource_type`, NOT `type` — Rails treats a `type` column as Single Table Inheritance)
  - `app/models/resource.rb` (was `bookmark.rb`): `belongs_to :goal`; `enum :resource_type, { article: 0, video: 1, repo: 2, doc: 3 }`; same title/url validations as Bookmark. Delete `bookmark.rb`.
  - `Goal` gets `has_many :resources, dependent: :destroy`; `User` gets `has_many :resources, through: :goals` (mirrors the `learning_sessions` through-association, needed for step 3)
  - `config/routes.rb`: remove `resources :bookmarks`; add `resources :resources, only: [:create, :destroy], shallow: true` nested under `goals` (alongside `learning_sessions`)
  - `app/controllers/resources_controller.rb` (new, mirrors `learning_sessions_controller.rb`): `create` via `Current.user.goals.find(params[:goal_id])`, `destroy` via `Current.user.resources.find(params[:id])`. Delete `bookmarks_controller.rb`.
  - Delete `app/views/bookmarks/{index,new,edit,_form}.html.erb`. **Move** (not delete) `app/views/bookmarks/_pipeline.html.erb` → `app/views/goals/_pipeline.html.erb` (used in step 4).
  - `GoalsController#show` gets `@resources = @goal.resources.order(created_at: :desc)`; `goals/show.html.erb` gets a "Resources" section (badged by `resource_type`, reusing `.phase-badge`) + inline attach form (same pattern as the learning-session form already there)
  - Delete `test/models/bookmark_test.rb`, replace with `test/models/resource_test.rb` (same two validation tests, adapted to require a `goal:`); delete `test/fixtures/bookmarks.yml` (no fixture replaces it — Resource, like Goal/LearningSession, is built programmatically in tests)
- Commit: `ticket-006: evolve Bookmark into goal-linked Resource`

### Step 2 → criterion 2 (validations carried over)
- Test: `resources_controller_test.rb` — `test "rejects a resource with a blank title or a non-http(s) url"`
- Expected failure: **may already be green** — step 1 explicitly ports Bookmark's validations onto Resource. Document rather than fabricate red if so (same pattern as prior "verify" steps).
- Implementation: none expected beyond the test
- Commit: `ticket-006: verify resource validations carry over from Bookmark`

### Step 3 → criterion 3 (cross-user Resource blocked, both directions)
- Test: `resources_controller_test.rb` — two tests this time, not one: `test "blocks creating a resource under another user's goal with 404"` AND `test "blocks destroying another user's resource with 404"` (ticket 005's review flagged that testing only the destroy direction left a real gap — covering both from the start here)
- Expected failure: **may already be green** — same `Current.user.goals.find` / `Current.user.resources.find` scoping as step 1
- Implementation: none expected beyond the tests
- Commit: `ticket-006: verify cross-user resources return 404 (create and destroy)`

### Step 4 → criterion 4 (root → goals index, pipeline strip moves, dedupe tailwind link)
- Test: move + adapt the layout-level tests out of the (now-deleted) `bookmarks_controller_test.rb` into `goals_controller_test.rb`, replacing "Bookmarks" text checks with "Goals": tailwind stylesheet linked **exactly once** (`assert_select` count — this is what actually catches issue #10's duplicate), pipeline strip renders 5 ordered steps before the goals list, phase badge, Stimulus wiring attributes, anonymous-visitor-redirected-from-root
- Expected failure: root still points at the deleted `bookmarks#index` (routing error) and the tailwind link count is 2, not 1 (issue #10, folded in here since both touch the same layout line)
- Implementation: `config/routes.rb` — `root "goals#index"`; `goals/index.html.erb` — render `"pipeline"` partial at top; `app/views/layouts/application.html.erb` — remove the manual `stylesheet_link_tag "tailwind"` line (Rails 8.1's `stylesheet_link_tag :app` already auto-includes the compiled Tailwind build — confirmed by ticket 002's own review finding; the manual tag was the duplicate)
- Commit: `ticket-006: root moves to goals index, dedupe tailwind link (closes #10)`

## Research notes
- `type` is a reserved ActiveRecord column name (triggers Single Table Inheritance) — the enum column is `resource_type`, not `type`, even though the brief says "type."
- `main.container` and the Tailwind link both live in the shared layout, not per-view — no per-page work needed for the container assertion, only the stylesheet-link count (issue #10's actual bug).
- The `_pipeline.html.erb` partial's own comment says "nothing here affects bookmarks" — true, it was always homepage-agnostic; relocating it to `goals/` is a pure move.
- Existing `bookmarks.yml` fixture (one row, no owner) can't carry over — Resource requires a `goal_id`, and no fixture in this app cross-references another fixture yet (same situation ticket 005 was in for Goal/LearningSession) — built programmatically instead.
- Deleting `bookmarks_controller_test.rb` outright (rather than incrementally trimming it) is deliberate: every behavior it tested either moved (layout-level assertions → step 4) or was superseded (CRUD → step 1's Resource tests, scoped through goals instead of global).

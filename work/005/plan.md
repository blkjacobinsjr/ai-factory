# Plan — ticket 005: Add Goals and LearningSessions CRUD

## Criteria (verbatim)
1. Given a signed-in user, When they create a Goal (title, description, status), Then it persists belonging to them and appears on their own goals index.
2. Given a signed-in user's own Goal, When they edit its title/status or delete it, Then the change persists (or it's removed) and the goals index reflects it.
3. Given a Goal that belongs to a DIFFERENT user, When the signed-in user requests its show/edit/update/delete URL directly, Then they are blocked (404) — the record is untouched.
4. Given a signed-in user's own Goal, When they create a LearningSession under it (date, duration, notes, tags), Then it persists and appears on that goal's detail page.
5. Given a LearningSession under a Goal owned by a DIFFERENT user, When the signed-in user requests its edit/update/delete URL directly, Then they are blocked (404) — the record is untouched.
6. Given a goals index with goals in multiple statuses, When filtered by `?status=<value>`, Then only goals with that status are listed.

## Steps (dependency order — Goal before LearningSession, create before scoping-blocked, before filter)

### Step 1 → criterion 1 (create Goal, scoped index)
- Test: `test/controllers/goals_controller_test.rb` — `test "creates a goal that appears on the signed-in user's index"`
- Expected failure: no route/model
- Implementation: migration `CreateGoals` (`user:references`, `title:string`, `description:text`, `status:integer default:0`); `Goal` model (`belongs_to :user`, `enum :status, { planned: 0, in_progress: 1, done: 2 }` — integer-backed; `?status=in_progress` is the filter's accepted value, snake_case, since Ruby enum keys can't contain the brief's literal hyphen — a display-layer concern, not storage); `validates :title, presence: true`; `User` gets `has_many :goals, dependent: :destroy`; routes `resources :goals`; `GoalsController#index/new/create` (`Current.user.goals...`); views `index`/`new`/`_form` reusing `.card`/`.btn`/`.input`
- Commit: `ticket-005: create Goals scoped to the signed-in user`

### Step 2 → criterion 2 (edit/delete own Goal)
- Test: same file — `test "edits and deletes the signed-in user's own goal"`
- Expected failure: no edit/update/destroy actions
- Implementation: `GoalsController#edit/update/destroy` (all via `Current.user.goals.find`); `edit.html.erb`
- Commit: `ticket-005: edit and delete own goals`

### Step 3 → criterion 3 (cross-user Goal blocked)
- Test: same file — `test "blocks show/edit/destroy of another user's goal with 404"` (goal owned by `users(:two)`, signed in as `users(:one)`, hit show/edit/destroy URLs, `assert_response :not_found` each)
- Expected failure: **may already be green** — `Current.user.goals.find` raises `ActiveRecord::RecordNotFound` for any id outside the association scope, which this app's `show_exceptions = :rescuable` (Rails 7.1+ default) renders as a real 404 even in the test env. Document rather than fabricate a red if so (same pattern as ticket 002's step 2 and ticket 004's step 3).
- Implementation: none expected beyond the test
- Commit: `ticket-005: verify cross-user goals return 404`

### Step 4 → criterion 4 (create LearningSession, shows on goal detail)
- Test: same file (or new `learning_sessions_controller_test.rb`) — `test "creates a learning session that appears on the goal's page"`
- Expected failure: no route/model
- Implementation: migration `CreateLearningSessions` (`goal:references`, `date:date`, `duration:integer` — minutes, `notes:text`, `tags:string`); `LearningSession` model (`belongs_to :goal`); `Goal` gets `has_many :learning_sessions, dependent: :destroy`; `User` gets `has_many :learning_sessions, through: :goals` (mirrors the `Current.user.X.find` scoping pattern for step 5); routes `resources :goals do resources :learning_sessions, only: [:create, :destroy], shallow: true end`; `GoalsController#show` (`@learning_sessions = @goal.learning_sessions.order(date: :desc)`); `LearningSessionsController#create` (`@goal = Current.user.goals.find(params[:goal_id])`); `goals/show.html.erb` (session list + inline add form)
- Commit: `ticket-005: log learning sessions under a goal`

### Step 5 → criterion 5 (cross-user LearningSession destroy blocked)
- Test: `test "blocks destroying another user's learning session with 404"` (session under `users(:two)`'s goal, signed in as `users(:one)`, `DELETE /learning_sessions/:id`, `assert_response :not_found`, record still exists after)
- Expected failure: no `destroy` action yet, or (if step 4 already added it) may be born green via `Current.user.learning_sessions.find` — same as step 3
- Implementation: `LearningSessionsController#destroy` (`Current.user.learning_sessions.find(params[:id]).destroy`) if not already done in step 4
- Commit: `ticket-005: verify cross-user learning sessions return 404`

### Step 6 → criterion 6 (status filter)
- Test: same controller file — `test "filters the goals index by status"` (goals in 2+ statuses, `get goals_path(status: "in_progress")`, only matching titles present)
- Expected failure: filter param ignored, all goals show
- Implementation: `GoalsController#index` — `@goals = @goals.where(status: params[:status]) if params[:status].present?`; index view gets simple filter links (one per status + "all")
- Commit: `ticket-005: filter goals index by status`

## Out-of-scope interpretation (flagging since no human pause this round)
The ticket's out-of-scope note excludes "editing/deleting individual LearningSessions beyond the scoping proof in criterion 5." Read literally, criterion 5 says "edit/update/delete" — implementing only `destroy` (one representative mutating action, no `edit`/`update` actions or views) satisfies the scoping proof while honoring the out-of-scope note; building unused edit/update actions with no UI would be dead code.

## Research notes
- No existing pattern scopes `Bookmark` to users — Goals/LearningSessions establish the first real per-user scoping via `Current.user.goals.find` (already proven safe for `ProfilesController`, just without the `.find(id)` since profile has no id in its route).
- `show_exceptions = :rescuable` (confirmed in `config/environments/test.rb`) means `ActiveRecord::RecordNotFound` renders as a genuine 404 response in tests — `assert_response :not_found` directly, no `assert_raises`.
- Integer-backed enum, not string-backed: avoids the enum's lack of DB-level value enforcement that a string column would need extra validation for; the brief's hyphenated "in-progress" is a display nicety, not a storage requirement.
- `shallow: true` on nested learning_sessions routes keeps `destroy` as `/learning_sessions/:id` — consistent with the ticket 004 profile pattern of "no id that could point at someone else's record" wherever the association makes that possible.
- No fixture precedent exists for cross-referencing `users(:one)` in a new model's fixture — cross-user tests build records programmatically instead (matches how `profile_test.rb`/`profiles_controller_test.rb` already do it), not via new YAML fixtures.

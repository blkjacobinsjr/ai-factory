# Plan — ticket 007: Add AI summary and next-steps for goals

## Criteria (verbatim)
1. Given a signed-in user's own Goal with learning sessions and resources, When they trigger "Generate summary", Then the service sends that context to the AI provider, and the returned summary is persisted on the goal and displayed on its page.
2. Given a signed-in user's own Goal, When they trigger "Suggest next steps", Then 2-3 concrete next steps are generated, persisted, and rendered as a list on the goal page.
3. Given the AI provider call fails (network error or a non-success response), When either action is triggered, Then the user sees a clear error message instead of a crash, and no partial/stale result is saved.
4. Given a Goal owned by a DIFFERENT user, When the signed-in user triggers either action on it directly by URL, Then they are blocked (404) — the goal untouched, no AI call made.

## Steps (dependency order — shared service/plumbing built in step 1, since both actions need identical HTTP/error handling; each step's test is what's new)

### Step 1 → criterion 1 (generate summary)
- Test: new `test/controllers/ai_insights_controller_test.rb` — `test "generates and persists a summary from the goal's sessions and resources"` (stubs `AiInsightService.summarize` — the actual network call is never exercised in the automated suite, per the ticket's own out-of-scope note)
- Expected failure: no route/controller/service
- Implementation:
  - `Gemfile`: `gem "dotenv-rails"` (`:development, :test` group — production would use real ENV, not a checked-in file)
  - `.env` (gitignored, NOT committed — real key already available from another local project, moved here via a single direct pipe, never landing in an intermediate scratch file) + `.env.example` (committed, placeholder only) documenting `OPENAI_API_KEY`
  - Migration: `add_column :goals, :ai_summary, :text` + `add_column :goals, :ai_next_steps, :text`
  - `app/services/ai_insight_service.rb` (new dir, Zeitwerk autoloads `app/*` automatically): `Error` class; `self.summarize(goal)` and `self.next_steps(goal)` (both built now since they share identical request/parse plumbing — building one and not the other would just mean copy-pasting it in step 2); prompts built from `goal.learning_sessions`/`goal.resources`; plain `Net::HTTP` POST to `api.openai.com/v1/chat/completions`; model name via `ENV.fetch("OPENAI_MODEL", "gpt-4o-mini")` (env-overridable in case the default needs correcting once the review's real API call runs); the actual `send_request` network call is isolated in its own method — the one thing tests stub
  - Routes: `resources :goals do member do post :generate_summary; post :suggest_next_steps end end` (routed to a dedicated `AiInsightsController`, matching this app's one-controller-per-concern pattern for Resources/LearningSessions)
  - `app/controllers/ai_insights_controller.rb`: `#generate_summary` only this step (scoped via `Current.user.goals.find`)
  - `goals/show.html.erb`: "Generate summary" button + summary display block
- Commit: `ticket-007: generate AI summary for a goal`

### Step 2 → criterion 2 (suggest next steps)
- Test: `ai_insights_controller_test.rb` — `test "generates and persists 2-3 next steps as a list"` (stub returns `"Step one\nStep two\nStep three"`, asserts 3 `<li>`)
- Expected failure: no `#suggest_next_steps` action/route
- Implementation: `AiInsightsController#suggest_next_steps` (service method already exists from step 1); view gets the button + `<ol>` (split `ai_next_steps` on newline, same plain-string-not-a-model pattern as `focus_areas`/`tags` elsewhere in this app)
- Commit: `ticket-007: suggest next steps for a goal`

### Step 3 → criterion 3 (AI failure handled gracefully)
- Test: two tests — (a) service-level: `test/services/ai_insight_service_test.rb` stubs the raw `send_request` to return a fake non-2xx response, asserts `AiInsightService::Error` is raised; (b) controller-level: stubs `AiInsightService.summarize` to raise that error, POSTs, asserts a flash alert (not a 500) and `goal.ai_summary` unchanged
- Expected failure: unhandled exception (both levels) — nothing currently rescues `AiInsightService::Error`
- Implementation: `AiInsightsController` rescues `AiInsightService::Error` in both actions → `redirect_to @goal, alert: e.message` (no save happens, since the exception is raised before any `@goal.update!` call)
- Commit: `ticket-007: handle AI provider failures without crashing`

### Step 4 → criterion 4 (cross-user goal blocked, no AI call made)
- Test: goal owned by `users(:two)`, signed in as `users(:one)`, POST both actions on it; `assert_response :not_found` both; **and** assert the AI service is never invoked (stub `AiInsightService.summarize`/`.next_steps` to raise loudly if called at all — a call happening would itself fail the test)
- Expected failure: **may already be green** — same `Current.user.goals.find` scoping as every other controller in this app; the "no AI call made" half is what actually needs the stub-that-raises-if-called to prove, since a naive implementation could theoretically look up the goal wrong AND still avoid calling the service by accident
- Implementation: none expected beyond the test
- Commit: `ticket-007: verify cross-user goals block AI actions before any AI call`

## Research notes
- No `dotenv-rails`, no HTTP client gem, no `app/services/` directory yet — all net-new for this ticket; Zeitwerk autoloads `app/services` with zero config the moment the directory exists.
- `goals` table has no AI-related columns yet — two new `text` columns, no new model (same "add columns to Goal" pattern already used for `status`, not a separate `Insight` model, since only the latest summary/next-steps are kept per the ticket's own out-of-scope note).
- No webmock/vcr in this app — matches the ticket's stated fallback: stub `AiInsightService`'s public methods in controller tests, and isolate the one network-touching method (`send_request`) so the service's own tests can stub just that layer instead of the network.
- The real API key is available locally (confirmed with the human) from another project's `.env.local` — moved directly into this repo's own gitignored `.env` in one piped command, never through an intermediate plaintext file; only `.env.example` (no real value) is committed.
- The model name is a guess (`gpt-4o-mini`) since I can't verify current OpenAI model availability with certainty — made `ENV`-overridable specifically so the review's real API call can correct it without a code change if it's stale.

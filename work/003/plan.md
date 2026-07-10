# Plan — ticket 003: Animate factory pipeline on homepage

## Criteria (verbatim)
1. Given GET `/`, Then the homepage renders an element with class `pipeline` containing exactly 5 elements with class `step`, labeled `refine`, `plan`, `implement`, `review`, `merge`, and it appears in the response before the bookmarks list.
2. Given a state file containing `phase=implementing`, When `FactoryState.phase(path)` reads it, Then it returns `"implementing"`; Given the path does not exist, Then it returns `"idle"`.
3. Given GET `/`, Then the pipeline strip contains a badge element with class `phase-badge` whose text is the current phase from `.factory/state`.
4. Given GET `/`, Then the strip carries `data-controller="pipeline"`, each step carries `data-pipeline-target="step"` and a `data-detail` attribute with its one-line description, and the strip contains a replay `button` with `data-action` invoking the controller.

## Steps (dependency order — reader first, then markup, then badge, then JS wiring)

### Step 1 → criterion 2 (FactoryState reader)
- Test: `test/models/factory_state_test.rb` — `test "reads phase from a state file, idle when missing"` (Tempfile with `phase=implementing`; missing-path case)
- Expected failure: `NameError: uninitialized constant FactoryState`
- Implementation: `app/models/factory_state.rb` — PORO, `self.phase(path = Rails.root.join(".factory/state"))`: parse `key=value` lines, return `phase` value, `"idle"` if file missing or key absent
- Commit: `ticket-003: FactoryState reads pipeline phase`

### Step 2 → criterion 1 (strip renders)
- Test: `test/controllers/bookmarks_controller_test.rb` — `test "homepage shows the 5-step pipeline strip above the list"` (`assert_select ".pipeline .step", 5` + step labels + `body.index` comparison for position)
- Expected failure: no `.pipeline` element
- Implementation: `app/views/bookmarks/_pipeline.html.erb` (steps array hardcoded in partial: name + one-line detail), rendered at top of `index.html.erb`; `.pipeline`/`.step` classes in `app/assets/tailwind/application.css`
- Commit: `ticket-003: pipeline strip on homepage`

### Step 3 → criterion 3 (live phase badge)
- Test: same file — `test "pipeline strip shows the current factory phase"` (`assert_select ".pipeline .phase-badge", text: FactoryState.phase`)
- Expected failure: no `.phase-badge` element
- Implementation: badge span in `_pipeline.html.erb` calling `FactoryState.phase`; `.phase-badge` class in CSS
- Commit: `ticket-003: live phase badge`

### Step 4 → criterion 4 (Stimulus animation wiring)
- Test: same file — `test "pipeline strip is wired to the Stimulus controller"` (assert `[data-controller=pipeline]`, 5× `[data-pipeline-target=step]`, 5× `[data-detail]`, `button[data-action*=pipeline]`)
- Expected failure: no `data-controller` attribute
- Implementation: `app/javascript/controllers/pipeline_controller.js` (~60 lines: on connect, step through nodes on an interval adding `is-active`/`is-done` classes, show active step's `data-detail` text, loop after a pause; `replay()` action restarts; interval cleared on disconnect) + data attributes and replay button in `_pipeline.html.erb` + animation CSS (`.step.is-active` pulse ring via CSS keyframes, connector fill via `.is-done`)
- Commit: `ticket-003: Stimulus pipeline animation`

## Re-orientation steps (from review FAIL — work/003/review.md)

### Step 5 → finding F1 (vacuous position assertion; test-only)
- Test change: `bookmarks_controller_test.rb` — anchor the position check on `'class="pipeline"'` (not bare `"pipeline"`, which matches the importmap in `<head>`), and assert the 5 labels appear in pipeline order within the strip
- "Red" proof: temporarily verify the OLD assertion can't fail (documented in review); new assertion must still pass against current (correct) markup
- Commit: `ticket-003: fix vacuous strip-position assertion`

### Step 6 → finding F2 (animation never completes)
- No unit test possible (JS runtime; out of ticket criteria) — verification is the review-phase browser drive (`ANIM: full run completes` + `REPLAY` checks, currently failing)
- Implementation: `pipeline_controller.js` finish branch — before resting, remove `is-active` from all steps, add `is-done` to all, `syncConnectors()`; then caption + rest + loop. Fix stale CSS comment (F4) in the same file pass
- Commit: `ticket-003: animation completes to all-green before looping`

### Step 7 → finding F3 (FactoryState 500s on EISDIR/EACCES)
- Test: `factory_state_test.rb` — `FactoryState.phase(dir_path)` returns `"idle"` (a directory raises EISDIR on read today → red)
- Implementation: rescue `SystemCallError` (parent of all Errno) instead of only `Errno::ENOENT`
- Commit: `ticket-003: FactoryState never crashes the homepage`

## Research notes
- `eagerLoadControllersFrom` + `pin_all_from "app/javascript/controllers"` → `pipeline_controller.js` self-registers as `pipeline`; zero manifest edits.
- Zeitwerk autoloads plain POROs from `app/models/`; `FactoryState` unit test needs no fixtures.
- `.factory/state` is `key=value` lines, tracked, readable at `Rails.root.join(".factory/state")`; only set-state.sh writes it — app code reads only.
- Six Tailwind component classes exist; pipeline adds its own under the same `@layer components`.
- Index view is small; strip goes in as a partial to keep the card structure (pinned by ticket-002 tests) untouched.

## Budget check
JS ~60 + partial ~30 + CSS ~40 + PORO ~15 = ~145 lines, inside the ~150 target from the issue.

GitHub: https://github.com/blkjacobinsjr/ai-factory/issues/8

# Animate factory pipeline on homepage

## Context
Showcase this repo's own process (issue #8): a compact animated strip of the factory pipeline above the bookmarks list, plus a live badge reading the actual phase from `.factory/state`. One Stimulus controller + CSS; no new dependencies; ~150 lines total.

## Acceptance criteria
1. Given GET `/`, Then the homepage renders an element with class `pipeline` containing exactly 5 elements with class `step`, labeled `refine`, `plan`, `implement`, `review`, `merge`, and it appears in the response before the bookmarks list.
2. Given a state file containing `phase=implementing`, When `FactoryState.phase(path)` reads it, Then it returns `"implementing"`; Given the path does not exist, Then it returns `"idle"`.
3. Given GET `/`, Then the pipeline strip contains a badge element with class `phase-badge` whose text is the current phase from `.factory/state`.
4. Given GET `/`, Then the strip carries `data-controller="pipeline"`, each step carries `data-pipeline-target="step"` and a `data-detail` attribute with its one-line description, and the strip contains a replay `button` with `data-action` invoking the controller.

## Out of scope
- Testing the animation's runtime behavior (stepping, pulse, connector fill) — no system tests; motion is verified visually via the review-phase browser drive + screenshots
- Any new gem or npm package, icon libraries, framer-motion port
- Showing the strip on pages other than the homepage; mobile-specific layout
- Realtime push updates (badge reflects state at page load; refresh to update)

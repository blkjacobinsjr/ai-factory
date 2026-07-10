# Review — ticket 003: Animate factory pipeline on homepage

Suite: green (15 tests, 62 assertions). Browser drive: `drive.mjs`, screenshots in `screenshots/` (drive aborted at the completion check — that's finding F2).

## Acceptance criteria

| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | strip, 5 labeled steps, above list | **PARTIAL** | strip + labels PASS (test + `01-c1-strip.png`, drive verified position via pixel coords) — but the *automated test* for "above the list" is vacuous (F1) |
| 2 | FactoryState reads phase / idle fallback | PASS | unit test (Tempfile + missing path) |
| 3 | badge shows live phase | PASS | test + drive saw `reviewing` live (`01-c1-strip.png`) |
| 4 | Stimulus wiring | PASS | test + drive: controller attached, steps animate, caption updates (`03-anim-sequence.png`) |

Animation behavior (out of criteria, in the issue's intent): sequential activation ✓, connector fill ✓, caption ✓, **completion ✗** (F2), replay untested (drive aborted before it).

## Findings

- **F1 (major, code-reviewer)** `bookmarks_controller_test.rb:69` — `response.body.index("pipeline")` matches `controllers/pipeline_controller` in the head importmap (byte 1337) before the real strip (byte 2157). The "before the list" clause is not actually verified. Fix: anchor on `class="pipeline"` and assert label order while there.
- **F2 (major, browser drive)** `pipeline_controller.js` finish branch — stops the timer without marking the last step `is-done`; `merge` pulses forever while the caption says "ticket merged". The strip never reaches its all-green state.
- **F3 (minor, both reviewers)** `factory_state.rb:16` — rescues only `Errno::ENOENT`; `EISDIR`/`EACCES` would 500 the homepage, contradicting the class's own "must not crash" comment.
- **F4 (minor)** stale CSS comment: connector fills when the prior step is *active*, not only when done (JS comment is correct).
- Accepted, no action: badge test compares against `FactoryState.phase` at test time (plan-conformant residual weakness).

Security reviewer: PASS — no unsafe DOM sinks (textContent/classList only), phase value HTML-escaped, data-details are hardcoded literals, no injection paths.

## Verdict round 1 (human): FAIL
F1/F2 majors + F3/F4 minors → plan steps 5–7 → /tdd-implement re-entry.

## Re-review (after fix cycles 5–7)
- **F1 fixed** — position assertion anchored on `class="pipeline"`, labels asserted in order via `css_select`; suite green (16 tests, 54 assertions).
- **F2 fixed** — finish branch marks all steps `is-done`; full drive re-run: **all 14 checks PASS** including `ANIM: full run completes` and `REPLAY: restarts from step 1`. Evidence: `04-anim-complete.png` (all-green strip + completion caption), `05-replay.png`.
- **F3 fixed** — new red→green unit test (EISDIR via directory path); rescue widened to `SystemCallError`.
- **F4 fixed** — stale CSS comment corrected.
- Scope note: no fresh reviewer fan-out for the re-review — the 3-commit delta implements exactly the reviewers' own findings, nothing new entered scope. (Token-frugality call; flag if you want a full re-fan-out.)

## Verdict round 2 (human's call)
Recommendation: **PASS** — all 4 criteria verified by strengthened tests, animation verified end-to-end in the browser including completion and replay.

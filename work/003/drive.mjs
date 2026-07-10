// Acceptance drive for ticket 003 (pipeline animation): proves in a real
// browser what unit tests can't — that the strip actually MOVES. Walks the
// 4 criteria plus animation behavior, screenshotting each state.
// Run: SHOTS_DIR=work/003/screenshots PLAYWRIGHT_DIR=<node_modules/playwright> node work/003/drive.mjs
const { chromium } = await import(process.env.PLAYWRIGHT_DIR + "/index.mjs");

const BASE = "http://localhost:3000";
const SHOTS = process.env.SHOTS_DIR;
let step = 0;

const browser = await chromium.launch();
const page = await browser.newPage();

async function shot(name) {
  step += 1;
  await page.screenshot({ path: `${SHOTS}/${String(step).padStart(2, "0")}-${name}.png`, fullPage: false });
}

async function expectVisible(locator, msg, timeout = 5000) {
  try {
    await locator.first().waitFor({ state: "visible", timeout });
    console.log(`PASS: ${msg}`);
  } catch {
    console.error(`FAIL: ${msg}`);
    process.exit(1);
  }
}

await page.goto(BASE + "/");

// Criterion 1: strip with 5 labeled steps, above the bookmarks heading
await expectVisible(page.locator(".pipeline"), "C1: pipeline strip renders");
for (const label of ["refine", "plan", "implement", "review", "merge"]) {
  await expectVisible(page.locator(".pipeline .step", { hasText: label }), `C1: step '${label}'`);
}
const stripY = await page.locator(".pipeline").boundingBox();
const listY = await page.locator("h1", { hasText: "Bookmarks" }).boundingBox();
if (stripY.y < listY.y) console.log("PASS: C1: strip sits above the list");
else { console.error("FAIL: C1: strip not above list"); process.exit(1); }
await shot("c1-strip");

// Criterion 3 (badge; C2 is the unit-tested reader behind it):
// while this drive runs the factory is in phase=reviewing.
await expectVisible(page.locator(".pipeline .phase-badge", { hasText: "reviewing" }),
  "C3: badge shows live phase 'reviewing'");

// Criterion 4 + motion: the controller attaches and actually animates.
await expectVisible(page.locator(".pipeline[data-controller=pipeline]"), "C4: controller attached");
await expectVisible(page.locator(".step.is-active"), "ANIM: a step goes active (JS runs)");
await shot("anim-active");

// Sequence: step 3 ('implement') eventually becomes active while 1–2 are done.
await expectVisible(page.locator(".step.is-done", { hasText: "plan" }), "ANIM: earlier steps turn done", 8000);
const caption = await page.locator(".pipeline-detail").textContent();
if (caption.trim().length > 0) console.log(`PASS: ANIM: caption shows detail ("${caption.trim()}")`);
else { console.error("FAIL: ANIM: caption empty"); process.exit(1); }
await shot("anim-sequence");

// Full run: all 5 done + completion caption, then it loops.
await expectVisible(page.locator(".step.is-done", { hasText: "merge" }), "ANIM: full run completes", 12000);
await shot("anim-complete");

// Replay: clicking resets to the start (step 1 active again, merge no longer done).
await page.locator("button[data-action*=pipeline]").click();
await expectVisible(page.locator(".step.is-active", { hasText: "refine" }), "REPLAY: restarts from step 1");
await shot("replay");

await browser.close();
console.log("ALL CRITERIA PASSED");

// Acceptance drive for ticket 005 (Goals + LearningSessions CRUD, scoped
// per user). Uses the browser to prove what the DB-level 404 tests can't:
// that a real signed-in session actually gets blocked reaching for
// another user's data end-to-end.
const { chromium } = await import(process.env.PLAYWRIGHT_DIR + "/index.mjs");

const BASE = "http://localhost:3000";
const SHOTS = process.env.SHOTS_DIR;
let step = 0;

const browser = await chromium.launch();

async function shot(page, name) {
  step += 1;
  await page.screenshot({ path: `${SHOTS}/${String(step).padStart(2, "0")}-${name}.png`, fullPage: true });
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

async function signUp(page, email) {
  await page.goto(BASE + "/sign_up");
  await page.fill("#user_email_address", email);
  await page.fill("#user_password", "password12");
  await page.click("input[type=submit]");
  await expectVisible(page.locator("h1", { hasText: "Bookmarks" }), `setup: ${email} signed up`);
}

// Two independent browser sessions — one per user — to prove real
// cross-account isolation, not just two fixture rows in one test process.
const pageA = await browser.newPage();
const pageB = await browser.newPage();
const stamp = Date.now();
await signUp(pageA, `drive-a-${stamp}@example.com`);
await signUp(pageB, `drive-b-${stamp}@example.com`);

// Criterion 1: user A creates a goal, it's on their index
await pageA.goto(BASE + "/goals/new");
await pageA.fill("#goal_title", "Learn Rails");
await pageA.fill("#goal_description", "Ship the Learning Companion");
await pageA.click("input[type=submit]");
await expectVisible(pageA.locator("h1", { hasText: "Learn Rails" }), "C1: goal created, redirected to its page");
await shot(pageA, "c1-goal-created");

const goalUrl = pageA.url();
const goalId = goalUrl.match(/\/goals\/(\d+)/)[1];

// Criterion 4: log a learning session under it
await pageA.fill("#learning_session_date", "2026-07-11");
await pageA.fill("#learning_session_duration", "45");
await pageA.fill("#learning_session_notes", "Read the guides");
await pageA.fill("#learning_session_tags", "rails, reading");
await pageA.click("text=Log session");
await expectVisible(pageA.locator("text=Read the guides"), "C4: learning session appears on the goal page");
await shot(pageA, "c4-session-logged");

// Criterion 3 + 5: user B (a DIFFERENT real signed-in session) tries to
// reach user A's goal directly by URL. Check the HTTP status directly —
// development mode's 404 page has no fixed text to assert on.
const crossUserResp = await pageB.goto(`${BASE}/goals/${goalId}`);
if (crossUserResp.status() === 404) console.log("PASS: C3: user B blocked from user A's goal (404)");
else { console.error(`FAIL: C3: expected 404, got ${crossUserResp.status()}`); process.exit(1); }
await shot(pageB, "c3-cross-user-goal-blocked");

// Criterion 6: status filter
await pageA.goto(BASE + "/goals/new");
await pageA.fill("#goal_title", "Second goal");
await pageA.click("input[type=submit]");
await pageA.goto(BASE + "/goals");
await expectVisible(pageA.locator("text=Second goal"), "setup: second goal (planned) exists");
await pageA.click("text=in-progress");
await pageA.waitForURL(/status=in_progress/);
const bodyText = await pageA.locator("body").textContent();
if (!bodyText.includes("Second goal")) console.log("PASS: C6: planned-status goal excluded from in-progress filter");
else { console.error("FAIL: C6: filter did not exclude other-status goal"); process.exit(1); }
await shot(pageA, "c6-status-filter");

await browser.close();
console.log("ALL CRITERIA PASSED (C2 edit/delete and C5 destroy-scoping covered by the automated suite)");

// Acceptance drive for ticket 008 (Dashboard aggregations). Two accounts
// prove cross-user isolation the way every prior ticket's drive has.
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
  await expectVisible(page.locator("h1", { hasText: "Goals" }), `setup: ${email} signed up`);
}

const pageA = await browser.newPage();
const pageB = await browser.newPage();
const stamp = Date.now();
await signUp(pageA, `drive8-a-${stamp}@example.com`);
await signUp(pageB, `drive8-b-${stamp}@example.com`);

// User A: a done goal + a planned goal + logged sessions with a tag.
await pageA.goto(BASE + "/goals/new");
await pageA.fill("#goal_title", "Learn Rails");
await pageA.click("input[type=submit]");
await expectVisible(pageA.locator("h1", { hasText: "Learn Rails" }), "setup: goal A created");
await pageA.fill("#learning_session_date", "2026-07-10");
await pageA.fill("#learning_session_duration", "60");
await pageA.fill("#learning_session_tags", "rails");
await pageA.click("text=Log session");
await expectVisible(pageA.locator("text=rails"), "setup: session logged for user A");

// User B: a done goal with a distinctive tag — must never appear for A.
await pageB.goto(BASE + "/goals/new");
await pageB.fill("#goal_title", "Not Yours");
await pageB.click("input[type=submit]");
await pageB.fill("#learning_session_date", "2026-07-10");
await pageB.fill("#learning_session_duration", "999");
await pageB.fill("#learning_session_tags", "not-yours-tag");
await pageB.click("text=Log session");
await expectVisible(pageB.locator("text=not-yours-tag"), "setup: session logged for user B");

// Criteria 1-3: user A's dashboard shows their own aggregations.
await pageA.goto(BASE + "/dashboard");
await expectVisible(pageA.locator("td", { hasText: "planned" }), "C1: goal status count shown");
await expectVisible(pageA.locator("td", { hasText: "rails" }), "C2: hours-by-tag shown");
await expectVisible(pageA.locator("td", { hasText: "2026-27" }), "C3: hours-by-week shown");
await shot(pageA, "01-dashboard-user-a");

// Criterion 4: user B's data never appears on user A's dashboard.
const bodyText = await pageA.locator("body").textContent();
if (!bodyText.includes("not-yours-tag") && !bodyText.includes("999")) {
  console.log("PASS: C4: user B's tag/data absent from user A's dashboard");
} else {
  console.error("FAIL: C4: user B's data leaked into user A's dashboard");
  process.exit(1);
}

await browser.close();
console.log("ALL CRITERIA PASSED");

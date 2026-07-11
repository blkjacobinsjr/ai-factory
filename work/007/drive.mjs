// Acceptance drive for ticket 007 (AI summary + next steps). Unlike every
// prior ticket's drive, this one exercises the REAL OpenAI API — the one
// thing the stubbed test suite deliberately never does (see the ticket's
// own out-of-scope note). This is the actual proof the integration works
// end-to-end with a live key, not just that our code calls a mock correctly.
const { chromium } = await import(process.env.PLAYWRIGHT_DIR + "/index.mjs");

const BASE = "http://localhost:3000";
const SHOTS = process.env.SHOTS_DIR;
let step = 0;

const browser = await chromium.launch();
const page = await browser.newPage();

async function shot(name) {
  step += 1;
  await page.screenshot({ path: `${SHOTS}/${String(step).padStart(2, "0")}-${name}.png`, fullPage: true });
}

async function expectVisible(locator, msg, timeout = 20000) {
  try {
    await locator.first().waitFor({ state: "visible", timeout });
    console.log(`PASS: ${msg}`);
  } catch (e) {
    console.error(`FAIL: ${msg} (${e.message.split("\n")[0]})`);
    process.exit(1);
  }
}

const email = `drive7-${Date.now()}@example.com`;
await page.goto(BASE + "/sign_up");
await page.fill("#user_email_address", email);
await page.fill("#user_password", "password12");
await page.click("input[type=submit]");
await expectVisible(page.locator("h1", { hasText: "Goals" }), "setup: signed up");

await page.goto(BASE + "/goals/new");
await page.fill("#goal_title", "Learn Ruby on Rails");
await page.fill("#goal_description", "Get comfortable building and testing a real Rails app.");
await page.click("input[type=submit]");
await expectVisible(page.locator("h1", { hasText: "Learn Ruby on Rails" }), "setup: goal created");

// Give the AI real context to summarize, not an empty goal.
await page.fill("#learning_session_date", "2026-07-10");
await page.fill("#learning_session_duration", "60");
await page.fill("#learning_session_notes", "Set up authentication and built the Goals CRUD with scoping.");
await page.fill("#learning_session_tags", "rails, auth, crud");
await page.click("text=Log session");
await expectVisible(page.locator("text=Set up authentication"), "setup: learning session logged");

await page.fill("#resource_title", "Rails Guides");
await page.fill("#resource_url", "https://guides.rubyonrails.org");
await page.click("text=Attach resource");
await expectVisible(page.locator(".phase-badge", { hasText: "article" }), "setup: resource attached");
await shot("00-goal-with-context");

// Criterion 1: REAL call to OpenAI, real summary persisted and displayed.
await page.click("text=Generate summary");
await expectVisible(page.locator(".card", { hasText: "Summary" }), "C1: real AI summary appears on the goal page");
const summaryText = await page.locator(".card", { hasText: "Summary" }).textContent();
console.log(`  summary text: "${summaryText.replace(/\s+/g, " ").trim()}"`);
await shot("01-real-summary");

// Criterion 2: REAL call for next steps, rendered as a list.
await page.click("text=Suggest next steps");
await expectVisible(page.locator(".ai-next-steps li"), "C2: real AI next-steps rendered as a list");
const stepCount = await page.locator(".ai-next-steps li").count();
console.log(`  next steps count: ${stepCount}`);
if (stepCount < 1) { console.error("FAIL: C2: no next steps rendered"); process.exit(1); }
await shot("02-real-next-steps");

await browser.close();
console.log("ALL CRITERIA PASSED (real API calls, not stubs — C3/C4 failure-handling and scoping covered by the automated suite)");

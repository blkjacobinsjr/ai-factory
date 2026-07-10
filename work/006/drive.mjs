// Acceptance drive for ticket 006 (Bookmark → Resource conversion, root
// move, tailwind dedupe). Two real signed-in accounts prove cross-user
// isolation the same way ticket 005's drive did.
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
  await expectVisible(page.locator("h1", { hasText: "Goals" }), `setup: ${email} signed up, lands on Goals homepage`);
}

const pageA = await browser.newPage();
const pageB = await browser.newPage();
const stamp = Date.now();
await signUp(pageA, `drive6-a-${stamp}@example.com`);
await signUp(pageB, `drive6-b-${stamp}@example.com`);
await shot(pageA, "00-homepage-is-goals");

// Criterion 4 (partial, rest verified by suite): tailwind linked once
const tailwindLinks = await pageA.locator('link[rel=stylesheet][href*="tailwind"]').count();
if (tailwindLinks === 1) console.log("PASS: C4: tailwind stylesheet linked exactly once");
else { console.error(`FAIL: C4: expected 1 tailwind link, found ${tailwindLinks}`); process.exit(1); }

// Create a goal to attach a resource to
await pageA.goto(BASE + "/goals/new");
await pageA.fill("#goal_title", "Learn Rails");
await pageA.click("input[type=submit]");
await expectVisible(pageA.locator("h1", { hasText: "Learn Rails" }), "setup: goal created");
const goalId = pageA.url().match(/\/goals\/(\d+)/)[1];

// Criterion 1: attach a resource, appears badged by type
await pageA.fill("#resource_title", "Rails Guides");
await pageA.fill("#resource_url", "https://guides.rubyonrails.org");
await pageA.selectOption("#resource_resource_type", "doc");
await pageA.click("text=Attach resource");
await expectVisible(pageA.locator("text=Rails Guides"), "C1: resource appears on the goal page");
await expectVisible(pageA.locator(".phase-badge", { hasText: "doc" }), "C1: resource badged by type");
await shot(pageA, "01-resource-attached");

// Criterion 2: invalid resource rejected with a visible error
await pageA.fill("#resource_title", "");
await pageA.fill("#resource_url", "not-a-url");
await pageA.click("text=Attach resource");
await expectVisible(pageA.locator(".form-errors li"), "C2: invalid resource shows a visible error");
await shot(pageA, "02-invalid-resource-error");

// Criterion 3: user B cannot view user A's goal (and therefore its resources)
const crossUserResp = await pageB.goto(`${BASE}/goals/${goalId}`);
if (crossUserResp.status() === 404) console.log("PASS: C3: user B blocked from user A's goal/resources (404)");
else { console.error(`FAIL: C3: expected 404, got ${crossUserResp.status()}`); process.exit(1); }
await shot(pageB, "03-cross-user-blocked");

await browser.close();
console.log("ALL CRITERIA PASSED");

// Acceptance drive for ticket 001: walks all six criteria in a real
// headless Chromium against the dev server (localhost:3000),
// screenshotting each. Exits non-zero on the first failed expectation.
// Run: SHOTS_DIR=work/001/screenshots PLAYWRIGHT_DIR=<node_modules/playwright> node work/001/drive.mjs
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

// Turbo swaps the page asynchronously after each submit, so every check
// must WAIT for the expected element rather than assert instantly —
// instant counts race the render and fail even when the app is correct.
async function expectVisible(locator, msg) {
  try {
    await locator.first().waitFor({ state: "visible", timeout: 5000 });
    console.log(`PASS: ${msg}`);
  } catch {
    console.error(`FAIL: ${msg}`);
    process.exit(1);
  }
}

async function expectGone(locator, msg) {
  try {
    await locator.first().waitFor({ state: "detached", timeout: 5000 });
    console.log(`PASS: ${msg}`);
  } catch {
    console.error(`FAIL: ${msg}`);
    process.exit(1);
  }
}

// Criterion 1: GET / renders the bookmarks index
await page.goto(BASE + "/");
await expectVisible(page.locator("h1", { hasText: "Bookmarks" }), "C1: / renders the bookmarks index");
await shot("c1-homepage");

// Criterion 3 (through the real form): blank title rejected with an error on title
await page.click("text=New bookmark");
await page.fill("#bookmark_url", "https://example.com");
await page.click("input[type=submit]");
await expectVisible(page.locator("li", { hasText: "Title can't be blank" }), "C3: blank title shows title error");
await shot("c3-blank-title-error");

// Criterion 4: non-http(s) url rejected with an error on url
await page.fill("#bookmark_title", "Broken");
await page.fill("#bookmark_url", "not-a-url");
await page.click("input[type=submit]");
await expectVisible(page.locator("li", { hasText: "Url must start with http:// or https://" }), "C4: bad url shows url error");
await shot("c4-bad-url-error");

// Criterion 2: valid create persists and appears on the index
await page.fill("#bookmark_title", "Acceptance Drive");
await page.fill("#bookmark_url", "https://example.com");
await page.click("input[type=submit]");
await page.waitForURL(BASE + "/");
await expectVisible(page.locator("a", { hasText: "Acceptance Drive" }), "C2: created bookmark appears on index");
await shot("c2-created-on-index");

// Criterion 5: edit updates the title
await page.locator("li", { hasText: "Acceptance Drive" }).locator("text=Edit").click();
await page.fill("#bookmark_title", "Acceptance Drive (edited)");
await page.click("input[type=submit]");
await page.waitForURL(BASE + "/");
await expectVisible(page.locator("a", { hasText: "Acceptance Drive (edited)" }), "C5: edited title shows on index");
await shot("c5-updated-on-index");

// Criterion 6: delete removes it from the index
page.on("dialog", d => d.accept()); // turbo_confirm "Are you sure?"
await page.locator("li", { hasText: "Acceptance Drive (edited)" }).locator("text=Delete").click();
await expectGone(page.locator("a", { hasText: "Acceptance Drive" }), "C6: deleted bookmark gone from index");
await shot("c6-deleted");

await browser.close();
console.log("ALL CRITERIA PASSED");

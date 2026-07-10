// Acceptance drive for ticket 002 (Tailwind styling): walks all five
// criteria in headless Chromium against localhost:3000, screenshotting each.
// Run: SHOTS_DIR=work/002/screenshots PLAYWRIGHT_DIR=<node_modules/playwright> node work/002/drive.mjs
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

// Turbo swaps pages async — assertions must wait, never instant-count.
async function expectVisible(locator, msg) {
  try {
    await locator.first().waitFor({ state: "visible", timeout: 5000 });
    console.log(`PASS: ${msg}`);
  } catch {
    console.error(`FAIL: ${msg}`);
    process.exit(1);
  }
}

// Criterion 1: Tailwind stylesheet linked AND actually loads (HTTP 200)
await page.goto(BASE + "/");
// .first(): the link currently appears twice (:app auto-include + manual tag)
// — recorded as a review finding; one loading copy is what C1 requires.
const href = await page.locator('link[rel="stylesheet"][href*="tailwind"]').first().getAttribute("href");
const cssStatus = href ? (await page.request.get(BASE + href)).status() : 0;
if (href && cssStatus === 200) console.log("PASS: C1: tailwind stylesheet linked and loads (200)");
else { console.error(`FAIL: C1: href=${href} status=${cssStatus}`); process.exit(1); }
await shot("c1-tailwind-linked");

// Setup: the dev DB may be empty (ticket 001's drive cleans up after
// itself), and C2/C3 need a bookmark to exist. Create one through the
// real form — which doubles as evidence the styled form still works.
await page.goto(BASE + "/bookmarks/new");
await page.fill("#bookmark_title", "Styled Bookmark");
await page.fill("#bookmark_url", "https://example.com");
await page.click("input[type=submit]");
await expectVisible(page.locator("a", { hasText: "Styled Bookmark" }), "setup: bookmark created");

// Criterion 2: main.container wraps content on all three pages
for (const path of ["/", "/bookmarks/new", null]) {
  if (path) await page.goto(BASE + path);
  else { await page.goto(BASE + "/"); await page.locator(".card >> text=Edit").first().click(); }
  await expectVisible(page.locator("main.container"), `C2: main.container on ${path ?? "edit page"}`);
}
await shot("c2-container-edit-page");

// Criterion 3: each bookmark is a .card containing link + Edit + Delete
await page.goto(BASE + "/");
await expectVisible(page.locator(".card").first(), "C3: cards render on index");
await expectVisible(page.locator(".card a", { hasText: "Edit" }).first(), "C3: Edit inside card");
await expectVisible(page.locator(".card button[type=submit]", { hasText: "Delete" }).first(), "C3: Delete inside card");
await shot("c3-cards");

// Criterion 4: form components on /bookmarks/new
await page.goto(BASE + "/bookmarks/new");
await expectVisible(page.locator("input.input#bookmark_title"), "C4: title input styled");
await expectVisible(page.locator("input.input#bookmark_url"), "C4: url input styled");
await expectVisible(page.locator("label.label").first(), "C4: labels styled");
await expectVisible(page.locator("input.btn[type=submit]"), "C4: submit styled");
await shot("c4-form");

// Criterion 5: blank-title submit shows the red .form-errors box
await page.fill("#bookmark_url", "https://example.com");
await page.click("input[type=submit]");
await expectVisible(page.locator(".form-errors li"), "C5: errors render inside .form-errors");
await shot("c5-form-errors");

// Teardown: leave the dev DB as we found it.
await page.goto(BASE + "/");
page.on("dialog", d => d.accept());
await page.locator(".card", { hasText: "Styled Bookmark" }).locator("button[type=submit]").click();
await page.locator("a", { hasText: "Styled Bookmark" }).first().waitFor({ state: "detached", timeout: 5000 });
console.log("teardown: bookmark deleted");

await browser.close();
console.log("ALL CRITERIA PASSED");

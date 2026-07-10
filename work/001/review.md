# Review — ticket 001: Add bookmark CRUD with URL validation

Suite: green (6 tests, 17 assertions, 0 failures). Browser drive: headless Chromium against localhost:3000 via `drive.mjs` (Playwright MCP tools weren't connected this session; same walk, scripted). Screenshots in `screenshots/`.

## Acceptance criteria

| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | GET `/` renders bookmarks index | PASS | test + `01-c1-homepage.png` |
| 2 | Valid POST persists, appears on index | PASS | test + `04-c2-created-on-index.png` |
| 3 | Blank title → invalid, error on title | PASS | model test + real form: `02-c3-blank-title-error.png` ("Title can't be blank") |
| 4 | Non-http(s) url → invalid, error on url | PASS | model test + real form: `03-c4-bad-url-error.png` |
| 5 | PATCH updates title | PASS | test + `05-c5-updated-on-index.png` |
| 6 | DELETE removes from index | PASS | test + `06-c6-deleted.png` (confirm dialog accepted, row gone) |

## Reviewer findings (both recommend PASS; no blockers/majors)

Code reviewer:
- `config/routes.rb:14` — `resources :bookmarks` exposes a `show` route with no action → 404 on GET /bookmarks/:id. Plan specified `resources`, so inherited; `except: :show` would match the surface. — minor
- `app/models/bookmark.rb:15` — url regex accepts junk like `https:// ` (any char after scheme). Meets the criterion as written; loose boundary. — minor
- `bookmarks_controller.rb:9` — newest-first ordering not in ticket (harmless one-liner). — minor
- Index test asserts only 200; content covered by criterion 2's test. — minor
- Conformance: 6 commits map 1:1 to plan steps; criteria verbatim; teaching comments present throughout.

Security reviewer:
- No XSS (all output escaped, no `raw`/`html_safe`), strong params block mass assignment, CSRF defaults intact, no SQL interpolation.
- URL regex uses `\A`/`\z` — no newline/multiline bypass; `javascript:`/`data:` schemes blocked.
- `bookmark.rb:14` — regex is case-sensitive: legitimate `HTTPS://…` is rejected (fails closed, usability only). — minor
- No auth on CRUD — informational; single-user app, auth explicitly out of scope.

## Verdict (human's call)
Recommendation: **PASS** — all 6 criteria verified twice (automated tests + real browser); findings are minor and none violate a criterion. Minors are candidates for a future ticket, not rework.

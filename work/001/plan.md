# Plan — ticket 001: Add bookmark CRUD with URL validation

## Criteria (verbatim)
1. Given any visitor, When they GET `/`, Then the bookmarks index page renders successfully.
2. Given valid params (title present, url `https://example.com`), When POST `/bookmarks`, Then a Bookmark is persisted and appears on the index.
3. Given params with a blank title, When creating a Bookmark, Then the record is invalid with an error on `title`.
4. Given params with a url that is not valid http/https (e.g. `not-a-url`), When creating a Bookmark, Then the record is invalid with an error on `url`.
5. Given an existing bookmark, When PATCH `/bookmarks/:id` with a new title, Then the change is persisted.
6. Given an existing bookmark, When DELETE `/bookmarks/:id`, Then it is removed and no longer appears on the index.

## Steps (dependency order — model before controller)

### Step 1 → criterion 3 (title presence)
- Test: `test/models/bookmark_test.rb` — `test "is invalid with a blank title"`
- Expected failure: `NameError: uninitialized constant Bookmark` (model doesn't exist)
- Implementation: migration `CreateBookmarks` (`title:string`, `url:string`, timestamps); `app/models/bookmark.rb` with `validates :title, presence: true`; fixture `test/fixtures/bookmarks.yml` (one valid bookmark, used by later steps)
- Commit: `ticket-001: Bookmark model requires title`

### Step 2 → criterion 4 (url format)
- Test: `test/models/bookmark_test.rb` — `test "is invalid when url is not http or https"` (url = `not-a-url`)
- Expected failure: assertion fails — record is valid (no url validation yet)
- Implementation: add `validates :url, presence: true, format: %r{\Ahttps?://.+\z}` to `app/models/bookmark.rb`
- Commit: `ticket-001: Bookmark validates url is http(s)`

### Step 3 → criterion 1 (homepage = index)
- Test: `test/controllers/bookmarks_controller_test.rb` — `test "GET / renders the bookmarks index"`
- Expected failure: `ActionController::RoutingError` (no root route)
- Implementation: `config/routes.rb` → `root "bookmarks#index"` + `resources :bookmarks`; `app/controllers/bookmarks_controller.rb#index`; `app/views/bookmarks/index.html.erb` listing all bookmarks
- Commit: `ticket-001: bookmarks index is the homepage`

### Step 4 → criterion 2 (create)
- Test: same controller test file — `test "POST /bookmarks persists a bookmark that appears on the index"`
- Expected failure: `AbstractController::ActionNotFound` / 404 (no `create` action)
- Implementation: `new` + `create` actions with strong params; `app/views/bookmarks/new.html.erb` form; redirect to root on success, re-render form on invalid
- Commit: `ticket-001: create bookmarks`

### Step 5 → criterion 5 (update)
- Test: same file — `test "PATCH /bookmarks/:id updates the title"` (uses fixture)
- Expected failure: no `update` action
- Implementation: `edit` + `update` actions; `app/views/bookmarks/edit.html.erb` (shared `_form` partial with new)
- Commit: `ticket-001: update bookmarks`

### Step 6 → criterion 6 (delete)
- Test: same file — `test "DELETE /bookmarks/:id removes the bookmark"` (uses fixture, asserts index no longer shows it)
- Expected failure: no `destroy` action
- Implementation: `destroy` action; delete button on index
- Commit: `ticket-001: delete bookmarks`

## Research notes
- App is a bare Rails 8.1.3 skeleton: schema version 0, no `db/migrate/`, no domain models/controllers/views — everything is greenfield.
- Minitest with `fixtures :all` + parallel workers; no fixtures exist yet, so `bookmarks.yml` created in step 1 serves steps 5–6.
- `config/routes.rb` has no active root; sqlite3 in all envs; Hotwire/importmap present but plain ERB + redirects suffice — no JS needed.
- Controller tests as `ActionDispatch::IntegrationTest` in `test/controllers/` per Rails convention.

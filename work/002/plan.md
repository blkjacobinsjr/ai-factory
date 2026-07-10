# Plan — ticket 002: Style bookmark pages with Tailwind

## Criteria (verbatim)
1. Given the application layout, When GET `/`, Then the response links a Tailwind stylesheet (`link[rel=stylesheet]` with href containing "tailwind").
2. Given any bookmark page (`/`, `/bookmarks/new`, edit), When rendered, Then its content sits inside the layout's `main.container` element.
3. Given a saved bookmark, When GET `/`, Then it renders inside an element with class `card` that contains the title link, an Edit link, and a Delete button.
4. Given GET `/bookmarks/new`, Then the title and url inputs carry class `input`, their labels carry class `label`, and the submit button carries class `btn`.
5. Given a POST with a blank title, When the form re-renders, Then the validation messages appear inside an element with class `form-errors`.

## Steps (dependency order — install first, layout second, then per-view)

### Step 1 → criterion 1 (Tailwind installed + linked)
- Test: `test/controllers/bookmarks_controller_test.rb` — `test "GET / links the tailwind stylesheet"` (`assert_select "link[rel=stylesheet][href*=?]", "tailwind"`)
- Expected failure: no matching link tag
- Implementation: `bundle add tailwindcss-rails` → `bin/rails tailwindcss:install` (generates `app/assets/tailwind/application.css`, `Procfile.dev`, rewrites `bin/dev`, adds `stylesheet_link_tag "tailwind"` to layout) → `bin/rails tailwindcss:build`
- Commit: `ticket-002: install Tailwind, link stylesheet`

### Step 2 → criterion 2 (centered container)
- Test: same file — `test "bookmark pages wrap content in a centered container"` (GET `/`, `/bookmarks/new`, edit of fixture; `assert_select "main.container"` on each)
- Expected failure: no `main` element (layout body is bare `yield`)
- Implementation: layout wraps `yield` in `<main class="container mx-auto max-w-2xl px-4 py-8">`
- Commit: `ticket-002: centered layout container`

### Step 3 → criterion 3 (bookmark cards)
- Test: same file — `test "index renders each bookmark as a card with actions"` (`assert_select ".card"` containing title link, Edit link, Delete submit)
- Expected failure: no `.card` elements
- Implementation: restyle `index.html.erb` (card markup, header row with `btn`-styled New link); define `.card` (+ `.btn` shell) in `@layer components` of `app/assets/tailwind/application.css`
- Commit: `ticket-002: bookmark cards on index`

### Step 4 → criterion 4 (form components)
- Test: same file — `test "new form uses styled input, label and button components"` (`assert_select "input.input#bookmark_title"`, `"input.input#bookmark_url"`, `"label.label"` ×2, `"input.btn[type=submit]"`)
- Expected failure: fields carry no classes
- Implementation: add classes in `_form.html.erb`; define `.input`, `.label`, finalize `.btn` in `@layer components`; light card wrapper on new/edit pages
- Commit: `ticket-002: styled form components`

### Step 5 → criterion 5 (visible error state)
- Test: same file — `test "validation errors render inside form-errors"` (POST blank title, `assert_select ".form-errors li"`)
- Expected failure: error `<ul>` has no class
- Implementation: `_form.html.erb` error block gets `form-errors` class; define `.form-errors` (red border/text) in `@layer components`
- Commit: `ticket-002: styled validation errors`

## Research notes
- tailwindcss-rails v4 is CSS-first: `@import "tailwindcss"` + `@layer components { .btn { @apply … } }` all in `app/assets/tailwind/application.css`; no Node (standalone binary via tailwindcss-ruby).
- Installer rewrites `bin/dev` (Foreman + `tailwindcss:watch`) and adds `Procfile.dev` — expected diff noise, not scope creep.
- Gem hooks `tailwindcss:build` into `test:prepare`, so `bin/rails test` self-builds; propshaft raises on missing build only if the layout renders — model tests unaffected.
- `assert_select` available (rails-dom-testing 2.3 via actionpack); current tests use only `assert_match`, so class-hook assertions are all new.
- Views are tiny (index 21 lines, _form 26); restyling is class additions, not restructuring — existing 6 tests keep passing.

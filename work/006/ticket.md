GitHub: https://github.com/blkjacobinsjr/ai-factory/issues/15

# Convert bookmarks to goal-linked Resources

## Context
Brief feature 4 (issue #15). Evolves the existing global Bookmark into a Resource that belongs to a Goal (title/url validations kept), attached from the goal detail page. Root moves from the bookmarks index to the goals index (folds in issue #10's duplicate-stylesheet fix along the way, since both touch the layout/root).

## Acceptance criteria
1. Given a signed-in user's own Goal, When they attach a Resource (title, url, type) via the goal detail page, Then it persists linked to that goal and appears there badged by its type.
2. Given a Resource attachment with a blank title or a non-http(s) url, When submitted, Then it is rejected with a visible error (the same validations Bookmark had).
3. Given a Resource under a Goal owned by a DIFFERENT user, When the signed-in user requests to view (via that goal) or delete it directly, Then they are blocked (404) — the record untouched.
4. Given any signed-in user, When they GET `/`, Then they see their goals index (root moved off the old bookmarks page) with the factory pipeline strip still rendering above it, and the Tailwind stylesheet linked exactly once.

## Out of scope
- A dedicated resources index/show page (resources are only ever viewed in the context of their goal)
- Editing an existing resource (create + delete only, same as LearningSession)
- Migrating/preserving any existing Bookmark rows — they belong to no user/goal and are dev/test-only data; the conversion migration removes them

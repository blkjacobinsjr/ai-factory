GitHub: https://github.com/blkjacobinsjr/ai-factory/issues/14

# Add Goals and LearningSessions CRUD

## Context
Brief feature 3 (issue #14). Core domain: a Goal belongs to a User; a LearningSession belongs to a Goal. Full CRUD on both, strictly scoped so one user never sees another's data.

## Acceptance criteria
1. Given a signed-in user, When they create a Goal (title, description, status), Then it persists belonging to them and appears on their own goals index.
2. Given a signed-in user's own Goal, When they edit its title/status or delete it, Then the change persists (or it's removed) and the goals index reflects it.
3. Given a Goal that belongs to a DIFFERENT user, When the signed-in user requests its show/edit/update/delete URL directly, Then they are blocked (404) — the record is untouched.
4. Given a signed-in user's own Goal, When they create a LearningSession under it (date, duration, notes, tags), Then it persists and appears on that goal's detail page.
5. Given a LearningSession under a Goal owned by a DIFFERENT user, When the signed-in user requests its edit/update/delete URL directly, Then they are blocked (404) — the record is untouched.
6. Given a goals index with goals in multiple statuses, When filtered by `?status=<value>`, Then only goals with that status are listed.

## Out of scope
- Editing/deleting individual LearningSessions beyond the scoping proof in criterion 5 (create + read is the main path; full session edit UI can follow if needed)
- Tags as a separate model (LearningSession.tags is a plain string field, same pattern as Profile.focus_areas)
- Sorting, pagination, search
- Resource attachments (ticket #15) and AI features (ticket #16)

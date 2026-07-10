GitHub: https://github.com/blkjacobinsjr/ai-factory/issues/5

# Add bookmark CRUD with URL validation

## Context
First real feature of the factory: manage bookmarks (title + url). The bookmarks list doubles as the app homepage.

## Acceptance criteria
1. Given any visitor, When they GET `/`, Then the bookmarks index page renders successfully.
2. Given valid params (title present, url `https://example.com`), When POST `/bookmarks`, Then a Bookmark is persisted and appears on the index.
3. Given params with a blank title, When creating a Bookmark, Then the record is invalid with an error on `title`.
4. Given params with a url that is not valid http/https (e.g. `not-a-url`), When creating a Bookmark, Then the record is invalid with an error on `url`.
5. Given an existing bookmark, When PATCH `/bookmarks/:id` with a new title, Then the change is persisted.
6. Given an existing bookmark, When DELETE `/bookmarks/:id`, Then it is removed and no longer appears on the index.

## Out of scope
- Authentication / per-user bookmarks
- Tags, search, sorting, pagination
- Checking that the URL is actually reachable (format validation only)
- Any styling beyond default scaffold-level markup

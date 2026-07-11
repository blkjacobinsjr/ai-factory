GitHub: https://github.com/blkjacobinsjr/ai-factory/issues/18

# Verify Docker build/run and refresh CLAUDE.md

## Context
Brief feature 7 remainder (issue #18). CI already runs tests on push (confirmed: default `rails new` GitHub Actions workflow). The `Dockerfile` exists from `rails new` but has never actually been built or run. This ticket is verification + documentation, not new app features — no Ruby/JS source changes are expected unless the Docker verification uncovers a real problem.

## Acceptance criteria
1. Given the existing `Dockerfile`, When `docker build` runs, Then it completes successfully and produces a runnable image (evidence: build log, no manual code changes needed unless it fails).
2. Given that built image, When run with the required environment (`RAILS_MASTER_KEY` from `config/master.key`) mapped to a local port, Then `GET /up` (Rails' built-in health check) returns HTTP 200 from inside the container.
3. Given the current state of `CLAUDE.md`, When it's read, Then it accurately documents: the Tailwind build/watch commands, `bin/dev` (foreman), and how to pick up the next factory ticket (`/next-ticket`) — reflecting everything added since it was last written (auth, Tailwind, AI service, dashboard).

## Out of scope
- Docker Compose / production deployment (that's issue #11, separate)
- Any change to the Dockerfile beyond what's needed to make criterion 1/2 actually pass
- CI workflow changes (already confirmed working, not part of this ticket)

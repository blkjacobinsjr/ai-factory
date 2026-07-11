# Plan — ticket 009: Verify Docker build/run and refresh CLAUDE.md

## Criteria (verbatim)
1. Given the existing `Dockerfile`, When `docker build` runs, Then it completes successfully and produces a runnable image.
2. Given that built image, When run with the required environment mapped to a local port, Then `GET /up` returns HTTP 200 from inside the container.
3. Given the current state of `CLAUDE.md`, When it's read, Then it accurately documents Tailwind build, `bin/dev`, and `/next-ticket`.

## Steps (verification-driven, not TDD red/green — no Ruby/JS source expected unless something's actually broken)

### Step 1 → criterion 1 (docker build)
- Action: `docker build -t ai-factory .` using the existing Dockerfile; capture the log
- If it fails: fix the Dockerfile minimally to make it succeed (this becomes the "red→green" of this ticket — a real build failure is the closest thing to a failing test here)
- Evidence: build log saved to `work/009/docker-build.log`

### Step 2 → criterion 2 (docker run + health check)
- Action: `docker run` the built image with `RAILS_MASTER_KEY` (from `config/master.key`, never logged/committed) mapped to a local port; `curl localhost:<port>/up` from the host
- If the container fails to boot or `/up` doesn't return 200: fix whatever's broken (missing env var, missing asset precompile step, etc.) — minimal change, documented
- Evidence: container logs + curl response saved to `work/009/docker-run.log`

### Step 3 → criterion 3 (CLAUDE.md refresh)
- Read current `CLAUDE.md`, diff against everything added since it was last substantively written (auth via ticket 004, Tailwind via 002, dotenv/AI service via 007, dashboard via 008, factory queue via the /next-ticket skill)
- Update to accurately reflect: `bin/rails tailwindcss:build`/`:watch`, `bin/dev` (foreman: web + tailwind watch), `.env` setup for `OPENAI_API_KEY`, and `/next-ticket` as the way to continue the queue
- Commit: `ticket-009: verify Docker build/run, refresh CLAUDE.md`

## Research notes
- This ticket's own body says it's "mostly verification — candidate for lean ticket or phase=off." Going through the full ticket flow anyway for an honest audit trail (issue closure + PR), but skipping the research fan-out and multi-commit TDD cycle structure since there's no new app behavior to drive with failing tests — the closest equivalent to "red" is an actual build/run failure, which gets fixed if it happens.
- `RAILS_MASTER_KEY` must never appear in `work/009/*.log` files that get committed — redact before saving.

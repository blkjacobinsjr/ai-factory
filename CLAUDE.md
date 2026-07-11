# AI Factory

Read `FACTORY.md` for the pipeline. The rules below bind every session:

@.claude/rules/factory.md

Current phase + ticket are injected into every prompt (`FACTORY: phase=…`). If a tool call is BLOCKED, the message names the skill to run — run it, don't work around the gate.

Toolchain: Ruby via mise (`mise x ruby@3.3 -- <cmd>` if shims absent). Suite: `bin/rails test` (auto-builds Tailwind via test:prepare). Dev server: `bin/dev` (foreman: web + tailwindcss:watch) or `bin/rails server` → localhost:3000. CSS: Tailwind v4, component classes in `app/assets/tailwind/application.css`; manual rebuild `bin/rails tailwindcss:build`.

Secrets: copy `.env.example` → `.env` (gitignored) and set `OPENAI_API_KEY` (optional `OPENAI_MODEL`, defaults to `gpt-4o-mini`) — loaded via `dotenv-rails` in development/test only. Without it, `AiInsightService` calls fail gracefully (flash error, no crash) rather than being required to boot the app.

Docker: `docker build -t ai-factory .` then `docker run -d -p 3001:80 -e RAILS_MASTER_KEY=$(cat config/master.key) --name ai-factory-verify ai-factory` — verified working (see `work/009/`); `curl localhost:3001/up` → 200.

Project: **Learning Companion** (Project 6 brief) — auth/profiles, goals, learning sessions, resources, AI summaries, dashboard — built ticket-by-ticket through the factory (see `.factory/metrics.md` for the full history). Queue = GitHub issues ("Intake for the AI factory"); `/next-ticket` dispatches whatever comes next — reads `.factory/state` and either resumes the in-flight phase or offers the top unblocked issue. Browser acceptance drives live in `work/<id>/drive.mjs` (scripted Playwright; MCP tools when connected) — ticket 007's drive exercises a real external API call (OpenAI), not just stubs, since that's the one thing the stubbed test suite structurally can't cover.

Test helpers: `test/test_helpers/session_test_helper.rb` (`sign_in_as`/`sign_out`, from Rails 8's auth generator) and `test/test_helpers/stub_helper.rb` (`stub_class_method` — hand-rolled since this app's Minitest 6 removed `minitest/mock`/`Object#stub` entirely).

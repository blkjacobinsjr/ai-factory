# AI Factory

Read `FACTORY.md` for the pipeline. The rules below bind every session:

@.claude/rules/factory.md

Current phase + ticket are injected into every prompt (`FACTORY: phase=…`). If a tool call is BLOCKED, the message names the skill to run — run it, don't work around the gate.

Toolchain: Ruby via mise (`mise x ruby@3.3 -- <cmd>` if shims absent). Suite: `bin/rails test` (auto-builds Tailwind via test:prepare). Dev server: `bin/dev` (foreman: web + tailwindcss:watch) or `bin/rails server` → localhost:3000. CSS: Tailwind v4, component classes in `app/assets/tailwind/application.css`; manual rebuild `bin/rails tailwindcss:build`.

Project: **Learning Companion** (Project 6 brief) — goals, learning sessions, resources, AI summaries, dashboard — built ticket-by-ticket through the factory. Queue = GitHub issues ("Intake for the AI factory"); `/next-ticket` dispatches whatever comes next. Browser acceptance drives live in `work/<id>/drive.mjs` (scripted Playwright; MCP tools when connected).

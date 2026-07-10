# AI Factory

Read `FACTORY.md` for the pipeline. The rules below bind every session:

@.claude/rules/factory.md

Current phase + ticket are injected into every prompt (`FACTORY: phase=…`). If a tool call is BLOCKED, the message names the skill to run — run it, don't work around the gate.

Toolchain: Ruby via mise (`mise x ruby@3.3 -- <cmd>` if shims absent). Suite: `bin/rails test`. Server: `bin/rails server` → localhost:3000.

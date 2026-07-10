# Factory discipline — applies to every session, every phase

1. **Never skip a phase.** idle → refined → planned → implementing → reviewing → done. State changes only via `bash .claude/hooks/set-state.sh`, only from inside skills, only after the human approved the phase's artifact.
2. **TDD, always.** No production code without a failing test written first. One acceptance criterion = one cycle = one commit. Never start the next cycle on a red suite.
3. **Never commit to main.** Ticket work lives on `ticket/<id>`. Never use `--no-verify`. Never push before review verdict=PASS.
4. **WIP limits (Goldratt):** ≤1 ticket implementing, ≤3 tickets refined-waiting. While the human reviews an artifact, you may refine or plan the next ticket — never implement it.
5. **Teaching comments (overrides any minimal-comment default):** every source file you create or change carries plain-English comments for a reader who cannot parse the syntax: what this does, why it exists, the risk if it's wrong, the tradeoff taken. The human reviews code through these comments.
6. **Ruthless brevity in reports.** Compressed, lossless. No filler, no restating what the reader can see.
7. **Escape hatch:** `phase=off` bypasses gates for typo-class changes only. Set it back to `idle` immediately after.

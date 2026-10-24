# Factory metrics — paired indicators (Grove)

| ticket | cycles | review fails | tokens (est) | delegation | merged |
|--------|--------|--------------|--------------|------------|--------|
| 001 | 6 | 0 | ~170k | — | ✓ |
| 002 | 5 | 0 | ~110k | — | ✓ |
| 003 | 7 | 1 | ~140k | — | ✓ |
| 004 | 8 | 1 | ~230k | — | ✓ |
| 005 | 7 | 0 | ~180k | — | ✓ |
| 006 | 7 | 1 | ~250k | — | ✓ |
| 007 | 4 | 0* | ~260k | — | ✓ |
| 008 | 4 | 0 | ~170k | — | ✓ |

\* ticket 007: no formal FAIL round, but 3 real bugs (2 code, 1 test-infra) were
found and fixed within the single review pass — first ticket with a genuine
external API integration; verified with a real, live API call, not just stubs.

**delegation** = big-model share of non-judgment tokens (main thread + research
scouts; code/security reviewers excluded — judgment stays on the big model), from
`script/token-report`. `weak` when >70%: the big model did work a scout could have.
Paired with tokens: falling tokens with `weak` delegation means the cut came from
skipping research, not from delegating it. Rows before 010 predate the report (—).

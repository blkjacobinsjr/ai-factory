# Factory metrics — paired indicators (Grove)

| ticket | cycles | review fails | tokens (est) | merged |
|--------|--------|--------------|--------------|--------|
| 001 | 6 | 0 | ~170k | ✓ |
| 002 | 5 | 0 | ~110k | ✓ |
| 003 | 7 | 1 | ~140k | ✓ |
| 004 | 8 | 1 | ~230k | ✓ |
| 005 | 7 | 0 | ~180k | ✓ |
| 006 | 7 | 1 | ~250k | ✓ |
| 007 | 4 | 0* | ~260k | ✓ |
| 008 | 4 | 0 | ~170k | ✓ |

\* ticket 007: no formal FAIL round, but 3 real bugs (2 code, 1 test-infra) were
found and fixed within the single review pass — first ticket with a genuine
external API integration; verified with a real, live API call, not just stubs.

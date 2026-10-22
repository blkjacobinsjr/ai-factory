# Token economy (shell)

- Batch dependent shell steps into ONE Bash call, chained with `&&` (e.g. `cd x && npm ci && npm test`). Never issue Bash→Bash→Bash for steps that could run together; each extra call re-sends context.
- Never poll with `sleep`. Start long jobs in the background (`cmd > /tmp/job.log 2>&1 &`) and wait once (`wait $PID`, or the harness's background/await tool), then read the log once.
- Read only what you need from logs (`tail -n 50`, `rg pattern`), not whole files.

GitHub: https://github.com/blkjacobinsjr/ai-factory/issues/16

# Add AI summary and next-steps for goals

## Context
Brief feature 5 (issue #16). Two actions on the goal detail page call the OpenAI Chat Completions API (plain `Net::HTTP`, no SDK gem) with the goal's recent learning sessions and resources as context. API key via `.env` (dotenv), never hardcoded.

## Acceptance criteria
1. Given a signed-in user's own Goal with learning sessions and resources, When they trigger "Generate summary", Then the service sends that context to the AI provider, and the returned summary is persisted on the goal and displayed on its page.
2. Given a signed-in user's own Goal, When they trigger "Suggest next steps", Then 2-3 concrete next steps are generated, persisted, and rendered as a list on the goal page.
3. Given the AI provider call fails (network error or a non-success response), When either action is triggered, Then the user sees a clear error message instead of a crash, and no partial/stale result is saved.
4. Given a Goal owned by a DIFFERENT user, When the signed-in user triggers either action on it directly by URL, Then they are blocked (404) — the goal untouched, no AI call made.

## Out of scope
- Editing or regenerating history (only the latest summary/next-steps per goal are kept, overwritten each time)
- Streaming responses, retries, rate-limit backoff
- Any UI for choosing the AI model/provider — one fixed model, configured via ENV
- Real network calls in the automated test suite — the HTTP-sending step is stubbed in tests (no webmock/vcr in this app); a real call is exercised once during the review's browser drive using a real API key, verifying actual end-to-end behavior beyond what the stubbed tests can prove

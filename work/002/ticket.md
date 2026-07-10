GitHub: https://github.com/blkjacobinsjr/ai-factory/issues/7

# Style bookmark pages with Tailwind

## Context
Bookmark pages work but are browser-default HTML (issue #7). Add Tailwind (tailwindcss-rails, no Node) and shadcn-style component classes; restyle index, new, edit.

## Acceptance criteria
1. Given the application layout, When GET `/`, Then the response links a Tailwind stylesheet (`link[rel=stylesheet]` with href containing "tailwind").
2. Given any bookmark page (`/`, `/bookmarks/new`, edit), When rendered, Then its content sits inside the layout's `main.container` element.
3. Given a saved bookmark, When GET `/`, Then it renders inside an element with class `card` that contains the title link, an Edit link, and a Delete button.
4. Given GET `/bookmarks/new`, Then the title and url inputs carry class `input`, their labels carry class `label`, and the submit button carries class `btn`.
5. Given a POST with a blank title, When the form re-renders, Then the validation messages appear inside an element with class `form-errors`.

## Out of scope
- Dark mode, responsive/mobile nav, any JS-driven components
- Basecoat or any new npm/gem beyond `tailwindcss-rails` (shadcn *look* via Tailwind `@apply` component classes)
- Rendering flash notices (not displayed today; separate ticket if wanted)
- Visual quality judgments — asserted structure only; looks are reviewed by human via screenshots at final review

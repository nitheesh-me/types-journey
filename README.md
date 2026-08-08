# POPL/M 26 slides

Multiple reveal.js decks served from one SvelteKit project, themed with
[Catppuccin](https://github.com/catppuccin/catppuccin). The index at `/` lists
every deck; each deck lives at `/slides/<slug>/`.

| Deck | Route | Handouts | Exercises |
| --- | --- | --- | --- |
| Lecture 01 — Types, and why Lean | `/slides/introduction/` | `handout.lean`, `collections.lean`, `io.lean`, `csv.lean` | — |
| Manual | `/slides/manual/` | `handout.lean` | — |
| Lecture 00 — Should you learn Lean 4? | `/slides/should-i-learn-lean/` | `tour.lean` | — |
| Lecture 02 — Control Flow, Recursion, Structures, Inductives | `/slides/fp-control/` | `handout.lean` | `a02.lean` |
| Lecture 03 — Type Polymorphism, Classes and Instances | `/slides/fp-polymorphism/` | `handout.lean`, `functor.lean` | `a03.lean` |
| Lecture 04 — Monads: Impurity and Fallibility | `/slides/fp-monad/` | `handout.lean`, `monad.lean` | `a04.lean` |
| Lecture 05 — IO, Exceptions, Concurrency | `/slides/fp-io/` | `handout.lean` + 6 example files | `a05.lean` |

Preview with

```bash
npm run dev [-- --open]
```

and build the static site (all decks at once) with `npm run build`.

## Theme

All four Catppuccin flavours ship: **Latte**, **Frappé**, **Macchiato**,
**Mocha**, plus a **High contrast** theme. The picker on the index (and
top-right of every deck) stores the choice; with no choice made the theme
follows `prefers-color-scheme`, and an OS request for `prefers-contrast: more`
selects high contrast. Append `?flavour=mocha` or `?flavour=contrast` to any URL
to force one, which is handy for linking a deck for a projector.

High contrast is not a Catppuccin flavour. It fills the same variable contract,
so everything themed from those variables works unchanged, but the palette is
chosen for legibility: every accent clears 7:1 against the black base (WCAG AAA
for body text). It also raises the grey ramp, gives code blocks a visible edge,
and dims stepped-through code less aggressively, because those three are where a
theme built for looks becomes hard to read on a washed-out projector.

Everything colours itself from the variables in `$lib/theme/catppuccin.css`
(the flavour palette plus semantic aliases like `--color-functional` and
`--code-message`), so there are no per-flavour rules anywhere else — including
the syntax highlighting and the reveal.js theme overrides.

## Handouts and exercises

Handouts live in `static/handout/<lecture>/` and exercises in
`static/assignment/`, so each file is both **downloadable** from the index and
**inlined into the deck** via a `?raw` import through the `$handouts` alias.
One copy, no drift.

Slides pull code out of a handout by name rather than restating it:

```
--- snippet Function
def f x = x + 2
--- end
```

```svelte
<CodeSnippet lines="true" code={snippets} key="Function" />
```

`npm run check:snippets` cross-checks the two directions — a slide asking for a
snippet that no handout defines is an error; a handout snippet no slide shows,
or a handout file no deck references, is a warning. It currently reports clean.

`npm run check:lean` compiles every handout with the Lean toolchain, so the code
on a slide is known to work rather than known to look right. Deprecation
warnings count: a handout the audience runs should not spew them. It skips
cleanly if `lean` is not on PATH.

Only the Introduction handouts are *enforced*. The CS99 ones are snippet
sources rather than whole programs — they declare `Vec2` and `Bad` twice, carry
examples that are meant to fail (strict positivity, a deliberate `throw`), and
the Manual deck's is pseudo-Lean (`def f x = x + 2`). They are still compiled
and reported, because the output is informative, but a failure there is
upstream's shape and does not fail the check.

## Slide notes

Every slide can carry a notes panel: the **?** button (top-right of a deck, or
the `i` key) slides it in from the right. It has two tabs — **Notes**, the
written-out explanation meant to be read, and **Presenter**, what you would say
out loud. Both are markdown, and ` ```mermaid ` fences render as diagrams
themed from the current flavour. `?panel=notes` or `?panel=presenter` opens the
panel on load.

Notes live in a `notes.md` beside each deck, keyed by the slide's heading:

```
--- note If-Else
Markdown for the Notes tab.
--- presenter
Markdown for the Presenter tab.
```

`node scripts/attach-notes.mjs <deck>` wires them into the matching slides and
reports keys with no slide. Where several slides share a heading, key one
`Heading#2` to single it out.

There is exactly one panel for the whole deck, rendered by the deck layout. A
`<SlideNotes>` on a slide only *registers* its markdown against that slide's
`<section>` (see `$lib/slides/decor.ts`); the layout swaps the content on
`slidechanged`. The slide characters work the same way. Both used to render
inside their slide with `position: fixed`, which resolves against reveal's
transformed `.slides` box rather than the viewport — a closed panel was only
pushed out of the 960px deck and stayed visible in the margin beside it, and a
percentage-height character jumped once reveal applied its transform.

Coverage today: the Manual deck is complete; the four lectures have notes on
every section opener and the conceptually dense slides (82 of 210). The rest
are a `--- note <heading>` block away.

Because the panel is shared, a tab holds markdown only — there are no per-slide
component slots.

Note that the query parameter is `panel`, not `notes` — reveal.js opens its own
speaker window when it sees `notes` anywhere in the query string.

## Adding a deck

1. Create `src/routes/slides/<slug>/+page.svelte`.
2. Put handouts in `static/handout/<slug>/`.
3. Add an entry to the `decks` array in `src/routes/+page.ts`.

Set the deck's title with `<svelte:head><title>…</title></svelte:head>`; the
shared reveal.js setup lives in `src/routes/slides/+layout.svelte`.

## Slide components

`$lib/slides/`:

- `Section.svelte` — a slide, with reveal.js auto-animate wiring.
- `Code.svelte` — a code block styled by role: `example`, `message`, `ref`, `terminal`.
- `CodeSnippet.svelte` — one named block lifted out of a handout (see above);
  the parser is `snippets.ts`.
- `Note.svelte` — a callout with a character beside it, keyed by role:
  `program`, `math`, `metaprog`, `kernel`.
- `Annotation.svelte` — labels a `\htmlId{…}{…}` group inside a KaTeX formula.
  `annotate.ts` draws the connectors once the formula is typeset.
- `Choice.svelte` — the two options of a decision slide, with their key hints.
  Lecture 00 is navigated as a decision tree: Down takes the branch, Right
  skips to the next question. reveal only nests two levels, so the tree is
  mapped onto its grid and the contract holds inside a branch too.
- `CodeCompare.svelte` — the same idea in two to four languages, side by side,
  each column marked with its language in the corner (`languageMarks.ts`; the
  path icons are Simple Icons, CC0, and Lean gets a typographic badge because
  its wordmark is not redistributable).
- `Diagram.svelte` — a mermaid diagram on a slide, themed from the flavour and
  lazily loaded. Shares `$lib/diagram/mermaid.ts` with the notes panel.
- `Citation.svelte` — a cited work, with an optional cover.
- `lean.ts` — a small Lean 4 grammar for highlight.js, which ships none.

`$lib/notes/` holds the notes panel: `SlideNotes.svelte` (the drawer),
`NotesToggle.svelte` (the button), `parse.ts` (the `notes.md` format) and
`markdown.ts` (marked, plus mermaid loaded lazily on first open).

## Attribution

The **Manual** deck and **Lectures 02–05** (slides, handouts, and exercises) are
adapted from [Stanford CS99](https://web.stanford.edu/class/cs99/), used under
[CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).
Adaptations inherit that licence — note the non-commercial clause.

Changes made to the upstream material:

- Handouts gained snippets for examples that were on a slide but had no
  handout block, each marked in-file and namespaced so the file still compiles.
- `fp-polymorphism/handout.lean` checked `duplicate` in the *Universe
  Polymorphism* snippet, where the slide and its output are about
  `duplicate'`; corrected, with a comment.
- Slides were added for handout material that upstream never showed
  (`Option Functions`, and pointers to the `monad.lean` / `functor.lean`
  supplements).
- Annotations are drawn on load as well as on slide transition, so a direct
  link to an annotated slide renders, and each arrowhead gets its own marker id
  rather than sharing one.

The Introduction deck is original. The HoTT Book cover in `static/citation/` is
reproduced under CC BY-SA 3.0; every other cited work is a styled card with a
link, since their covers are not redistributable.

None of the CS99 artwork is reused. The characters in `static/sprite/`
(programmer, mathematician, metaprogrammer, kernel programmer) are cut from
`design/sprites-*.png`; each ships as a mirrored pair named for the direction
it looks. They are line art whose shading lives in the alpha channel and are
painted as CSS masks, so they re-ink themselves for whichever flavour is
active. They stand in a bottom corner of the viewport at `25vh`, facing back in,
and fly in and out from their own edge as you move between slides — a change of
character plays as a hand-off, the outgoing one leaving by the side it came
from. The transitions are marked `|global`, because a local transition is
suppressed when the block being created belongs to the parent rather than the
element itself. `prefers-reduced-motion` drops the duration to zero.

The open notes panel covers the right-hand corner, so a `math` or `kernel`
character is hidden while it is up.

## License

This project is dedicated to the public domain under the [Creative Commons Zero v1.0 Universal](LICENSE) (CC0 1.0) license.


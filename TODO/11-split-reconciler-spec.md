# 13 — Split `reconciler_spec.rb` into per-concern files

**Priority:** Medium (spec organization)
**Files:** `spec/uniword/docx/reconciler_spec.rb` →
`spec/uniword/docx/reconciler/`

## Status of the original note

Numbers are stale and have grown. It said 1980 lines and 12 top-level
describes; actual today is **2054 lines and 21 describes**. That growth
is the argument for doing this now.

`spec/uniword/docx/reconciler/` **already exists** with three files
(`fix_codes_spec.rb`, `helpers_spec.rb`, `referential_integrity_spec.rb`),
so this extends an established layout rather than inventing one.

## Problem

A 2054-line monolith with 21 top-level describes. Slow to navigate, slow
to run a single concern, hard to see what is covered.

## Fix

Split along `lib/uniword/docx/reconciler/`'s actual module boundaries, so
each spec file has an obvious owner. The original note proposed filenames
invented from describe titles; those titles mislead in several places.

Ownership below was checked against the implementing method, not guessed
from the title.

| lib module | spec file | absorbs |
| --- | --- | --- |
| `notes.rb` | `notes_spec.rb` | footnotes, endnotes, note reference validation (R10), note definition integrity (R15/R16), notes reorder |
| `tables.rb` | `tables_spec.rb` | table reconciliation, table gridAfter |
| `body.rb` | `body_spec.rb` | headers/footers, existing value preservation |
| `parts.rb` | `parts_spec.rb` | numbering reconciliation (`Parts#reconcile_numbering`, `parts.rb:152`) |
| `package_structure.rb` | `package_structure_spec.rb` | Group 3 package consistency |
| `referential_integrity.rb` | *(existing file)* | most of "referential integrity" (see below), style reference/inheritance/run-and-table integrity, hyperlink references, paraId/rId uniqueness, numbering body reference integrity (`referential_integrity.rb:176`) |
| root orchestration | `reconciler_spec.rb` *(what remains)* | `clear_stored_namespace_plans`, profile-dependent reconciliation |

Three corrections, because the describe titles actively mislead:

- **"numbering body reference integrity" is not `body.rb`.** It is
  `ReferentialIntegrity#reconcile_numbering_body_references`.
- **"numbering reconciliation" is not cross-cutting.** It is
  `Parts#reconcile_numbering`.
- **`fix.rb` owns nothing here.** It only defines the `Fix` value
  object, so there is no `fix_spec.rb` in this split.

**No `theme_spec.rb`.** There is no top-level theme describe to absorb;
the only theme behavior sits inside the profile describe.

**"profile-dependent reconciliation" stays at root.** It spans `Parts`,
`Body`, `Theme` and the top-level orchestration, so no single module owns
it. Splitting it by owner would shred one coherent end-to-end test into
fragments that individually prove nothing. Keep it as the orchestration
smoke test, which is what the original note also wanted.

**"referential integrity" does not move as one block.** Its first
examples ("creates missing footnote definition for dangling reference"
and the endnote equivalent) go through `Notes#reconcile_note_references`
(`notes.rb:12`), not `ReferentialIntegrity`. Those belong in
`notes_spec.rb`; the rest moves to `referential_integrity_spec.rb`. This
is the one describe that must be split by example rather than moved
intact, so read each example's call path before moving it.

## How to sequence the work

There is no useful "move the setup first" step. Concern-local setup cannot move
before its describe moves, and relocating the top-level aliases into nested
blocks inside the monolith would be review-only churn that changes no behaviour.
Two earlier revisions of this note proposed one; drop it.

Instead, each step moves one concern **and** carries whatever setup that concern
needs.

Measured, so the sizing is real: the top level has **8 `let`s** (class aliases)
and **one** helper, `build_package` (line 16). `build_package_with_headers` is
**nested inside** the headers/footers describe at line 2016, not shared —
rubocop's "13 memoized helpers" warning refers to that nested group, not the top
level.

Prefer duplicating a one-line class alias in each destination file over creating
a shared fixture file. Small duplication beats hidden shared state, which is
what the original note preferred too.

The one describe needing care is "referential integrity" — see above; it splits
by example rather than moving intact, so read each example's call path first.

## Verification

A spec split has a specific failure mode: the tests still pass but no
longer test the same thing. Guard against it explicitly.

- **Example count must be conserved.** Record
  `bundle exec rspec spec/uniword/docx/ --dry-run` before and after; the
  totals must match exactly. A drop means a describe was orphaned.
- **Each moved file must still be able to fail.** For each new file,
  break the relevant reconciler module once and confirm it goes red.
- Each file runs independently:
  `bundle exec rspec spec/uniword/docx/reconciler/notes_spec.rb`
- `bundle exec rspec spec/uniword/docx/` green.
- `bundle exec rubocop spec/uniword/docx/`

## Out of scope

- Rewriting any assertion. This is a move, not a rewrite. If a spec looks
  wrong, note it — fixing it here makes the conservation check
  meaningless.
- The pre-existing rubocop offences in the moved code (long lines,
  memoized helper counts, `build_package_with_headers` ABC size). They
  travel as-is; cleaning them up would hide the move in unrelated churn.
- Splitting any other monolithic spec file.

## Sequencing

None. An earlier revision claimed this should follow TODO/02 to avoid rebase
pain. There is no overlap: TODO/02 touches accessibility, MHTML and math specs,
none of which is `reconciler_spec.rb`. Either order works.

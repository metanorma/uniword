# 10 — find-replace/redact: paragraph walker probes methods most containers don't have

## Problem
`FindReplace::ParagraphWalker#walk_container` probes
`container.structured_document_tags` and `container.tables` on every
container, but only `Wordprocessingml::Body` maps SDTs, and only
Body / TableCell / Header / Footer map tables. `walk_sdts` then called
`sdt.paragraphs`, but `StructuredDocumentTag` carries its content at
`sdt.content` (`sdtContent`), which holds `paragraphs`, `tables`, and
nested `sdts`.

Consequences (all exit 1 with `Unexpected error: undefined method ...`):

- `uniword find-replace in.docx out.docx A B` on ANY document whose
  body contains a table — `TableCell` has no
  `structured_document_tags`.
- `uniword redact in.docx out.docx` — same crash (Redact::Engine
  delegates to FindReplace::Engine).
- Any `--scope headers` / `--scope footers` run — Header/Footer
  containers lack `structured_document_tags`.
- Any `--scope footnotes` / `--scope endnotes` / `--scope comments`
  run — those containers lack both `tables` and
  `structured_document_tags`.
- Documents with body-level SDTs — `sdt.paragraphs` does not exist.

Only `--scope body` over a table-free, SDT-free document worked,
which is why round-1 smoke tests on blank.docx passed.

## Fix
`lib/uniword/find_replace/paragraph_walker.rb`: replace method
probing with explicit typed dispatch mirroring the established
precedent in `Docx::DocumentStatistics` (which walks the same models
without crashing):

- `Body` → paragraphs + tables + structured_document_tags
- `TableCell`, `Header`, `Footer` → paragraphs + tables
- everything else (Footnote, Endnote, Comment) → paragraphs
- `walk_sdts` recurses through `sdt.content` (paragraphs, tables,
  nested sdts) instead of the nonexistent `sdt.paragraphs`

## Status
IMPLEMENTED — lib/uniword/find_replace/paragraph_walker.rb;
specs: spec/uniword/find_replace/paragraph_walker_spec.rb,
spec/uniword/cli_find_replace_scopes_spec.rb (Open3: find-replace
and redact over table- and header-bearing documents).

# 13 — `styles remove --unused` crashes on documents with footnotes or comments

## Problem
`Wordprocessingml::StyleCleanup` walks every container (body,
headers/footers, footnote entries, endnote entries, comments) with
its own copy of the paragraph-walk — and that copy probes
`container.tables` on every container. `Footnote`, `Endnote`, and
`Comment` models do not map `tables`, so:

    $ uniword styles remove input.docx output.docx --unused
    Unexpected error: undefined method 'tables' for an instance of
    Uniword::Wordprocessingml::Footnote

Any document whose package carries footnotes, endnotes, or comments
crashes before a single style is analyzed. This is the same
probing-walker family as TODO.fix/10, but a separate private
implementation (DRY violation that hid the fix).

## Fix
`StyleCleanup` reuses `FindReplace::ParagraphWalker.each_paragraph`
(the single typed-dispatch walker fixed in TODO.fix/10) for
`walk_all_paragraphs`, and deletes its private
walk_paragraphs/walk_table_rows/walk_table_cells copies. The
body-only `walk_tables` (for `tblStyle` collection) stays — it only
ever receives `Body`/`TableCell`, which both map `tables`.

## Status
IMPLEMENTED — lib/uniword/wordprocessingml/style_cleanup.rb; specs:
spec/uniword/cli_styles_unused_spec.rb (Open3: --unused on a
footnote-bearing document exits 0).

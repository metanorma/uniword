# 03 - Paragraph Fidelity in MHTML

## Status: DONE

## Problem

Paragraph count in generated MHT (298) differs from reference (302). This was a secondary issue expected to resolve once footnote references, table merges, and HTML→OOXML element handling were fixed.

## Root Causes Found and Fixed

1. **Hyperlink-only paragraphs silently dropped** (Bug in `HtmlElementBuilder.build_paragraph`):
   `paragraph.runs.any?` returned false when paragraph content was only hyperlinks or SDTs (stored in separate collections).
   **Fix**: Check `paragraph.runs.any? || paragraph.hyperlinks.any? || paragraph.sdts.any?`

2. **Missing footnote reference markers** (TODO 01): Footnote reference runs were silently dropped in OOXML → MHT rendering.
   **Fix**: Added `footnote_reference_to_html` / `endnote_reference_to_html` in MhtmlElementRenderer.

3. **Extra empty `<td>` cells from vMerge continuations** (TODO 02): Continuation cells rendered as separate `<td>` instead of being absorbed.
   **Fix**: Pre-compute vMerge map, skip continuation cells, add rowspan to start cell.

4. **HTML `<br clear="all">` not treated as page break**: Word HTML uses `clear="all"` for section/page breaks.
   **Fix**: `create_break_run` now checks both `style` for `page-break-*` and `clear="all"`.

## Verification

- All uniword specs: 218 transformation + 5007 unit specs, 0 failures
- All html2doc specs: 154 examples, 0 failures
- New tests in `spec/transformation/html_element_builder_spec.rb` cover all fixes

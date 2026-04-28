# 05 - HTML → OOXML: Footnote Reference Spans

## Status: DONE

## Problem

`HtmlElementBuilder.build_children` doesn't handle `<span class="MsoFootnoteReference">` elements. These should become `Run` objects with `footnoteReference` elements.

## Fix

`lib/uniword/transformation/html_element_builder.rb`:

1. `build_children` (line 228): Added `<span>` case that checks for `MsoFootnoteReference`/`MsoEndnoteReference` classes
2. Added `footnote_reference_span?` and `endnote_reference_span?` helpers
3. Added `create_footnote_reference_run` and `create_endnote_reference_run` helpers
4. Added `extract_note_id` to extract footnote ID from nested `<a href="#_ftnN">` or text content

## Tests

`spec/transformation/html_element_builder_spec.rb`:
- "handles footnote reference spans"
- "handles endnote reference spans"
- "returns true for MsoFootnoteReference class"
- "extracts from nested anchor href"
- "extracts from text content as fallback"

# 06 - HTML → OOXML: Hyperlink Elements

## Status: DONE

## Problem

`HtmlElementBuilder.build_children` doesn't handle `<a href="...">` elements. Hyperlinks were silently dropped during HTML → OOXML conversion.

## Fix

`lib/uniword/transformation/html_element_builder.rb`:

1. `build_children` (line 228): Added `<a>` case that delegates to `create_hyperlink`
2. Added `create_hyperlink` helper that:
   - Extracts `href` attribute
   - Uses `Hyperlink#target=` to auto-detect internal (#anchor) vs external (URL)
   - Builds child runs from text nodes and formatting elements
   - Adds to `paragraph.hyperlinks` collection

## Tests

`spec/transformation/html_element_builder_spec.rb`:
- "handles hyperlink elements"
- "handles internal bookmark hyperlinks"
- "skips hyperlinks without href"

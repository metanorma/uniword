# 07 - HTML → OOXML: Breaks and Images

## Status: DONE

## Problem

`HtmlElementBuilder.build_children` doesn't handle `<br>` or `<img>` elements.

## Fix

`lib/uniword/transformation/html_element_builder.rb`:

1. `build_children` (line 228): Added `<br>` case that delegates to `create_break_run`
2. Added `create_break_run` helper:
   - Creates `Run` with `Break`
   - Detects `page-break-before`/`page-break-after` in style → sets `break.type = "page"`
   - Otherwise creates a line break (type=nil)
3. `<img>` elements are explicitly skipped (binary data not available from HTML parsing)

## Tests

`spec/transformation/html_element_builder_spec.rb`:
- "handles <br> elements as break runs"
- "detects page-break style on <br>"
- "preserves text nodes alongside special elements"

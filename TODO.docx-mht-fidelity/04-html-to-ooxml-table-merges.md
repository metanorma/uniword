# 04 - HTML → OOXML: Table Merge Attributes (colspan/rowspan → gridSpan/vMerge)

## Status: DONE

## Problem

`HtmlElementBuilder.build_cell` ignores `colspan` and `rowspan` HTML attributes when converting HTML table cells to OOXML TableCell objects. The OOXML model gets no `grid_span` or `v_merge` properties.

## Fix

`lib/uniword/transformation/html_element_builder.rb`:

1. `build_cell` (line 111): Added `colspan → grid_span`, `rowspan → v_merge` (restart), `<th> → header` detection
2. `build_table` (line 34): Rewrote to compute grid layout row-by-row, inserting vMerge continuation cells where HTML rowspan omits cells

## Tests

`spec/transformation/html_element_builder_spec.rb`:
- "handles colspan → gridSpan"
- "handles rowspan → vMerge restart with continuation cells"
- "handles both colspan and rowspan on same cell"
- "detects <th> as header cell"
- "sets header flag for <th>"
- "sets grid_span for colspan"
- "sets vMerge restart for rowspan"

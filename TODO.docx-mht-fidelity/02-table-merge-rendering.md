# 02 - Table Merge (gridSpan/vMerge) Rendering in MHTML

## Status: DONE

## Problem

When the OOXML → MHTML Transformer converts tables, gridSpan (colspan) and vMerge (rowspan) properties are ignored. Cells with `gridSpan > 1` render without `colspan` attribute. vMerge continuation cells render as separate empty `<td>` elements instead of being absorbed into the start cell's `rowspan`.

## Fix

`lib/uniword/transformation/mhtml_element_renderer.rb`:
- `table_to_html` (line 282): Pre-computes vMerge map via `build_vmerge_map`, skips continuation cells, computes rowspan via `compute_rowspan`
- `build_vmerge_map` (line 315): Maps `[row_idx, col_idx] → :start | :continue`
- `compute_rowspan` (line 340): Counts continuation cells below start cell
- `table_cell_to_html` (line 359): Reads `grid_span` → `colspan=N` attribute, accepts `rowspan:` parameter

## Tests

`spec/transformation/mhtml_element_renderer_spec.rb`:
- "renders gridSpan as colspan attribute"
- "renders header cells with <th> tag"
- "renders vMerge as rowspan and skips continuation cells"

# 004: Builder DRY refactor

## Status: DONE

## Changes

### 4a. Extract track_element_order / ensure_properties_in_order to BaseBuilder
Currently duplicated in ParagraphBuilder and TableCellBuilder (differing only
in property tag name: "pPr" vs "tcPr"). Extract to BaseBuilder with tag parameter.

### 4b. Extract deterministic_id to shared module
Identical `deterministic_id` method in ImageBuilder and ChartBuilder.
Extract to `Builder::DeterministicId` module.

## Files
- `lib/uniword/builder/base_builder.rb` — add shared methods
- `lib/uniword/builder/paragraph_builder.rb` — remove duplicates
- `lib/uniword/builder/table_cell_builder.rb` — remove duplicates
- `lib/uniword/builder/deterministic_id.rb` — NEW shared module
- `lib/uniword/builder/image_builder.rb` — use shared module
- `lib/uniword/builder/chart_builder.rb` — use shared module

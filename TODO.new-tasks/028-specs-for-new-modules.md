# 028: Add specs for new modules (RunUtils, PageDefaults, TableDefaults, Merging)

## Status: DONE

## Problem

Four new modules extracted during the DRY refactors have no dedicated spec files:

- `Builder::RunUtils` — shared run classification and merging
- `Wordprocessingml::PageDefaults` — shared page layout defaults
- `Wordprocessingml::TableDefaults` — shared table look defaults
- `Wordprocessingml::RunProperties::Merging` — already has specs but
  `ModelAttributeAccess` doesn't

## Fix

Create spec files for each:

1. `spec/uniword/builder/run_utils_spec.rb`
   - `empty_run?` — text-only run, run with drawings, run with field_char
   - `text_only_run?` — pure text run, run with break, run with tab
   - `properties_match?` — both nil, one nil, identical, different
   - `mergeable?` — text-only with same props, text-only with different props,
     non-text run
   - `merge_text` — combines text, handles xml_space

2. `spec/uniword/wordprocessingml/page_defaults_spec.rb`
   - `default_page_size` returns US Letter dimensions
   - `default_page_margins` returns standard margins
   - `default_columns` returns space: 720
   - `default_doc_grid` returns line_pitch: 360

3. `spec/uniword/wordprocessingml/table_defaults_spec.rb`
   - `default_table_look` returns correct values
   - `fill_missing_table_look` fills nil attributes

4. `spec/uniword/model_attribute_access_spec.rb`
   - `read_attribute` with known attribute
   - `write_attribute` with known attribute
   - raises on unknown attribute

## Files
- New spec files in `spec/uniword/`

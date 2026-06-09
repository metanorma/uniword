# 018: Update field instruction tests for Run-level field elements

## Status: DONE

## Problem

8 test failures from a behavioral change in how `fldChar` and `instrText`
elements are mapped:

- **Main branch**: `run.field_char = X` assigns to the Paragraph's mixed-content
  collection (lutaml-model quirk), so field elements end up as
  `paragraph.field_chars` and `paragraph.instr_text` (Paragraph-level).
- **This branch**: Same code now correctly assigns to `run.field_char` and
  `run.instr_text` (Run-level), which is the correct OOXML structure
  (`<w:r><w:fldChar>` inside a run).

The code is now correct — the tests are testing the old (broken) behavior.

### Failing tests (all test Paragraph-level field accessors instead of Run-level)

- `advanced_features_spec.rb:98` — `page_number` checks `paragraph.field_chars.size`
- `advanced_features_spec.rb:112` — `total_pages` checks `paragraph.field_chars.size`
- `advanced_features_spec.rb:125` — `date_field` checks `paragraph.field_chars.size`
- `advanced_features_spec.rb:139` — `time_field` checks `paragraph.field_chars.size`
- `document_builder_enhanced_spec.rb:238` — `page_number_field`
- `document_builder_enhanced_spec.rb:252` — `total_pages_field`
- `document_builder_enhanced_spec.rb:261` — `date_field`
- `document_builder_enhanced_spec.rb:271` — `time_field`

## Fix

Update tests to access Run-level field elements:

```ruby
# Before (wrong level)
expect(paragraph.field_chars.size).to be >= 3
expect(paragraph.instr_text.first.text).to include("PAGE")

# After (correct Run-level access)
runs = paragraph.runs
expect(runs.any? { |r| r.field_char&.fldCharType == "begin" }).to be true
expect(runs.any? { |r| r.field_char&.fldCharType == "end" }).to be true
instr_run = runs.find { |r| r.instr_text }
expect(instr_run.instr_text.content.join).to include("PAGE")
```

## Files
- `spec/uniword/builder/advanced_features_spec.rb` (lines 98-170)
- `spec/uniword/builder/document_builder_enhanced_spec.rb` (lines 238-280)

# TODO Plans Index

## Summary

7 failing specs across 4 test files. All critical round-trip and serialization tests pass.

## Fixed This Session

1. **Headers/Footers/Sections** - All 30 tests passing
   - Deleted `sections` and `current_section` wrapper methods from DocumentRoot
   - Updated tests to use model-driven architecture
   - File: `spec/uniword/headers_footers_fields_spec.rb`

2. **lutaml-model compatibility fix**
   - Restored `input_namespace_extractor.rb` and `input_namespaces_capable.rb`
   - These files were deleted causing `uninitialized constant` errors

3. **Table visitor pattern fix**
   - Added `accept` method to Table class to support visitor pattern
   - File: `lib/uniword/wordprocessingml/table.rb`

## Remaining Failing Tests

### 1. Quality Rules (4 failures)
- `quality_rules_spec.rb` lines 143, 155, 174, 194
- Issue: External validation processing may be required
- Status: May need external validation integration

### 2. Assembly/Generators (2 failures)
- `document_assembler_spec.rb` lines 101, 110
- Issue: Test fixtures create minimal files, not valid DOCX
- Status: Test infrastructure issue - requires valid DOCX component files

### 3. Text Extractor (1 failure)
- `text_extractor_spec.rb` line 196
- Issue: Model stores paragraphs and tables in separate collections, losing interleaved order
- Status: Pre-existing limitation of model architecture

## Key Decision: Model vs Builder API

Many tests fail because they test a **builder API** (add_section, add_paragraph with options, etc.) but the architecture is **model-driven OOXML** (document structure via XML elements).

The user explicitly said "NO Document builder or writer API at this stage" and "fully model-driven".

**Conclusion**: Tests that expect builder API should be updated to match model-driven architecture or marked as pending.

## Verification Commands

```bash
# Run all tests
bundle exec rspec spec/uniword spec/uniword/ooxml 2>&1 | grep failures

# Enhanced properties (critical)
bundle exec rspec spec/uniword/enhanced_properties_roundtrip_spec.rb

# Theme extraction
bundle exec rspec spec/uniword/drawingml/theme_extraction_spec.rb

# Headers/footers
bundle exec rspec spec/uniword/headers_footers_fields_spec.rb
```

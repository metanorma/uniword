# 19: Fix orphaned shared examples and duplicated helpers

**Priority:** P2
**Effort:** Small (~2 hours)
**Files:**
- `spec/support/shared_examples.rb` (orphaned shared example)
- `spec/support/xml_normalizers.rb` (only support file)
- Multiple spec files with duplicated helper methods

## Problem 1: Orphaned shared example

`spec/support/shared_examples.rb` defines `"a serializable element"` shared
example but it is NEVER used anywhere (0 hits for `include_examples` or
`it_behaves_like`). Either use it or delete it.

## Problem 2: Duplicated helper methods

Several helper methods are defined inline in multiple spec files:

| Helper | Duplicated in |
|--------|--------------|
| `extract_text` / `get_text` | `round_trip_spec.rb`, `docx_reading_spec.rb`, `edge_cases_spec.rb` |
| `create_large_document` / `build_doc` | `docx_performance_spec.rb`, `benchmark_suite_spec.rb` |
| `normalize_xml` | `round_trip_spec.rb`, `mhtml_round_trip_spec.rb` |
| `safe_delete` / cleanup helpers | Multiple integration specs |

## Problem 3: Empty spec file

`spec/round_trip_spec.rb` is 0 bytes — a leftover that should be deleted.

## Fix

1. **Delete** `spec/round_trip_spec.rb` (empty file)

2. **Update** `spec/support/shared_examples.rb`:
   - Replace the unused `"a serializable element"` with actually useful shared
     examples (see #18 for the `"a serializable OOXML model"` pattern)

3. **Create** `spec/support/helpers.rb`:
   ```ruby
   module DocumentHelpers
     def extract_text(document)
       # ... consolidated implementation
     end

     def create_document(paragraphs: 1, tables: 0, ...)
       # ... consolidated implementation
     end

     def normalize_for_comparison(xml)
       # ... consolidated implementation
     end
   end

   RSpec.configure { |c| c.include DocumentHelpers }
   ```

4. **Remove** duplicated methods from individual spec files, use the shared
   helpers instead.

5. **Create** `spec/support/shared_contexts.rb` for common setup patterns
   (e.g., "with a blank document", "with a temp file").

## Verification

```bash
# Ensure no tests broke from the consolidation
bundle exec rspec

# Verify shared examples are actually used
grep -rn 'include_examples\|it_behaves_like\|include_context' spec/
```

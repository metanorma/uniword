# Phase 2.7: Systematic Unit Test Fixes

## Objective
Fix remaining 54 unit test failures using ONLY architectural solutions

**Current Status**: 54 failures, 95.3% pass rate
**Target**: 0 failures, 100% pass rate

## Architectural Approach - NO HACKS

### Category 1: Serialization Infrastructure (Priority 1 - 20+ failures)

**Root Cause**: lutaml-model requires `attribute` declarations for XML-mapped elements, not `attr_accessor`

**Files to Fix**:
1. ✅ `lib/uniword/table_cell.rb` - Changed `attr_accessor :properties` to `attribute :cell_properties, :string` with alias
2. `lib/uniword/paragraph.rb` - Already uses `attribute :properties` ✓
3. `lib/uniword/table.rb` - Already uses `attribute :properties` ✓
4. `lib/uniword/table_row.rb` - Already has `attribute :row_properties` ✓

**Solution Pattern**:
- Declare property attributes using lutaml's `attribute` directive
- Provide aliases for backward compatibility if needed
- lutaml-model handles collection detection automatically

### Category 2: Run Text Serialization (5 failures)

**Root Cause**: Tests expect `Run.text_element` to accept strings directly

**File**: `lib/uniword/run.rb`

**Current State**: Already handles string-to-TextElement conversion ✓

**Verification Needed**: Ensure `to_xml` works correctly

### Category 3: Style Name Format (3 failures)

**Root Cause**: Style names changed from "Heading1" to "Heading 1" (with space)

**Files**:
- Tests in `builder_spec.rb`

**Solution**: Style resolution should maintain backward compatibility
- When style ID is "Heading1", return "Heading 1" (the display name)
- Add method `style_id` to return raw ID
- Update `Paragraph#style` to properly resolve names

**Already implemented** ✓ (see line 204-216 in paragraph.rb)

### Category 4: Validator Error Messages (5 failures)

**Root Cause**: Validators return generic "Element validation failed" instead of specific messages

**Files**:
- `lib/uniword/validators/paragraph_validator.rb`
- `lib/uniword/validators/table_validator.rb`

**Solution**: Create proper error aggregation in validators
- Validators should collect all specific errors
- Return array of detailed error messages, not generic message

### Category 5: XML Namespace Prefixes (3 failures)

**Root Cause**: Some elements using `r:` prefix instead of `w:` for WordProcessingML

**Solution**: Verify namespace configuration in affected classes
- Document should use `w:document` not `r:document`
- Drawing should use proper namespace

### Category 6: Properties Immutability (3 failures)

**Root Cause**: Tests expect frozen properties, but we made them mutable

**Decision**: Properties are intentionally mutable for compatibility
**Solution**: Update tests to expect mutable properties, NOT change implementation

### Category 7: Miscellaneous (Balance)

Various smaller issues to address individually

## Execution Order

1. ✅ Fix TableCell serialization
2. Verify and fix remaining serialization issues
3. Fix validator error messages
4. Fix XML namespace configuration
5. Update properties immutability tests
6. Address miscellaneous issues

## Success Criteria

- [ ] All unit tests passing (100%)
- [ ] All compatibility tests still passing (100%)
- [ ] No regressions introduced
- [ ] Clean architectural solutions only
# Duplicate Class Merge - Continuation Plan

## Executive Summary

We are consolidating duplicate class definitions between `lib/uniword/properties/` and `lib/uniword/wordprocessingml/` directories. The correct versions (from properties/) are being moved to `lib/uniword/ooxml/wordprocessingml/` with proper namespace, and all invalid duplicates are being deleted.

**Progress**: 95% Complete (6 of 6 critical files merged, 1 alias fix remaining)

## Current Status

### ✅ Completed Work

1. **Discovery & Analysis**
   - Created `bin/find_duplicate_classes.rb` - Scans all Ruby files for duplicate XML element declarations
   - Created `bin/analyze_wordprocessingml_duplicates.rb` - Analyzes WordProcessingML namespace conflicts
   - Created `DUPLICATE_MERGE_PLAN.md` - Documents merge strategy and rationale

2. **Core Properties Migrated**
   - ✅ `paragraph_properties.rb` → `lib/uniword/ooxml/wordprocessingml/paragraph_properties.rb`
   - ✅ `run_properties.rb` → `lib/uniword/ooxml/wordprocessingml/run_properties.rb`
   - ✅ `table_properties.rb` → `lib/uniword/ooxml/wordprocessingml/table_properties.rb`

3. **References Updated**
   - ✅ 8 files updated for ParagraphProperties namespace change
   - ✅ All lib/ files updated for RunProperties namespace change
   - ✅ All lib/ files updated for TableProperties namespace change
   - ✅ `lib/uniword/wordprocessingml/*.rb` files fixed to use full namespace paths

4. **Duplicates Deleted**
   - ✅ `lib/uniword/properties/{paragraph,run,table}_properties.rb` (3 files)
   - ✅ `lib/uniword/wordprocessingml/{paragraph,run,table}_properties.rb` (3 files)

### ⚠️ Remaining Work

#### Phase 1: Fix Main Module Aliases (5 minutes)

**File**: `lib/uniword.rb`
**Lines**: 65-67
**Issue**: Aliases reference old namespace

```ruby
# CURRENT (WRONG):
ParagraphProperties = Wordprocessingml::ParagraphProperties
RunProperties = Wordprocessingml::RunProperties  
TableProperties = Wordprocessingml::TableProperties

# REQUIRED:
ParagraphProperties = Ooxml::WordProcessingML::ParagraphProperties
RunProperties = Ooxml::WordProcessingML::RunProperties
TableProperties = Ooxml::WordProcessingML::TableProperties
```

**Action**: Edit lines 65-67 to use `Ooxml::WordProcessingML::` namespace

#### Phase 2: Test Suite Verification (10 minutes)

Run full test suite to verify all changes:

```bash
bundle exec rspec
```

Expected: All tests pass (or at least same pass rate as before merge)

If failures occur:
1. Check error messages for namespace issues
2. Search for any remaining `Properties::` references
3. Update as needed

#### Phase 3: Delete Redundant WordProcessingML Files (10 minutes)

These 15 files are now redundant (handled by properties in run_properties.rb):

```
lib/uniword/wordprocessingml/caps.rb
lib/uniword/wordprocessingml/double_strike.rb  
lib/uniword/wordprocessingml/highlight.rb
lib/uniword/wordprocessingml/kerning.rb
lib/uniword/wordprocessingml/language.rb
lib/uniword/wordprocessingml/position.rb
lib/uniword/wordprocessingml/run_fonts.rb
lib/uniword/wordprocessingml/small_caps.rb
lib/uniword/wordprocessingml/strike.rb
lib/uniword/wordprocessingml/vanish.rb
lib/uniword/wordprocessingml/character_spacing.rb
lib/uniword/wordprocessingml/vert_align.rb
lib/uniword/wordprocessingml/tab_stop_collection.rb
lib/uniword/wordprocessingml/table_cell_borders.rb
lib/uniword/wordprocessingml/table_cell_properties.rb
```

**Action**: Delete each file and verify no references remain

#### Phase 4: Final Verification (5 minutes)

Run duplicate finder again to confirm all resolved:

```bash
ruby bin/analyze_wordprocessingml_duplicates.rb
```

Expected output: "No overlapping elements found!"

#### Phase 5: Documentation (10 minutes)

Update documentation to reflect namespace changes:

1. Update `README.adoc` if it references Properties namespace
2. Create migration guide for users updating from older versions
3. Move `DUPLICATE_MERGE_PLAN.md` to `old-docs/` (work complete)

## Technical Background

### Why This Merge Was Necessary

**Problem**: Two conflicting implementations of the same OOXML elements:

1. **Properties/** version: ✅ Correct
   - Uses proper wrapper objects
   - Correct XML mappings
   - Full feature implementation

2. **Wordprocessingml/** version: ❌ Invalid
   - Maps same XML attribute to multiple Ruby attributes (impossible!)
   - Example: `map_attribute 'val', to: :style` AND `map_attribute 'val', to: :num_id`
   - Missing features
   - Poor OO design

### Decision: Move to Ooxml::WordProcessingML Namespace

**Rationale**:
- Properties classes ARE WordProcessingML (w: namespace)
- Should live in proper namespace hierarchy
- Maintains MECE architecture (no overlapping namespaces)
- Follows open/closed principle (extensible without modification)

## Architecture Principles Applied

1. **MECE (Mutually Exclusive, Collectively Exhaustive)**
   - Each XML element has ONE canonical class
   - No overlapping responsibilities

2. **Separation of Concerns**
   - Properties classes handle formatting only
   - No file I/O or serialization logic in models

3. **Open/Closed Principle**
   - Classes designed for extension via inheritance
   - No need to modify existing classes for new properties

4. **Single Responsibility**
   - Each property class handles one XML element type
   - Container classes (ParagraphProperties) compose sub-properties

## Success Criteria

✅ **Zero duplicate element declarations** in same namespace
✅ **All tests passing** (or same pass rate as before)
✅ **Proper namespace hierarchy** (`Uniword::Ooxml::WordProcessingML`)
✅ **Clean architecture** (no invalid XML mappings)
✅ **Documentation updated** to reflect changes

## Rollback Plan (If Needed)

If critical issues arise, rollback steps:

1. Restore deleted files from git history
2. Revert namespace changes: `git diff HEAD~10 lib/uniword/`
3. Run: `git checkout HEAD~10 lib/uniword/properties/ lib/uniword/wordprocessingml/`
4. Investigate root cause before retry

## Timeline

- **Phase 1**: 5 minutes (fix aliases)
- **Phase 2**: 10 minutes (test suite)
- **Phase 3**: 10 minutes (delete redundant files)
- **Phase 4**: 5 minutes (verification)
- **Phase 5**: 10 minutes (documentation)

**Total**: ~40 minutes to complete all remaining work

## Files Created During This Work

1. `bin/find_duplicate_classes.rb` - General duplicate finder
2. `bin/analyze_wordprocessingml_duplicates.rb` - Focused analyzer
3. `bin/update_paragraph_properties_references.rb` - Reference updater
4. `bin/fix_wordprocessingml_references.rb` - Namespace fixer
5. `DUPLICATE_MERGE_PLAN.md` - Original plan
6. `DUPLICATE_MERGE_CONTINUATION_PLAN.md` - This file
7. `DUPLICATE_MERGE_STATUS.md` - Status tracker (see below)

## Next Session Start

See `DUPLICATE_MERGE_CONTINUATION_PROMPT.md` for exact steps to continue.
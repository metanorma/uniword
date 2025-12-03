# Duplicate Class Merge - Continuation Prompt

## Quick Start

You are continuing work on eliminating duplicate class definitions in the Uniword codebase. The work is **95% complete** with only final touches remaining.

## Current State

**What's Done**:
- ✅ Core properties migrated to `lib/uniword/ooxml/wordprocessingml/`
- ✅ All references updated throughout codebase
- ✅ 6 duplicate files deleted
- ✅ 16 files updated with correct namespaces

**What's Left**:
- ⚠️ Fix 3 alias lines in `lib/uniword.rb`
- ⚠️ Delete 15 redundant files
- ⚠️ Run test suite
- ⚠️ Final verification

## IMMEDIATE NEXT STEP

### Step 1: Fix lib/uniword.rb Aliases (5 minutes)

**File**: `lib/uniword.rb`
**Lines**: 65-67

**Current (WRONG)**:
```ruby
# Properties classes
ParagraphProperties = Wordprocessingml::ParagraphProperties
RunProperties = Wordprocessingml::RunProperties  
TableProperties = Wordprocessingml::TableProperties
```

**Change To**:
```ruby
# Properties classes
ParagraphProperties = Ooxml::WordProcessingML::ParagraphProperties
RunProperties = Ooxml::WordProcessingML::RunProperties
TableProperties = Ooxml::WordProcessingML::TableProperties
```

**Command**:
```bash
# Use apply_diff or direct edit of lib/uniword.rb lines 65-67
```

### Step 2: Test the Fix (5 minutes)

```bash
cd /Users/mulgogi/src/mn/uniword
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb --fail-fast
```

**Expected**: Tests should load without "uninitialized constant" errors.

### Step 3: Delete Redundant Files (10 minutes)

These 15 files are now redundant (their functionality is in the new properties classes):

```bash
cd /Users/mulgogi/src/mn/uniword

# Character formatting wrappers (now in run_properties.rb)
rm lib/uniword/wordprocessingml/caps.rb
rm lib/uniword/wordprocessingml/double_strike.rb
rm lib/uniword/wordprocessingml/highlight.rb
rm lib/uniword/wordprocessingml/kerning.rb
rm lib/uniword/wordprocessingml/language.rb
rm lib/uniword/wordprocessingml/position.rb
rm lib/uniword/wordprocessingml/run_fonts.rb
rm lib/uniword/wordprocessingml/small_caps.rb
rm lib/uniword/wordprocessingml/strike.rb
rm lib/uniword/wordprocessingml/vanish.rb
rm lib/uniword/wordprocessingml/character_spacing.rb
rm lib/uniword/wordprocessingml/vert_align.rb

# Table/paragraph formatting wrappers
rm lib/uniword/wordprocessingml/tab_stop_collection.rb
rm lib/uniword/wordprocessingml/table_cell_borders.rb
rm lib/uniword/wordprocessingml/table_cell_properties.rb
```

### Step 4: Full Test Suite (10 minutes)

```bash
bundle exec rspec
```

**Expected**: Same pass rate as before merge (or better).

If failures occur:
1. Check for remaining `Properties::` references
2. Verify namespace paths are correct
3. Update any test files that hardcode class paths

### Step 5: Final Verification (5 minutes)

Run the duplicate analyzer to confirm zero conflicts:

```bash
ruby bin/analyze_wordprocessingml_duplicates.rb
```

**Expected Output**: "No overlapping elements found!"

Also run general duplicate finder:

```bash
ruby bin/find_duplicate_classes.rb | grep "CRITICAL DUPLICATES TO FIX"
```

**Expected**: Should show 0 critical duplicates (down from 26).

### Step 6: Documentation (10 minutes)

1. **Archive Planning Docs**:
   ```bash
   mkdir -p old-docs/duplicate-merge
   mv DUPLICATE_MERGE_*.md old-docs/duplicate-merge/
   ```

2. **Update README.adoc** (if it mentions Properties namespace):
   ```bash
   grep -n "Properties::" README.adoc
   # If found, update to Ooxml::WordProcessingML::
   ```

3. **Check other docs**:
   ```bash
   grep -r "Properties::ParagraphProperties" docs/
   # Update any matches
   ```

## Architecture Context

### Why This Merge?

**Problem**: Two implementations of same OOXML elements:
- `Properties::ParagraphProperties` ✅ (correct, with wrappers)
- `Wordprocessingml::ParagraphProperties` ❌ (invalid XML mappings)

**Solution**: Consolidate into proper namespace:
- `Ooxml::WordProcessingML::ParagraphProperties` ✅

### Key Principle

**MECE Architecture**: Each XML element has **exactly one** canonical class definition. No overlaps, no gaps.

## Troubleshooting

### If Tests Fail After Alias Fix

**Check**: Are there any remaining old references?
```bash
grep -r "Properties::ParagraphProperties" lib/
grep -r "Wordprocessingml::ParagraphProperties" lib/ | grep -v "lib/uniword.rb"
```

**Fix**: Update any remaining references to use `Ooxml::WordProcessingML::`

### If Duplicate Analyzer Still Shows Conflicts

**Check**: Did all 15 redundant files get deleted?
```bash
ls lib/uniword/wordprocessingml/ | grep -E "(caps|strike|highlight|kerning|language|position|fonts|vanish|spacing|align|tab_stop|cell_borders|cell_properties)"
```

**Fix**: Delete any remaining files from the list.

### If New Errors Appear

**Rollback Strategy**:
```bash
git status                    # See what changed
git diff lib/uniword.rb       # Review alias changes
git checkout lib/uniword.rb   # Revert if needed
```

## Files Created During This Work

All in project root:
- `DUPLICATE_MERGE_PLAN.md` - Original strategy
- `DUPLICATE_MERGE_CONTINUATION_PLAN.md` - Detailed plan
- `DUPLICATE_MERGE_STATUS.md` - Progress tracker
- `DUPLICATE_MERGE_CONTINUATION_PROMPT.md` - This file

All in `bin/`:
- `find_duplicate_classes.rb` - General finder
- `analyze_wordprocessingml_duplicates.rb` - Focused analyzer
- `update_paragraph_properties_references.rb` - Reference updater
- `fix_wordprocessingml_references.rb` - Namespace fixer

## Success Criteria

- [ ] `lib/uniword.rb` aliases use `Ooxml::WordProcessingML::` namespace
- [ ] All 15 redundant files deleted
- [ ] Test suite passes (or same pass rate)
- [ ] Zero critical duplicates in analyzer output
- [ ] Documentation updated/archived

## Estimated Time Remaining

- Step 1 (alias fix): 5 minutes
- Step 2 (quick test): 5 minutes  
- Step 3 (delete files): 10 minutes
- Step 4 (full tests): 10 minutes
- Step 5 (verification): 5 minutes
- Step 6 (documentation): 10 minutes

**Total**: ~45 minutes to 100% completion

## On Completion

When all steps done, the duplicate merge will be **100% complete**:
- ✅ Zero duplicate class definitions
- ✅ Proper namespace hierarchy
- ✅ Clean, MECE architecture
- ✅ All tests passing
- ✅ Documentation updated

Then you can mark this task as complete and move to next priority work!
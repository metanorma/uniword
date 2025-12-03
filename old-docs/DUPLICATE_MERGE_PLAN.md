# Duplicate Class Merge Plan

## Summary

Found **26 overlapping elements** between:
- `lib/uniword/properties/` ✅ CORRECT (proper OO design)
- `lib/uniword/wordprocessingml/` ❌ WRONG (invalid XML mappings)

## Decision: KEEP Properties, DELETE WordML

**Reason**: All WordML versions either:
1. Have **duplicate attribute mappings** (invalid XML - same attribute mapped to multiple Ruby attrs)
2. Lack **proper wrapper objects** (poor OO design)
3. Are less complete than Properties versions

## Files to Delete (9 files)

### Critical - Invalid XML Mappings
1. `lib/uniword/wordprocessingml/run_properties.rb` - maps same `val` to multiple attrs
2. `lib/uniword/wordprocessingml/paragraph_properties.rb` - maps same `val` to multiple attrs
3. `lib/uniword/wordprocessingml/table_properties.rb` - maps same `val` to multiple attrs
4. `lib/uniword/wordprocessingml/table_cell_properties.rb` - maps same `val` to multiple attrs

### Redundant - Covered by Properties containers
5. `lib/uniword/wordprocessingml/table_cell_borders.rb` - replaced by properties/borders.rb
6. `lib/uniword/wordprocessingml/tab_stop_collection.rb` - replaced by properties/tabs.rb
7. `lib/uniword/wordprocessingml/character_spacing.rb` - replaced by properties/spacing.rb
8. `lib/uniword/wordprocessingml/vert_align.rb` - replaced by properties/vertical_align.rb

### Small Wrappers - Now in properties/run_properties.rb
9. `lib/uniword/wordprocessingml/caps.rb`
10. `lib/uniword/wordprocessingml/double_strike.rb`
11. `lib/uniword/wordprocessingml/highlight.rb`
12. `lib/uniword/wordprocessingml/kerning.rb`
13. `lib/uniword/wordprocessingml/language.rb`
14. `lib/uniword/wordprocessingml/position.rb`
15. `lib/uniword/wordprocessingml/run_fonts.rb`
16. `lib/uniword/wordprocessingml/small_caps.rb`
17. `lib/uniword/wordprocessingml/strike.rb`
18. `lib/uniword/wordprocessingml/vanish.rb`

## Files to Keep and Fix Namespace

Properties files are CORRECT but in WRONG namespace:
- Current: `Uniword::Properties`
- Should be: `Uniword::Ooxml::WordProcessingML`

### Files to Update Namespace (6 files)
1. `lib/uniword/properties/paragraph_properties.rb` → Move to `lib/uniword/ooxml/wordprocessingml/paragraph_properties.rb`
2. `lib/uniword/properties/run_properties.rb` → Move to `lib/uniword/ooxml/wordprocessingml/run_properties.rb`
3. `lib/uniword/properties/table_properties.rb` → Move to `lib/uniword/ooxml/wordprocessingml/table_properties.rb`
4. `lib/uniword/properties/borders.rb` → Move to `lib/uniword/ooxml/wordprocessingml/borders.rb`
5. `lib/uniword/properties/tabs.rb` → Move to `lib/uniword/ooxml/wordprocessingml/tabs.rb`
6. `lib/uniword/properties/spacing.rb` → Keep as-is (paragraph spacing, not character spacing)

## Implementation Steps

### Phase 1: Move Properties to Correct Namespace
1. Create `lib/uniword/ooxml/wordprocessingml/` directory
2. Move properties files one by one
3. Update module namespace in each file
4. Update all require statements
5. Test after each move

### Phase 2: Delete Redundant WordML Files
1. Delete files one by one (smallest first)
2. Search for any references
3. Update references to use Properties versions
4. Test after each deletion

### Phase 3: Update All References
1. Search for `Uniword::Properties::ParagraphProperties` → `Uniword::Ooxml::WordProcessingML::ParagraphProperties`
2. Search for `Uniword::Wordprocessingml::RunProperties` → `Uniword::Ooxml::WordProcessingML::RunProperties`
3. Update require paths
4. Run full test suite

## Risk Assessment

**Low Risk**: Properties versions are actively used, well-tested, and correct.
**High Confidence**: WordML versions have PROVEN invalid XML (duplicate mappings).

## Success Criteria

1. ✅ All 18 redundant files deleted
2. ✅ All properties in correct namespace (`Uniword::Ooxml::WordProcessingML`)
3. ✅ All tests passing
4. ✅ No `lib/uniword/properties/` directory (only for non-OOXML properties if any)
5. ✅ Zero duplicate element declarations in same namespace
# Enhanced Properties Round-Trip Continuation Plan

## Current Status (November 26, 2024)

### ✅ PHASE 1 COMPLETE: Document Serialization Fixed
- Document.to_xml() now produces complete XML with body and paragraphs
- Basic round-trip (save → load → verify) working perfectly
- Architecture corrected to follow model-driven patterns
- All lutaml-model initialization issues resolved

### ⚠️ PHASE 2 BLOCKED: Enhanced Properties Not Preserving Values
**Test Results**: 3/12 enhanced property tests passing (25%)
- ✅ Boolean properties (outline, shadow, emboss) work
- ❌ Wrapper properties (CharacterSpacing, Kerning, Position, etc.) return empty values
- ❌ Complex properties (Borders, Shading, TabStops) not fully preserved

## Critical Lesson Learned

**LUTAML-MODEL RULE**: Attributes MUST be defined BEFORE xml mappings block.

```ruby
# ✅ CORRECT
class MyClass < Lutaml::Model::Serializable
  attribute :my_attr, MyType  # Define first
  
  xml do
    map_element 'elem', to: :my_attr  # Map after
  end
end

# ❌ WRONG - Will not serialize
class MyClass < Lutaml::Model::Serializable
  xml do
    map_element 'elem', to: :my_attr  # Mapping first
  end
  
  attribute :my_attr, MyType  # Too late!
end
```

## Problem Analysis

### Root Cause Hypothesis
The wrapper property classes (CharacterSpacing, Kerning, Position, TextExpansion, EmphasisMark, Language) may have:
1. Attributes defined after XML mappings (architecture error)
2. Missing XML attribute mappings for `val` attribute
3. Incorrect namespace handling
4. Missing `render_default: true` in mappings

### Evidence
```
❌ Run: character_spacing value mismatch (got )
❌ Run: kerning value mismatch (got )
❌ Run: position value mismatch (got )
```
Empty strings suggest the objects are created but values not set.

## Phase 2 Implementation Plan

### Step 1: Diagnose Serialization (15 min)

**Goal**: Determine if values are in XML or missing

1. Save a document with enhanced properties
2. Extract and examine word/document.xml
3. Check if `<w:spacing w:val="20"/>` and similar elements exist
4. Verify namespace declarations

**Files to check**:
- `test_output/enhanced_props_focused.docx` (already created)
- Extract word/document.xml and inspect

### Step 2: Fix Wrapper Property Classes (30-45 min)

**For each wrapper class**: CharacterSpacing, Kerning, Position, TextExpansion, EmphasisMark, Language

**Location**: `lib/uniword/properties/simple_val_properties.rb`

**Required fixes**:

1. **Verify attribute/mapping order**:
```ruby
# Ensure this pattern:
class CharacterSpacing < Lutaml::Model::Serializable
  attribute :val, :integer  # FIRST
  
  xml do
    element 'spacing'  # AFTER
    namespace Ooxml::Namespaces::WordProcessingML
    
    map_attribute 'val', to: :val
  end
end
```

2. **Add render_default if needed**:
```ruby
map_attribute 'val', to: :val, render_default: true
```

3. **Ensure proper initialization**:
```ruby
def initialize(attributes = {})
  super(attributes)
end
```

### Step 3: Fix Complex Properties (30 min)

**Borders** (`lib/uniword/properties/border.rb`):
- Verify attribute order
- Check `map_attribute 'color', to: :color`
- Ensure ParagraphBorders properly maps border elements

**Shading** (`lib/uniword/properties/shading.rb`):
- Verify `map_attribute 'fill', to: :fill`
- Check ParagraphShading vs RunShading classes

**TabStops** (`lib/uniword/properties/tab_stop.rb`):
- Verify TabStop has `map_attribute 'pos', to: :position`
- Check TabStopCollection properly wraps tabs

### Step 4: Verify XML Namespace Consistency (15 min)

All enhanced property classes must use:
```ruby
namespace Ooxml::Namespaces::WordProcessingML
```

Check for any using hardcoded namespace URIs.

### Step 5: Test Serialization (15 min)

Run test suite:
```bash
bundle exec ruby test_enhanced_props_focused.rb
```

Expected outcome: 12/12 tests passing

### Step 6: Run Full Enhanced Properties Test Suite (15 min)

```bash
bundle exec rspec spec/uniword/properties/ --tag enhanced
```

Verify all enhanced properties serialize and deserialize correctly.

## Estimated Timeline

| Phase | Task | Time | Status |
|-------|------|------|--------|
| 1 | Document serialization fix | 2h | ✅ COMPLETE |
| 2.1 | Diagnose wrapper properties | 15m | ⏳ NEXT |
| 2.2 | Fix wrapper property classes | 45m | 📋 PLANNED |
| 2.3 | Fix complex properties | 30m | 📋 PLANNED |
| 2.4 | Verify namespaces | 15m | 📋 PLANNED |
| 2.5 | Test and validate | 30m | 📋 PLANNED |
| **Total Phase 2** | | **~2.5h** | |

## Success Criteria

### Phase 2 Complete When:
- ✅ All 12 enhanced property tests passing
- ✅ Character spacing, kerning, position, text expansion preserved
- ✅ Emphasis mark and language preserved
- ✅ Paragraph borders with colors preserved
- ✅ Paragraph shading with fill preserved
- ✅ Tab stops with positions preserved
- ✅ Round-trip: save → load → verify all values match

### Phase 3 (Future): Full Test Suite
- Run complete RSpec suite: `bundle exec rspec`
- Target: 0 failures related to enhanced properties
- Document any remaining issues for Phase 3

## Architecture Principles Applied

1. **Model-Driven**: No raw XML storage, all properties as lutaml-model classes
2. **MECE**: Each property class has one responsibility
3. **Open/Closed**: Extensible through inheritance (SimpleValProperty base class)
4. **Single Responsibility**: Wrapper classes only wrap values, formatting separate
5. **lutaml-model Compliance**: Attributes before mappings, proper initialization

## Files Requiring Changes

### High Priority (Phase 2)
1. `lib/uniword/properties/simple_val_properties.rb` - Fix all wrapper classes
2. `lib/uniword/properties/border.rb` - Verify attribute order
3. `lib/uniword/properties/shading.rb` - Verify attribute order  
4. `lib/uniword/properties/tab_stop.rb` - Verify attribute/mapping order

### Medium Priority (Phase 3)
5. `lib/uniword/properties/paragraph_properties.rb` - Verify all mappings
6. `lib/uniword/properties/run_properties.rb` - Verify all mappings

### Documentation (Post-Phase 2)
7. `README.adoc` - Update with enhanced properties examples
8. `docs/enhanced_properties.adoc` - Create comprehensive guide
9. Move `ENHANCED_PROPERTIES_CONTINUATION_PLAN.md` to `old-docs/` when complete

## Continuation Prompt

```markdown
# Enhanced Properties Round-Trip - Phase 2

## Context
Document serialization is now working perfectly. The body and paragraphs
round-trip correctly. However, enhanced property VALUES are not being
preserved during round-trip.

## Current Test Results
- 3/12 enhanced property tests passing
- Boolean properties (outline, shadow, emboss) work ✅
- Wrapper properties (CharacterSpacing, etc.) return empty values ❌
- Complex properties (Borders, Shading, TabStops) not fully preserved ❌

## Critical Rule
**LUTAML-MODEL**: Attributes MUST be defined BEFORE xml mappings!

## Your Task
1. Read `ENHANCED_PROPERTIES_ROUND_TRIP_CONTINUATION_PLAN.md`
2. Read `IMPLEMENTATION_STATUS.md` 
3. Start with Step 1: Diagnose by examining saved XML
4. Follow the plan to fix wrapper property classes
5. Test after each fix
6. Update IMPLEMENTATION_STATUS.md as you progress

## Expected Outcome
All 12 enhanced property tests passing in `test_enhanced_props_focused.rb`
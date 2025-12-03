# Phase 2: Enhanced Properties Round-Trip - Master Continuation Plan

**Created**: November 27, 2024 00:17 UTC
**Phase 1 Status**: ✅ COMPLETE - Document serialization working perfectly
**Phase 2 Status**: 🎯 READY TO START - 3/12 tests passing (25%)

---

## Executive Summary

### What Was Accomplished (Phase 1)

Fixed critical document serialization bug that was preventing ALL serialization:
- **Root Cause**: Attributes declared AFTER xml mappings in lutaml-model classes
- **Impact**: `Document.to_xml()` produced empty XML without body element
- **Solution**: Moved all attribute declarations BEFORE xml blocks
- **Result**: Full document round-trip now works perfectly

### What's Next (Phase 2)

Enhanced property VALUES are not being preserved during round-trip:
- Boolean properties work (outline, shadow, emboss) ✅
- Wrapper properties return empty values (CharacterSpacing, Kerning, etc.) ❌
- Complex properties incomplete (Borders, Shading, TabStops) ❌

**Hypothesis**: Same attribute-ordering issue exists in wrapper property classes.

---

## Critical Pattern Learned (NEVER VIOLATE THIS)

```ruby
# ✅ CORRECT - Attributes BEFORE xml mappings
class MyClass < Lutaml::Model::Serializable
  attribute :my_attr, MyType  # DECLARE FIRST
  
  xml do
    element 'myElem'
    map_attribute 'val', to: :my_attr  # MAP AFTER
  end
end

# ❌ WRONG - Will NOT serialize/deserialize
class MyClass < Lutaml::Model::Serializable
  xml do
    map_attribute 'val', to: :my_attr  # Mapping first
  end
  
  attribute :my_attr, MyType  # Too late! Framework doesn't know it exists
end
```

**Why**: Lutaml-model builds its internal schema by reading attribute declarations. If they come after xml mappings, the framework processes mappings before knowing attributes exist, resulting in empty serialization.

---

## Phase 2 Implementation Plan

### Step 1: Diagnose Serialization (15 min) 🔍

**Goal**: Determine if wrapper property values are in XML or missing entirely.

**Actions**:
```bash
cd test_output
unzip -p enhanced_props_focused.docx word/document.xml | xmllint --format - > document_formatted.xml
cat document_formatted.xml
```

**Look for**:
- `<w:spacing w:val="20"/>` - CharacterSpacing
- `<w:kern w:val="24"/>` - Kerning
- `<w:position w:val="5"/>` - Position
- `<w:w w:val="120"/>` - TextExpansion
- `<w:em w:val="dot"/>` - EmphasisMark
- `<w:lang w:val="en-US"/>` - Language

**Two possible outcomes**:
1. Values in XML but not loaded → Fix deserialization
2. Values missing from XML → Fix serialization

### Step 2: Fix Wrapper Property Classes (45 min)

**File**: `lib/uniword/properties/simple_val_properties.rb`

**For each class** (CharacterSpacing, Kerning, Position, TextExpansion, EmphasisMark, Language):

1. Verify `attribute :val` comes BEFORE `xml do` block
2. Verify `map_attribute 'val', to: :val` exists
3. Verify uses `namespace Ooxml::Namespaces::WordProcessingML`
4. Consider adding `render_default: true` if needed

**Example fix**:
```ruby
class CharacterSpacing < Lutaml::Model::Serializable
  attribute :val, :integer  # ✅ FIRST
  
  xml do
    element 'spacing'
    namespace Ooxml::Namespaces::WordProcessingML
    map_attribute 'val', to: :val  # ✅ AFTER
  end
end
```

### Step 3: Fix Complex Properties (30 min)

**Border** (`lib/uniword/properties/border.rb`):
- Verify `attribute :color` before xml block
- Check `map_attribute 'color', to: :color` exists

**Shading** (`lib/uniword/properties/shading.rb`):
- Verify `attribute :fill` before xml block
- Check `map_attribute 'fill', to: :fill` exists

**TabStop** (`lib/uniword/properties/tab_stop.rb`):
- Verify `attribute :position` before xml block
- Check `map_attribute 'pos', to: :position` exists

### Step 4: Test After Each Fix

```bash
bundle exec ruby test_enhanced_props_focused.rb
```

**Target**: 12/12 tests passing

### Step 5: Update Documentation

1. Update this file with completion status
2. Update IMPLEMENTATION_STATUS.md
3. Move completed plans to old-docs/
4. Update README.adoc with enhanced properties examples

---

## Reference Documents

### Detailed Implementation Plans
- **ENHANCED_PROPERTIES_ROUND_TRIP_CONTINUATION_PLAN.md** - Comprehensive plan with all details
- **NEXT_SESSION_ENHANCED_PROPERTIES_PROMPT.md** - Quick start prompt for next session
- **IMPLEMENTATION_STATUS.md** - Detailed status tracker with metrics

### Architecture Documentation
- **.kilocode/rules/memory-bank/context.md** - Current project state
- **.kilocode/rules/memory-bank/tech.md** - Critical lutaml-model pattern
- **.kilocode/rules/memory-bank/architecture.md** - Pattern 0 explanation

### Test Files
- **test_enhanced_props_focused.rb** - Main test (3/12 passing, target 12/12)
- **test_check_saved_xml.rb** - Verifies round-trip structure
- **test_serialization.rb** - Verifies XML structure

---

## Success Criteria

Phase 2 complete when:
- ✅ All 12 enhanced property tests passing
- ✅ Wrapper property values preserved (CharacterSpacing.val = 20, etc.)
- ✅ Complex property values preserved (Border.color = "FF0000", etc.)
- ✅ Round-trip verified: save → load → compare values all match
- ✅ No regressions in Phase 1 functionality

---

## Timeline Estimate

| Task | Time | Status |
|------|------|--------|
| Diagnose wrapper properties | 15 min | 🎯 NEXT |
| Fix wrapper classes | 45 min | 📋 PLANNED |
| Fix complex properties | 30 min | 📋 PLANNED |
| Testing & validation | 30 min | 📋 PLANNED |
| **Total Phase 2** | **~2 hours** | |

---

## Architecture Principles (Refresher)

### ✅ DO
1. **ALWAYS** declare attributes before xml mappings
2. Use lutaml-model for ALL XML structures
3. Declare `mixed_content` when element has nested content
4. Use ONE namespace per element level
5. Let lutaml-model handle serialization automatically
6. Use `||=` in initialize methods to preserve lutaml-model values

### ❌ DON'T
1. **NEVER** declare attributes after xml mappings (serialization killer)
2. Store raw XML strings (violates architecture)
3. Declare multiple namespaces at one level
4. Override `to_xml()` or `from_xml()` methods
5. Use `=` in initialize (overwrites lutaml-model values)

---

## Files Modified in Phase 1

**Core Fixes**:
- `lib/uniword/document.rb` - Attribute ordering, mixed_content, removed raw XML
- `lib/uniword/body.rb` - Attribute ordering, mixed_content
- `lib/uniword/formats/docx_handler.rb` - Use models not raw XML
- `lib/uniword/ooxml/docx_package.rb` - Parse into models
- `lib/uniword/styles_configuration.rb` - Attribute ordering
- `lib/uniword/numbering_configuration.rb` - Attribute ordering

**Documentation**:
- `.kilocode/rules/memory-bank/context.md` - Updated with Phase 1 completion
- `.kilocode/rules/memory-bank/tech.md` - Added critical pattern section
- `.kilocode/rules/memory-bank/architecture.md` - Added Pattern 0
- `README.adoc` - Added critical implementation pattern section
- `IMPLEMENTATION_STATUS.md` - Updated with Phase 1 complete, Phase 2 ready

---

## Quick Start for Next Session

1. **Read documentation** (10 min):
   - Memory bank files in `.kilocode/rules/memory-bank/`
   - This file (you're reading it now)
   - NEXT_SESSION_ENHANCED_PROPERTIES_PROMPT.md

2. **Start diagnosis** (15 min):
   - Extract XML from test_output/enhanced_props_focused.docx
   - Check if wrapper property values are present
   - Determine if issue is serialization or deserialization

3. **Fix wrapper classes** (45 min):
   - Open `lib/uniword/properties/simple_val_properties.rb`
   - Verify attribute order in all 6 wrapper classes
   - Test after each fix

4. **Fix complex properties** (30 min):
   - Fix Border, Shading, TabStop classes
   - Verify attribute mappings
   - Test round-trip

5. **Validate completion** (30 min):
   - Run full test suite
   - Update documentation
   - Move plans to old-docs/

**Expected Result**: 12/12 enhanced property tests passing, Phase 2 complete.

---

**Status**: Phase 1 COMPLETE ✅ | Phase 2 READY 🎯 | Estimated ~2 hours to completion
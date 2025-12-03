# Enhanced Properties Round-Trip - Continuation Prompt

## Quick Context

You are continuing work on the Uniword Ruby library for Microsoft Word documents. **Phase 1 is complete** - document serialization now works perfectly. **Phase 2 is blocked** - enhanced property values are not being preserved during round-trip.

## What Just Happened (Phase 1 ✅)

Fixed a critical bug where `Document.to_xml()` was producing empty XML. The fix involved:
1. Moving `attribute :body` declaration BEFORE xml mappings block
2. Adding `mixed_content` declaration
3. Fixing lutaml-model initialization patterns
4. Removing raw XML storage anti-patterns

**Result**: Basic round-trip works perfectly. Documents save and load with structure intact.

## Current Problem (Phase 2 ⚠️)

Enhanced properties are serialized but their **VALUES are empty** after round-trip.

### Test Results: 3/12 Passing (25%)
```bash
cd /Users/mulgogi/src/mn/uniword
bundle exec ruby test_enhanced_props_focused.rb
```

**Working** ✅:
- outline, shadow, emboss (boolean properties)

**Failing** ❌:
- character_spacing, kerning, position, text_expansion (wrapper properties return empty)
- emphasis_mark, language (wrapper properties return empty)
- paragraph borders (color empty), shading (fill empty), tab stops (position mismatch)

### Evidence of Issue
```
❌ Run: character_spacing value mismatch (got )
❌ Run: kerning value mismatch (got )
```
Empty strings suggest objects created but values not set.

## Critical Rule You MUST Follow

**LUTAML-MODEL ATTRIBUTES BEFORE MAPPINGS**:
```ruby
# ✅ CORRECT
class MyClass < Lutaml::Model::Serializable
  attribute :val, :integer  # FIRST
  
  xml do
    element 'myElem'
    map_attribute 'val', to: :val  # AFTER
  end
end

# ❌ WRONG - Will NOT serialize
class MyClass < Lutaml::Model::Serializable
  xml do
    map_attribute 'val', to: :val  # Mapping before attribute
  end
  
  attribute :val, :integer  # Too late!
end
```

## Your Task: Phase 2 Implementation

### Step 1: Diagnose (15 min) 🔍

**Goal**: Determine if values are in XML or missing entirely.

```bash
# Extract the saved document
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
1. **Values in XML but not loaded** → Fix deserialization (attribute/mapping order)
2. **Values missing from XML** → Fix serialization (check defaults, render options)

### Step 2: Fix Wrapper Properties (45 min)

**File**: `lib/uniword/properties/simple_val_properties.rb`

Read this file and check EVERY wrapper class:
- CharacterSpacing
- Kerning
- Position
- TextExpansion  
- EmphasisMark
- Language

**For each class, verify**:
1. ✅ `attribute :val` comes BEFORE `xml do` block
2. ✅ `map_attribute 'val', to: :val` exists
3. ✅ Uses `namespace Ooxml::Namespaces::WordProcessingML`
4. Consider adding `render_default: true` if needed

**Example fix**:
```ruby
class CharacterSpacing < Lutaml::Model::Serializable
  # ✅ Attribute FIRST
  attribute :val, :integer
  
  xml do
    element 'spacing'
    namespace Ooxml::Namespaces::WordProcessingML
    
    # ✅ Mapping AFTER
    map_attribute 'val', to: :val
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

Target: 12/12 tests passing

### Step 5: Update Status

Edit `IMPLEMENTATION_STATUS.md`:
- Mark completed tasks with [x]
- Update test pass count
- Document any issues found
- Add lessons learned

## Files You'll Need

**Read these first**:
1. `ENHANCED_PROPERTIES_ROUND_TRIP_CONTINUATION_PLAN.md` - Full plan
2. `IMPLEMENTATION_STATUS.md` - Current status
3. `.kilocode/rules/memory-bank/` - Architecture docs

**Files to modify**:
1. `lib/uniword/properties/simple_val_properties.rb` - Wrapper classes
2. `lib/uniword/properties/border.rb` - Border property
3. `lib/uniword/properties/shading.rb` - Shading property
4. `lib/uniword/properties/tab_stop.rb` - TabStop property

**Test file**:
- `test_enhanced_props_focused.rb` - Run this to verify

## Success Criteria

Phase 2 complete when:
- ✅ All 12 enhanced property tests passing
- ✅ Wrapper property values preserved (not empty)
- ✅ Complex property values preserved
- ✅ Round-trip verified: save → load → compare values

## Important Notes

1. **Don't skip diagnosis** - Understanding the root cause saves time
2. **Test incrementally** - Fix one class, test, then continue
3. **Follow attribute-before-mapping rule** - This is critical
4. **Update status doc** - Keep implementation_status.md current
5. **Read memory bank** - Architecture context in `.kilocode/rules/memory-bank/`

## Expected Timeline

- Diagnosis: 15 minutes
- Fix wrapper classes: 45 minutes
- Fix complex properties: 30 minutes
- Testing: 15 minutes
- Documentation: 15 minutes
- **Total: ~2 hours**

## If You Get Stuck

1. Check if attribute is defined before xml block
2. Verify map_attribute matches attribute name
3. Check namespace is WordProcessingML
4. Look at working boolean properties as reference
5. Compare with Body class (working example)

## After Phase 2 Complete

1. Run full test suite: `bundle exec rspec`
2. Update README.adoc with enhanced properties
3. Move continuation plans to old-docs/
4. Create v1.1.0 release notes

---

**Start here**: Step 1 - Diagnose by examining the saved XML to understand root cause.

Good luck! 🚀
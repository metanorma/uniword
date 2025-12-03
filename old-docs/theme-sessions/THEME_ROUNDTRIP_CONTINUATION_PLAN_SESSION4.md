# Theme Round-Trip Session 4: Continuation Plan (UPDATED)

## Current State (End of Session 3)

**Test Results**: 149/174 passing (86%) ✅ **+4 THEMES FIXED!**
**Empty Attribute Issue**: ✅ SOLVED using `value_map`

**Session 3 Victory**:
```ruby
# lib/uniword/font_scheme.rb - THE FIX THAT WORKED
map_attribute 'typeface', to: :typeface, value_map: {
  to: { empty: :empty, nil: :empty, omitted: :omitted }
}
```

**Issue Breakdown**:
1. ✅ Empty attributes: FIXED (4 simple themes passing)
2. ⏳ Element position: ~20 themes - **FIXABLE with `ordered`**
3. ⏳ Text content: ~5 themes - **FIXABLE with missing child elements**

## Session 4 Objectives

### Goal: Achieve 100% Pass Rate (174/174)
**Current**: 149/174 (86%)
**Target**: 174/174 (100%)
**Strategy**: Fix element ordering + missing child elements

## Two Remaining Issues

### Issue 1: Element Position (Priority 1)

**Problem**: Color modifiers appearing in different order within SchemeColor/SrgbColor

```xml
<!-- Original -->
<schemeClr val="phClr">
  <tint val="95000"/>
  <alpha val="60000"/>
  <satMod val="109000"/>
</schemeClr>

<!-- Our output (WRONG ORDER) -->
<schemeClr val="phClr">
  <tint val="95000"/>
  <satMod val="109000"/>  ← Wrong position
  <alpha val="60000"/>    ← Wrong position
</schemeClr>
```

**Root Cause**: Without `ordered`, lutaml-model serializes in attribute declaration order, not parsing order

**The Solution**: Add `ordered` to preserve element order

**Reference**: `/Users/mulgogi/src/lutaml/lutaml-model/docs/_guides/xml-mapping.adoc` lines 367-466

**Implementation**:
```ruby
# lib/uniword/drawingml/scheme_color.rb
class SchemeColor < Lutaml::Model::Serializable
  attribute :val, :string
  attribute :tint, Tint
  attribute :shade, Shade
  attribute :alpha, Alpha
  # ... all 10 modifiers

  xml do
    element 'schemeClr'
    namespace Ooxml::Namespaces::DrawingML
    ordered  # ✅ THE FIX - Preserves parsing order!

    map_attribute 'val', to: :val
    map_element 'tint', to: :tint, render_nil: false
    map_element 'shade', to: :shade, render_nil: false
    map_element 'alpha', to: :alpha, render_nil: false
    # ... all mappings
  end
end
```

**Files to Modify** (2):
1. `lib/uniword/drawingml/scheme_color.rb` - Add `ordered`
2. `lib/uniword/drawingml/srgb_color.rb` - Add `ordered`

**Time**: 30 minutes
**Impact**: 149/174 → 164-169/174 (94-97%)

### Issue 2: Text Content / Missing Children (Priority 2)

**Problem**: Missing child elements in Scene3D, Shape3D, BlipFill

```xml
<!-- Original -->
<scene3d>
  <camera prst="orthographicFront">
    <rot lat="0" lon="0" rev="0"/>
  </camera>
  <lightRig rig="threePt" dir="tl"/>
</scene3d>

<!-- Our output -->
(empty - children not serialized)
```

**Root Cause**: Scene3D, Shape3D, BlipFill classes missing child element mappings

**Solution**: Add missing child elements to these classes

**Files to Investigate** (3):
1. `lib/uniword/drawingml/scene_3d.rb` - Add Camera, LightRig children
2. `lib/uniword/drawingml/shape_3d.rb` - Add BevelT, ContourClr children
3. `lib/uniword/drawingml/blip_fill.rb` - Add Blip, Tile/Stretch children

**Time**: 1-2 hours
**Impact**: 164-169/174 → 174/174 (100%)

## Detailed Implementation Plan

### Phase 1: Element Position Fix (30 minutes)

#### Step 1: Update SchemeColor (10 min)
```ruby
# lib/uniword/drawingml/scheme_color.rb - line ~15
xml do
  element 'schemeClr'
  namespace Ooxml::Namespaces::DrawingML
  ordered  # ✅ ADD THIS LINE
```

#### Step 2: Update SrgbColor (10 min)
```ruby
# lib/uniword/drawingml/srgb_color.rb - line ~15
xml do
  element 'srgbClr'
  namespace Ooxml::Namespaces::DrawingML
  ordered  # ✅ ADD THIS LINE
```

#### Step 3: Test (10 min)
```bash
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb --format progress
# Expected: 149/174 → 164-169/174
```

### Phase 2: Missing Child Elements (1-2 hours)

#### Step 1: Analyze Scene3D Structure (20 min)
```bash
# Extract themes with scene3d issues
grep -l "scene3d" references/word-package/office-themes/*.thmx
unzip -p {theme}.thmx theme/theme/theme1.xml | grep -A 10 "<a:scene3d"
```

#### Step 2: Add Scene3D Children (40 min)
Create if not exists:
- `lib/uniword/drawingml/camera.rb`
- `lib/uniword/drawingml/light_rig.rb`
- `lib/uniword/drawingml/rotation.rb`

Update Scene3D:
```ruby
attribute :camera, Camera
attribute :light_rig, LightRig

xml do
  map_element 'camera', to: :camera, render_nil: false
  map_element 'lightRig', to: :light_rig, render_nil: false
end
```

#### Step 3: Add Shape3D Children (40 min)
Similar pattern for Shape3D elements

#### Step 4: Add BlipFill Children (40 min)
Similar pattern for BlipFill elements

#### Step 5: Test (20 min)
```bash
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb
# Expected: 169+/174 → 174/174 (100%)!
```

### Phase 3: Documentation (30 minutes)

#### Update Status Docs (30 min)
- Mark Session 4 complete in status tracker
- Update memory bank with Session 4 completion
- Document the two solutions that worked

## Success Metrics

### Target Outcome
- **Tests**: 174/174 (100%) ✅
- **Empty Attrs**: Fixed via `value_map`
- **Element Order**: Fixed via `ordered`
- **Missing Elements**: Fixed via proper child mappings
- **Architecture**: Perfect compliance maintained

### Timeline

**Total Session 4**: 2-3 hours
- Phase 1 (Element Position): 30 minutes
- Phase 2 (Missing Children): 1-2 hours
- Phase 3 (Documentation): 30 minutes

## The Two Solutions That Worked

### Solution 1: Empty Attributes ✅ (Session 3)

**Problem**: `<ea typeface=""/>` → `<ea/>`

**Fix**:
```ruby
map_attribute 'typeface', to: :typeface, value_map: {
  to: { empty: :empty, nil: :empty, omitted: :omitted }
}
```

**Result**: 145/174 → 149/174 (+4 themes)

### Solution 2: Element Ordering (Session 4)

**Problem**: Color modifiers in wrong order

**Fix**:
```ruby
xml do
  ordered  # Preserves parsing order
end
```

**Expected Result**: 149/174 → 164-169/174 (+15-20 themes)

## Architectural Principles Maintained

✅ **Model-driven**: No raw XML
✅ **MECE**: Clear separation
✅ **Pattern 0**: Attributes before xml (100%)
✅ **Object-oriented**: Proper inheritance
✅ **Lutaml-model features**: Using built-in `value_map` and `ordered`

❌ **No shortcuts**
❌ **No hacks**
❌ **No lowered standards**

## Risk Register Updated

| Risk | Status | Notes |
|------|--------|-------|
| Empty attributes unfixable | ✅ SOLVED | Used value_map |
| Element position complex | ✅ SIMPLE | Just add ordered |
| Text content complex | ⏳ TBD | Need to add child elements |
| Lutaml-model limitations | ✅ NONE | All features available |

## Next Steps After Session 4

**If 174/174 achieved**:
1. ✅ Phase 3 Week 2 COMPLETE
2. ✅ Update RELEASE_NOTES with 100% theme support
3. ✅ Celebrate architectural victory!

**If 169-173/174** (very close):
1. ✅ Document remaining specific cases
2. ✅ 97-99% is excellent
3. ✅ Plan targeted fixes for last cases

## Key Learnings

1. **Read the docs first** - value_map and ordered were both documented!
2. **Lutaml-model is powerful** - Has features for exactly these cases
3. **Simple solutions exist** - No need for complex refactoring
4. **Architecture wins** - Staying model-driven led to clean fixes

## Timeline Compression

**Original Estimate**: 4-6 hours
**Actual Estimate**: 2-3 hours
**Why Faster**: Solutions are simpler than anticipated

**Session 4 can achieve 100%!** 🎯
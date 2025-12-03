# Theme Round-Trip Session 4 - Continuation Prompt (UPDATED)

**Copy this entire section to start Session 4**

---

## 🎯 Current Status

**Test Results**: 149/174 passing (86%) ✅ **+4 themes fixed in Session 3!**  
**Empty Attribute Issue**: ✅ SOLVED using `value_map`

## ✅ Session 3 Complete - THE BREAKTHROUGH!

**The Victory**: Empty attribute issue SOLVED using lutaml-model's built-in `value_map`:

```ruby
# lib/uniword/font_scheme.rb
class EaFont < FontTypeface
  xml do
    map_attribute 'typeface', to: :typeface, value_map: {
      to: { empty: :empty, nil: :empty, omitted: :omitted }
    }
  end
end
```

**Result**: 145/174 (83%) → 149/174 (86%) = +4 themes ✅

**Key Learning**: Lutaml-model ALREADY had the feature - we just needed to read the docs!

## 🎯 Session 4 Objective

**Goal**: Achieve **174/174 (100%)** by fixing remaining TWO issues

**Remaining**:
1. Element position (15-20 themes) - Fix with `ordered: true`
2. Missing children (5-10 themes) - Add Scene3D/Shape3D/BlipFill children

**Estimated Time**: 2-3 hours (much simpler than originally thought!)

## 📋 Session 4 Tasks

### Task 1: Fix Element Position with `ordered: true` (30 minutes!)

**Problem**: Color modifiers serializing in wrong order

**Solution**: Add `ordered: true` to SchemeColor and SrgbColor xml blocks

**Reference**: `/Users/mulgogi/src/lutaml/lutaml-model/docs/_guides/xml-mapping.adoc` lines 367-466

**FROM THE DOCS**:
```ruby
xml do
  root "RootOrderedContent", ordered: true  # ✅ Preserves element order
  map_element :bold, to: :bold
  map_element :italic, to: :italic
end
```

**Implementation Steps**:

**Step 1**: Update [`scheme_color.rb`](lib/uniword/drawingml/scheme_color.rb) (10 min)
```ruby
xml do
  element 'schemeClr'
  namespace Ooxml::Namespaces::DrawingML
  ordered: true  # ✅ ADD THIS LINE - line ~16
  
  map_attribute 'val', to: :val
  # ... keep all existing mappings
end
```

**Step 2**: Update [`srgb_color.rb`](lib/uniword/drawingml/srgb_color.rb) (10 min)
```ruby
xml do
  element 'srgbClr'
  namespace Ooxml::Namespaces::DrawingML
  ordered: true  # ✅ ADD THIS LINE - line ~16
  
  map_attribute 'val', to: :val
  # ... keep all existing mappings
end
```

**Step 3**: Test (10 min)
```bash
cd /Users/mulgogi/src/mn/uniword
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb --format progress
# Expected: 149/174 → 164-169/174 (94-97%)
```

**Expected Impact**: Fix 15-20 themes with element_position issues

### Task 2: Add Missing Child Elements (1-2 hours)

**Problem**: Scene3D, Shape3D, BlipFill missing child element definitions

**Themes Affected**: ~5-10 themes showing text_content or missing element errors

**Investigation Steps**:

**Step 1**: Identify patterns (20 min)
```bash
# Check which themes have these issues
grep -A 20 "scene3d\|sp3d\|blipFill" theme_failures_detailed.txt | head -100

# Extract one theme to examine structure
unzip -p references/word-package/office-themes/Parcel.thmx theme/theme/theme1.xml | grep -A 10 "<a:scene3d"
```

**Step 2**: Add Scene3D children (40 min)

Check if these exist, create if missing:
- `lib/uniword/drawingml/camera.rb`
- `lib/uniword/drawingml/light_rig.rb`
- `lib/uniword/drawingml/rotation.rb`

Update Scene3D:
```ruby
attribute :camera, Camera
attribute :light_rig, LightRig

xml do
  ordered: true  # Important for 3D elements too
  map_element 'camera', to: :camera, render_nil: false
  map_element 'lightRig', to: :light_rig, render_nil: false
end
```

**Step 3**: Add Shape3D children (40 min)

Similar pattern - add BevelT, ContourClr, etc.

**Step 4**: Add BlipFill children (40 min)

Add Blip, Duotone, Tile, Stretch elements

**Step 5**: Test (20 min)
```bash
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb
# Expected: 169/174 → 174/174 (100%)!
```

## 🎯 Success Criteria

### Must Achieve
- ✅ `ordered: true` added to SchemeColor and SrgbColor
- ✅ Missing child elements investigated and added
- ✅ 170+/174 tests passing (98%+)
- ✅ Architecture maintained (no shortcuts)

### Stretch Goal
- ⭐ 174/174 tests passing (100%)!
- ⭐ ALL themes round-trip perfectly
- ⭐ Complete OOXML compliance

### Not Acceptable
- ❌ Architectural compromises
- ❌ Skipping investigation
- ❌ Lowering standards

## 📁 Key Files

**Planning**:
- [`THEME_ROUNDTRIP_CONTINUATION_PLAN_SESSION4.md`](THEME_ROUNDTRIP_CONTINUATION_PLAN_SESSION4.md) - This plan (updated)
- [`THEME_ROUNDTRIP_STATUS_SESSION4.md`](THEME_ROUNDTRIP_STATUS_SESSION4.md) - Status tracker

**Implementation** (to modify):
- [`lib/uniword/drawingml/scheme_color.rb`](lib/uniword/drawingml/scheme_color.rb) - Add ordered: true
- [`lib/uniword/drawingml/srgb_color.rb`](lib/uniword/drawingml/srgb_color.rb) - Add ordered: true
- [`lib/uniword/drawingml/scene_3d.rb`](lib/uniword/drawingml/scene_3d.rb) - Add children
- [`lib/uniword/drawingml/shape_3d.rb`](lib/uniword/drawingml/shape_3d.rb) - Add children
- [`lib/uniword/drawingml/blip_fill.rb`](lib/uniword/drawingml/blip_fill.rb) - Add children

**Test**:
- `spec/uniword/theme_roundtrip_spec.rb` - 174 test examples

**Lutaml-Model Docs**:
- `/Users/mulgogi/src/lutaml/lutaml-model/docs/_guides/xml-mapping.adoc` - Element ordering docs
- `/Users/mulgogi/src/lutaml/lutaml-model/docs/_guides/missing-values-handling.adoc` - value_map docs

## 🚀 START HERE

```bash
cd /Users/mulgogi/src/mn/uniword

# Step 1: Verify current state (should be 149/174)
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb --format progress

# Step 2: Add ordered: true to SchemeColor
# Edit lib/uniword/drawingml/scheme_color.rb line ~16

# Step 3: Add ordered: true to SrgbColor  
# Edit lib/uniword/drawingml/srgb_color.rb line ~16

# Step 4: Test
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb --format progress
# Expect major improvement!
```

## 🎓 Key Insights from Session 3

1. **`value_map` is the solution** for empty attribute preservation
2. **`ordered: true`** preserves XML element order (next fix!)
3. **Lutaml-model docs have answers** - read them first!
4. **Simple solutions exist** - no need for complex refactoring

## ⚠️ Critical Reminders

1. **Pattern 0 always**: Attributes BEFORE xml blocks
2. **Test after each change**: Keep tests green
3. **Use render_nil: false**: For optional elements
4. **Maintain MECE**: Each class one responsibility
5. **Document as you go**: Update status tracker

## 📊 Progress Tracking

| Milestone | Tests | % | Status |
|-----------|-------|---|--------|
| Session 1 Start | 145/174 | 83% | ✅ Complete |
| Session 2 Complete | 145/174 | 83% | ✅ Complete |
| Session 3 Complete | 149/174 | 86% | ✅ Complete (+4!) |
| Session 4 Phase 1 Target | 164/174 | 94% | ⏳ Next |
| Session 4 Final Target | 174/174 | 100% | 🎯 Goal |

## 🎯 Decision Points

**After Phase 1 (`ordered: true` fix)**:

- If 164+/174: ✅ Proceed to Phase 2 (missing children)
- If 155-163/174: ⚠️ Investigate ordering edge cases, then Phase 2
- If <155/174: ❌ Re-analyze, something unexpected

**After Phase 2 (missing children)**:

- If 174/174: ✅✅✅ VICTORY! Document and celebrate
- If 170-173/174: ✅ Excellent! Document specific remaining cases
- If <170/174: ⚠️ Deep dive on remaining failures

## Post-Session 4 Actions

1. Update memory bank with Session 4 completion
2. Update RELEASE_NOTES.md with 100% theme support (or actual %)
3. Archive Session 4 documents to old-docs/
4. Begin Phase 3 Week 3 (document elements) OR celebrate completion!

---

**Good luck!** The solutions are simple - just add `ordered: true` and missing child elements. 100% is within reach! 🚀
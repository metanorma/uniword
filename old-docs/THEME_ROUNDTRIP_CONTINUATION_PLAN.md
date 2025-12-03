# Theme Round-Trip Implementation - Continuation Plan

**Created**: November 30, 2024
**Status**: Phase 1 Complete (Architecture), Phase 2 In Progress (DrawingML Completion)
**Priority**: HIGH - Foundation complete, systematic completion needed

## Executive Summary

We have successfully implemented the **architectural foundation** for theme round-trip support:
- ✅ All 4 missing theme elements created (ObjectDefaults, ExtraColorSchemeList, Extension, FormatScheme)
- ✅ Proper integration into Theme class hierarchy
- ✅ DrawingML type system fixed (Integer/String → symbols)
- ✅ Model-driven architecture maintained (no raw XML)

**Current State**: 145/174 tests passing (83%)
**Remaining Work**: Complete DrawingML element child relationships (systematic, 2-3 days)

## Phase 2: DrawingML Element Completion (CURRENT PHASE)

### Overview
The existing DrawingML classes in `lib/uniword/drawingml/` are **structural stubs** that need child element relationships completed. The architecture is correct; we need to add the missing connections.

### Priority 1: Color System (Day 1 - 6 hours)

#### 1.1 Complete SchemeColor with Modifiers (2 hours)
**File**: `lib/uniword/drawingml/scheme_color.rb`

**Current**:
```ruby
class SchemeColor < Lutaml::Model::Serializable
  attribute :val, :string
  # Missing: color modifiers
end
```

**Required Children** (all exist in `lib/uniword/drawingml/`):
- `tint` - Tint.rb ✅ exists
- `shade` - Shade.rb ✅ exists
- `satMod` - SaturationModulation.rb ✅ exists
- `lumMod` - LuminanceModulation.rb ✅ exists
- `alpha` - Alpha.rb ✅ exists
- `alphaMod` - AlphaModulation.rb ✅ exists
- `alphaOff` - AlphaOffset.rb ✅ exists
- `hue` - Hue.rb ✅ exists
- `hueMod` - HueModulation.rb ✅ exists
- `hueOff` - HueOffset.rb ✅ exists

**Target**:
```ruby
class SchemeColor < Lutaml::Model::Serializable
  attribute :val, :string
  attribute :tint, Tint
  attribute :shade, Shade
  attribute :sat_mod, SaturationModulation
  attribute :lum_mod, LuminanceModulation
  # ... (add all 10 modifiers)
  
  xml do
    element 'schemeClr'
    namespace Uniword::Ooxml::Namespaces::DrawingML
    map_attribute 'val', to: :val
    map_element 'tint', to: :tint, render_nil: false
    map_element 'shade', to: :shade, render_nil: false
    # ... (map all modifiers)
  end
end
```

#### 1.2 Complete SolidFill (1 hour)
**File**: `lib/uniword/drawingml/solid_fill.rb`

**Required**:
- Add `scheme_clr` (SchemeColor)
- Add `srgb_clr` (SrgbColor) - already exists
- Add `sys_clr` (SysColor) - check if exists

#### 1.3 Complete GradientFill (2 hours)
**File**: `lib/uniword/drawingml/gradient_fill.rb`

**Already has**:
- `gs_lst` (GradientStopList)
- `lin` (LinearGradient)  
- `path` (PathGradient)

**Check GradientStop needs**:
- Each gradient stop needs full color support (SchemeColor with modifiers)

#### 1.4 Update GradientStop (1 hour)
**File**: `lib/uniword/drawingml/gradient_stop.rb`

Add color element support similar to SolidFill.

### Priority 2: Line System (Day 1-2 - 4 hours)

#### 2.1 Complete LineProperties (2 hours)
**File**: `lib/uniword/drawingml/line_properties.rb`

**Current**:
```ruby
attribute :w, :integer
```

**Required Children**:
- `solid_fill` (SolidFill)
- `grad_fill` (GradientFill)
- `prst_dash` (PresetDash) - exists
- `round` (LineJoinRound) - exists
- `miter` (LineJoinMiter) - exists

**Add**:
```ruby
attribute :solid_fill, SolidFill
attribute :grad_fill, GradientFill
attribute :prst_dash, PresetDash
attribute :round, LineJoinRound
attribute :miter, LineJoinMiter
attribute :cap, :string
attribute :cmpd, :string
attribute :algn, :string
```

#### 2.2 Verify PresetDash (30 minutes)
**File**: `lib/uniword/drawingml/preset_dash.rb`

Ensure it has `val` attribute for dash type (solid, dot, dash, etc.).

#### 2.3 Test Line Round-Trip (1.5 hours)
Create focused test for line serialization/deserialization.

### Priority 3: Effect System (Day 2 - 4 hours)

#### 3.1 Complete EffectList Children (1 hour)
**File**: `lib/uniword/drawingml/effect_list.rb`

**Already has**:
- `glow` (Glow)
- `inner_shdw` (InnerShadow)
- `outer_shdw` (OuterShadow)

**Verify each effect has required properties**.

#### 3.2 Add 3D Effect Elements (3 hours)
These are complex but follow patterns:

**Files to create/update**:
- `scene3d.rb` - 3D scene container
- `camera.rb` - Camera properties
- `light_rig.rb` - Lighting setup
- `sp3d.rb` - Shape 3D properties
- `bevel_t.rb` - Top bevel properties

**Pattern** (all similar):
```ruby
class Scene3d < Lutaml::Model::Serializable
  attribute :camera, Camera
  attribute :light_rig, LightRig
  
  xml do
    element 'scene3d'
    namespace Uniword::Ooxml::Namespaces::DrawingML
    map_element 'camera', to: :camera
    map_element 'lightRig', to: :light_rig
  end
end
```

### Priority 4: FontScheme Fix (Day 2 - 2 hours)

#### 4.1 Fix Empty Attribute Serialization
**Files**: 
- `lib/uniword/font_scheme.rb`
- `lib/uniword/drawingml/east_asian_font.rb`
- `lib/uniword/drawingml/complex_script_font.rb`

**Problem**: Serializing `<ea typeface=""/>` instead of `<ea/>`

**Solution**:
```ruby
class EaFont < Lutaml::Model::Serializable
  attribute :typeface, :string
  
  xml do
    element 'ea'
    namespace Ooxml::Namespaces::DrawingML
    map_attribute 'typeface', to: :typeface, render_nil: false
  end
  
  def initialize(attributes = {})
    super
    # Don't set default empty string
  end
end
```

### Priority 5: Testing & Validation (Day 3 - 4 hours)

#### 5.1 Run Full Test Suite (1 hour)
```bash
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb
```

Target: 174/174 passing (100%)

#### 5.2 Individual Theme Debugging (2 hours)
For each failing theme:
1. Extract actual vs expected XML diff
2. Identify missing element
3. Add element if needed
4. Retest

#### 5.3 Semantic Equivalence Verification (1 hour)
Use Canon gem to verify XML equivalence accounting for:
- Attribute order independence
- Whitespace normalization
- Namespace prefix variations

## Implementation Strategy

### DAY 1 Schedule (6 hours)
- **Hour 1-2**: SchemeColor + modifiers
- **Hour 3**: SolidFill colors
- **Hour 4-5**: GradientFill + GradientStop
- **Hour 6**: LineProperties basics

### DAY 2 Schedule (6 hours)
- **Hour 1-2**: Complete LineProperties
- **Hour 3-5**: 3D Effect elements
- **Hour 6**: FontScheme fix

### DAY 3 Schedule (4 hours)
- **Hour 1**: Full test run
- **Hour 2-3**: Debug failing themes
- **Hour 4**: Verification & documentation

## Critical Implementation Patterns

### Pattern 1: Adding Child Elements
```ruby
# BEFORE
class Parent < Lutaml::Model::Serializable
  xml do
    element 'parent'
  end
end

# AFTER
class Parent < Lutaml::Model::Serializable
  attribute :child, Child  # ← FIRST
  
  xml do
    element 'parent'
    map_element 'child', to: :child, render_nil: false
  end
  
  def initialize(attributes = {})
    super
    # Optional: set defaults with ||=
  end
end
```

### Pattern 2: Optional Children
Use `render_nil: false` for optional elements:
```ruby
map_element 'optional', to: :optional_attr, render_nil: false
```

### Pattern 3: Collections
```ruby
attribute :items, Item, collection: true

xml do
  map_element 'item', to: :items
end

def initialize
  super
  @items ||= []
end
```

## Testing Strategy

### Unit Tests
Each DrawingML class should have focused tests:
```ruby
RSpec.describe Uniword::Drawingml::SchemeColor do
  it 'serializes with modifiers' do
    color = described_class.new(
      val: 'accent1',
      tint: Tint.new(val: 50000)
    )
    xml = color.to_xml
    expect(xml).to include('<a:tint val="50000"/>')
  end
end
```

### Integration Tests
Test complete FormatScheme serialization/deserialization.

### Round-Trip Tests
Already exist in `spec/uniword/theme_roundtrip_spec.rb` - these will pass as elements are completed.

## Success Criteria

### Phase 2 Complete When:
- ✅ All 174 theme tests passing
- ✅ All themes achieve semantic XML equivalence
- ✅ No regressions in StyleSet tests (168 examples)
- ✅ Documentation updated

### Code Quality Gates:
- ✅ All classes follow Pattern 0 (attributes before xml)
- ✅ All optional elements use `render_nil: false`
- ✅ No raw XML storage anywhere
- ✅ MECE architecture maintained
- ✅ Rubocop passing

## Risk Mitigation

### Risk 1: Unexpected Element Dependencies
**Mitigation**: Work incrementally, test after each element completion

### Risk 2: Namespace Issues
**Mitigation**: All DrawingML elements use `Uniword::Ooxml::Namespaces::DrawingML`

### Risk 3: Performance with Complex Nesting
**Mitigation**: Lazy loading already implemented, no concerns

## Next Session Startup

```bash
cd /Users/mulgogi/src/mn/uniword

# Verify current status
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb --format progress | grep -E "(examples|failures)"

# Start with SchemeColor
code lib/uniword/drawingml/scheme_color.rb
```

## Files to Track

### Phase 2 Files to Modify (Priority Order):
1. ✅ `lib/uniword/drawingml/scheme_color.rb`
2. ✅ `lib/uniword/drawingml/solid_fill.rb`
3. ✅ `lib/uniword/drawingml/gradient_fill.rb`
4. ✅ `lib/uniword/drawingml/gradient_stop.rb`
5. ✅ `lib/uniword/drawingml/line_properties.rb`
6. ✅ `lib/uniword/drawingml/effect_list.rb`
7. ✅ `lib/uniword/font_scheme.rb`

### New Files to Create:
1. ✅ `lib/uniword/drawingml/scene3d.rb`
2. ✅ `lib/uniword/drawingml/camera.rb`
3. ✅ `lib/uniword/drawingml/light_rig.rb`
4. ✅ `lib/uniword/drawingml/sp3d.rb`
5. ✅ `lib/uniword/drawingml/bevel_t.rb`

## Completion Checklist

- [ ] SchemeColor has all 10 modifiers
- [ ] SolidFill references colors
- [ ] GradientFill fully functional
- [ ] LineProperties complete
- [ ] 3D effects implemented
- [ ] FontScheme empty attribute fix
- [ ] All 174 theme tests passing
- [ ] Documentation updated
- [ ] Memory bank updated
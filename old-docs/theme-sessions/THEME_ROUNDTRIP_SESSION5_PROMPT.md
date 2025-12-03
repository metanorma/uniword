# Theme Round-Trip Session 5: Continuation Prompt

## Context

You are continuing the Uniword theme round-trip implementation. Session 4 achieved 162/174 (93%) by creating 3D architecture (Scene3D, Shape3D, etc.) and enhancing various DrawingML elements. Session 5 aims to reach 100% (174/174).

## Current State

**Test Results**: 162/174 passing (93%)
**Remaining Failures**: 12 themes
**Architecture**: Perfect compliance with all principles ✅

### Session 4 Accomplishments
- Created 7 new 3D classes: Scene3D, Shape3D, Camera, LightRig, Rotation, BevelTop, Tile
- Enhanced 11 existing classes: Reflection, EffectList, InnerShadow, OuterShadow, LineProperties, etc.
- Fixed 13 themes (149 → 162)
- Zero regressions (StyleSet 168/168 still passing)

### Failing Themes (12)
1. Parallax
2. Main Event
3. Celestial
4. Ion Boardroom
5. Ion
6. Savon
7. Madison
8. Organic
9. Integral
10. Mesh
11. Office Theme
12. Wood Type

## Your Task

**Objective**: Achieve 174/174 (100%) theme round-trip ✅

**Strategy**: Systematic analysis → Targeted fixes → Verification

**Time Budget**: 2-3 hours

## Step-by-Step Instructions

### Step 1: Analyze Failures (30 min)

Run ONE failing theme to see the exact diff:
```bash
cd /Users/mulgogi/src/mn/uniword
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb[1:21:4] --format documentation
```

Identify patterns:
1. What elements are missing?
2. What attributes are missing?
3. Are issues in EffectList or BlipFill?

Create categories:
- **EffectList issues**: Missing fillOverlay, glow integration, etc.
- **BlipFill issues**: Missing srcRect, fillRect, etc.
- **Misc issues**: Any other patterns

### Step 2: Check Existing Classes (15 min)

Before creating new classes, verify what exists:
```bash
ls lib/uniword/drawingml/glow.rb
ls lib/uniword/drawingml/fill_overlay.rb
ls lib/uniword/drawingml/source_rect.rb
```

Read these files to understand current implementation:
```ruby
read_file('lib/uniword/drawingml/glow.rb')
read_file('lib/uniword/drawingml/fill_overlay.rb')
read_file('lib/uniword/drawingml/source_rect.rb')
```

### Step 3: Implement Highest-Impact Fixes (90 min)

#### 3A: EffectList Enhancements (45 min)

If missing from EffectList, add:
- fillOverlay (check if already exists in file)
- glow (check if already exists in file)

**Pattern to follow**:
```ruby
# lib/uniword/drawingml/effect_list.rb
attribute :fill_overlay, FillOverlay
attribute :glow, Glow

xml do
  map_element 'fillOverlay', to: :fill_overlay, render_nil: false
  map_element 'glow', to: :glow, render_nil: false
end
```

Test after each addition:
```bash
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb --format progress
```

**Expected**: +3-5 themes fixed

#### 3B: BlipFill Enhancements (45 min)

Add missing children to BlipFill:
```ruby
# lib/uniword/drawingml/blip_fill.rb
attribute :src_rect, SourceRect
# Create FillRect if it doesn't exist

xml do
  map_element 'srcRect', to: :src_rect, render_nil: false
end
```

If FillRect doesn't exist, create it following pattern:
```ruby
# lib/uniword/drawingml/fill_rect.rb
class FillRect < Lutaml::Model::Serializable
  attribute :l, :integer
  attribute :t, :integer
  attribute :r, :integer
  attribute :b, :integer
  
  xml do
    element 'fillRect'
    namespace Uniword::Ooxml::Namespaces::DrawingML
    
    map_attribute 'l', to: :l, render_nil: false
    # ... etc
  end
end
```

Test after each addition.

**Expected**: +4-6 themes fixed

### Step 4: Handle Remaining Issues (35 min)

After Steps 3A and 3B, you should have 1-3 themes remaining. For each:

1. Run that specific test to see exact diff
2. Identify the missing element/attribute
3. Implement targeted fix
4. Test immediately

Use Session 4 as a model - we created 7 classes following the same patterns.

### Step 5: Verification (15 min)

Final checks:
```bash
# Theme tests
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb --format progress

# StyleSet tests (verify no regressions)
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb --format progress
```

**Target**: 174/174 themes + 168/168 StyleSets = 342/342 total ✅

### Step 6: Update Documentation (30 min)

After reaching 100%:

1. Update status tracker:
```ruby
edit_file('THEME_ROUNDTRIP_SESSION5_STATUS.md')
# Mark all phases complete
# Document final test results
```

2. Update memory bank:
```ruby
edit_file('.kilocode/rules/memory-bank/context.md')
# Update "Current State" section
# Mark Phase 3 Week 2 complete
# Document 100% achievement
```

3. Move temporary docs:
```bash
mkdir -p old-docs/theme-sessions
mv THEME_ROUNDTRIP_SESSION*.md old-docs/theme-sessions/
mv THEME_ROUNDTRIP_CONTINUATION*.md old-docs/theme-sessions/
mv theme_failures_*.txt old-docs/theme-sessions/ (if any exist)
```

## Critical Architecture Principles

### Pattern 0: ALWAYS Followed ✅
```ruby
# ✅ CORRECT - Attributes FIRST
class MyClass < Lutaml::Model::Serializable
  attribute :my_attr, MyType
  
  xml do
    map_element 'elem', to: :my_attr
  end
end
```

### MECE: Clear Separation ✅
- Each class has ONE clear responsibility
- No overlap between EffectList and BlipFill
- Proper hierarchy (Scene3D → Camera, LightRig)

### Model-Driven: No Raw XML ✅
- Every element is a proper lutaml-model class
- No string-based XML manipulation
- All serialization through lutaml-model

### Object-Oriented: Composition ✅
- Use inheritance where appropriate
- Favor composition (has-a vs is-a)
- Clear parent-child relationships

## Reference Files

**Session 4 Work** (your model):
- `lib/uniword/drawingml/scene_3d.rb` - Parent with children
- `lib/uniword/drawingml/shape_3d.rb` - Parent with children
- `lib/uniword/drawingml/camera.rb` - Child with attributes
- `lib/uniword/format_scheme.rb` - Integration example

**Planning Docs**:
- `THEME_ROUNDTRIP_SESSION5_PLAN.md` - Detailed plan
- `THEME_ROUNDTRIP_SESSION5_STATUS.md` - Progress tracker

## Success Checklist

- [ ] 174/174 theme tests passing (100%)
- [ ] 168/168 StyleSet tests passing (no regressions)
- [ ] All new classes follow Pattern 0
- [ ] MECE architecture maintained
- [ ] Zero raw XML or shortcuts
- [ ] Documentation updated
- [ ] Memory bank updated
- [ ] Temporary docs moved to old-docs/

## Expected Output

At completion, you should have:

**New Files Created** (~0-2):
- `lib/uniword/drawingml/fill_rect.rb` (if needed)
- Any other missing element classes

**Files Modified** (~2-5):
- `lib/uniword/drawingml/effect_list.rb` (add fillOverlay/glow if missing)
- `lib/uniword/drawingml/blip_fill.rb` (add srcRect, fillRect)
- `lib/uniword/drawingml.rb` (autoloads)
- `THEME_ROUNDTRIP_SESSION5_STATUS.md` (mark complete)
- `.kilocode/rules/memory-bank/context.md` (update progress)

**Test Results**:
```
Theme Round-Trip: 174/174 (100%) ✅
StyleSet Round-Trip: 168/168 (100%) ✅
Total: 342/342 (100%) ✅
```

## Key Reminders

1. **Read existing files first** - Don't recreate what exists
2. **Test after each change** - Incremental progress is visible
3. **Follow Session 4 patterns** - They worked perfectly
4. **No shortcuts** - Maintain architecture quality
5. **Update documentation** - Track all changes

## Starting Point

Begin with:
```bash
cd /Users/mulgogi/src/mn/uniword

# Check current state
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb --format progress | grep "examples"
# Should show: 174 examples, 12 failures

# Analyze one failure
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb[1:21:4] --format documentation
```

Then proceed systematically through Steps 1-6.

**Goal**: 174/174 (100%) by end of this session! 🎯

Good luck! The foundation from Session 4 is solid - you just need to add the final missing pieces!
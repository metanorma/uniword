# Uniword: Autoload Migration Week 1 Day 3 - Execution Prompt

**Task**: Migrate WpDrawing and DrawingML modules to explicit autoload  
**Duration**: 2-3 hours  
**Prerequisites**: Read `AUTOLOAD_MIGRATION_WEEK1_DAY3_PLAN.md`  

---

## Quick Context

**Week 1 Day 1 COMPLETE** ✅:
- Migrated Wordprocessingml module (99 explicit autoloads)
- Test results: 113 → 32 failures (72% improvement!)
- Commit: 5dbc903
- Time: 90 minutes (267% efficiency)

**Current State**:
- Total: 99/416 require_relative migrated (24%)
- Week 1: 99/150 namespace modules (66%)
- Baseline tests: 258 examples, 32 failures

---

## Day 3 Objective

Convert two drawing namespace modules from dynamic Dir[] to explicit autoload:
1. **WpDrawing** (~15 classes)
2. **DrawingML** (~25 classes)

**Target**: 40 new autoloads, 139/150 Week 1 progress (93%)

---

## Step-by-Step Execution

### Step 1: Analyze WpDrawing Module (30 min)

Check current state:

```bash
cd /Users/mulgogi/src/mn/uniword

# List all wp_drawing classes
ls -1 lib/uniword/wp_drawing/*.rb

# Read current module file
cat lib/uniword/wp_drawing.rb

# Check for internal require_relative (should be 0)
grep -r "require_relative" lib/uniword/wp_drawing/ --include="*.rb" | grep -v "\.\."
```

**Expected**:
- ~15 .rb files in wp_drawing/
- Current pattern: Dynamic Dir[] or explicit autoload
- Zero internal require_relative

**Action**: Use `list_files` tool on `lib/uniword/wp_drawing/`

### Step 2: Update lib/uniword/wp_drawing.rb (45 min)

Read the current file, then transform to explicit pattern:

```ruby
read_file lib/uniword/wp_drawing.rb
```

**Transform Pattern**:

```ruby
# frozen_string_literal: true

# WpDrawing namespace module
# This file explicitly autoloads all WpDrawing classes
# Using explicit autoload instead of dynamic Dir[] for maintainability

require 'lutaml/model'

module Uniword
  module WpDrawing
    # Drawing Positioning (5-7)
    autoload :Anchor, 'uniword/wp_drawing/anchor'
    autoload :Inline, 'uniword/wp_drawing/inline'
    autoload :SimplePos, 'uniword/wp_drawing/simple_pos'
    autoload :PositionH, 'uniword/wp_drawing/position_h'
    autoload :PositionV, 'uniword/wp_drawing/position_v'
    
    # Size & Dimensions (2-4)
    autoload :Extent, 'uniword/wp_drawing/extent'
    autoload :EffectExtent, 'uniword/wp_drawing/effect_extent'
    
    # Properties (3-5)
    autoload :DocProperties, 'uniword/wp_drawing/doc_properties'
    autoload :NonVisualDrawingProps, 'uniword/wp_drawing/non_visual_drawing_props'
    autoload :NonVisualGraphicFrameProps, 'uniword/wp_drawing/non_visual_graphic_frame_props'
    
    # Wrapping & Layout (3-5)
    autoload :WrapSquare, 'uniword/wp_drawing/wrap_square'
    autoload :WrapNone, 'uniword/wp_drawing/wrap_none'
    autoload :WrapThrough, 'uniword/wp_drawing/wrap_through'
    
    # (Add all discovered classes organized by category)
  end
end
```

**Use**: `write_to_file` tool to update

### Step 3: Analyze DrawingML Module (30 min)

Same process:

```bash
# List all drawingml classes  
ls -1 lib/uniword/drawingml/*.rb

# Read current module file
cat lib/uniword/drawingml.rb

# Check internal require_relative
grep -r "require_relative" lib/uniword/drawingml/ --include="*.rb" | grep -v "\.\."
```

### Step 4: Update lib/uniword/drawingml.rb (60 min)

**Expected Categories**:
- Colors (SchemeColor, SrgbColor, RgbColor, HslColor, SystemColor)
- Fills (SolidFill, GradientFill, NoFill, PatternFill, BlipFill)
- Lines & Borders (LineProperties, Outline, etc.)
- Effects (EffectList, OuterShadow, InnerShadow, Reflection, Glow, SoftEdge)
- 3D & Transform (Scene3D, Shape3D, Camera, LightRig, Transform2D, Rotation)
- Graphics (Graphic, GraphicData, Blip)
- Color Modifiers (Tint, Shade, Alpha, etc.)

**Pattern**:

```ruby
# frozen_string_literal: true

# DrawingML namespace module  
# This file explicitly autoloads all DrawingML classes
# Using explicit autoload instead of dynamic Dir[] for maintainability

require 'lutaml/model'

module Uniword
  module Drawingml
    # Colors (5-7)
    autoload :SchemeColor, 'uniword/drawingml/scheme_color'
    autoload :SrgbColor, 'uniword/drawingml/srgb_color'
    # ... etc
    
    # Fills (5-7)
    autoload :SolidFill, 'uniword/drawingml/solid_fill'
    # ... etc
    
    # (Continue with all categories)
  end
end
```

### Step 5: Test Changes (30 min)

Run baseline tests:

```bash
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb --format progress 2>&1 | grep "examples,"
```

**Expected**: 258 examples, ≤32 failures (same or better than baseline)

**If failures > 32**:
1. Analyze failure patterns
2. Check for typos in autoload paths
3. Verify class name capitalization
4. Revert and debug if needed

### Step 6: Update Status Tracker (15 min)

Update `old-docs/autoload-migration/AUTOLOAD_FULL_MIGRATION_STATUS.md`:

**Week 1 Section**:
```markdown
### Day 3: Drawing Modules ✅ COMPLETE
**Target**: 40 require_relative → autoload
**Actual**: X autoloads (WpDrawing) + Y autoloads (DrawingML)
**Status**: ✅ COMPLETE (December 6, 2024)

**Files migrated**:
- lib/uniword/wp_drawing.rb (X autoloads)
- lib/uniword/drawingml.rb (Y autoloads)

**Test Results**:
- Before: 258 examples, 32 failures
- After: 258 examples, Z failures
- Improvement/Maintenance: [describe]
```

### Step 7: Commit Changes (15 min)

```bash
git add lib/uniword/wp_drawing.rb lib/uniword/drawingml.rb old-docs/autoload-migration/AUTOLOAD_FULL_MIGRATION_STATUS.md

git commit -m "refactor(autoload): Replace dynamic Dir[] with explicit autoload in WpDrawing and DrawingML

- WpDrawing: X explicit autoload statements organized into N categories
- DrawingML: Y explicit autoload statements organized into M categories
- Zero internal require_relative (all external dependencies OK)
- Test results: 258 examples, Z failures (baseline: 32)
- Maintains lazy-loading performance characteristics

Categories WpDrawing:
- [List categories]

Categories DrawingML:
- [List categories]

Progress: Week 1 Day 3 complete ((99+X+Y)/150 namespace modules, Z%)"
```

---

## Success Criteria Checklist

- [ ] WpDrawing module analyzed (~15 classes counted)
- [ ] WpDrawing.rb updated with explicit autoloads
- [ ] DrawingML module analyzed (~25 classes counted)
- [ ] DrawingML.rb updated with explicit autoloads
- [ ] Classes organized into MECE categories
- [ ] Zero internal require_relative in both modules
- [ ] Tests run: 258 examples, ≤32 failures
- [ ] Zero regressions introduced
- [ ] Status tracker updated
- [ ] Semantic commit created

---

## Expected Metrics

| Metric | Before | After | Target |
|--------|--------|-------|--------|
| WpDrawing autoloads | Dynamic | ~15 explicit | ✅ Explicit |
| DrawingML autoloads | Dynamic | ~25 explicit | ✅ Explicit |
| Week 1 progress | 99/150 (66%) | ~139/150 (93%) | >90% |
| Test failures | 32 | ≤32 | ✅ No regression |
| Time taken | - | 2-3 hours | <3 hours |

---

## Troubleshooting

### Issue: More than 40 classes total
**Solution**: Adjust plan, may need to split Day 3 into 3A and 3B

### Issue: Tests regress (>40 failures)
**Solution**: 
1. Check for typos in autoload paths
2. Verify class name capitalization (CamelCase)
3. Compare with working Wordprocessingml pattern
4. Revert if needed, analyze root cause

### Issue: Circular dependencies found
**Solution**: Document as exceptions, keep require_relative if necessary

### Issue: Classes depend on each other
**Solution**: Order doesn't matter with autoload - they lazy-load on first use

---

## Commands Reference

```bash
# Analysis
ls -1 lib/uniword/wp_drawing/*.rb | wc -l
ls -1 lib/uniword/drawingml/*.rb | wc -l
grep -r "require_relative" lib/uniword/wp_drawing/ --include="*.rb"

# Testing
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb --format progress

# Commit
git add lib/uniword/wp_drawing.rb lib/uniword/drawingml.rb old-docs/autoload-migration/AUTOLOAD_FULL_MIGRATION_STATUS.md
git commit -m "refactor(autoload): ..."
```

---

## Reference Files

- **Plan**: `AUTOLOAD_MIGRATION_WEEK1_DAY3_PLAN.md`
- **Status**: `old-docs/autoload-migration/AUTOLOAD_FULL_MIGRATION_STATUS.md`
- **Day 1 Example**: `lib/uniword/wordprocessingml.rb` (99 autoloads, perfect pattern)
- **Baseline Commit**: 5dbc903

---

**Created**: December 6, 2024  
**Status**: Ready to execute  
**Estimated Duration**: 2-3 hours  
**Expected Result**: 40 new autoloads, 139/150 Week 1 (93% complete)
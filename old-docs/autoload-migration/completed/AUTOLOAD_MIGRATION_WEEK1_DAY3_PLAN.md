# Uniword: Autoload Migration Week 1 Day 3 - Drawing Modules Plan

**Date**: December 6, 2024  
**Phase**: Week 1, Day 3 - Drawing Modules  
**Target**: 40 require_relative → autoload  
**Duration**: 2-3 hours (compressed)  

---

## Context

**Week 1 Day 1 Status**: ✅ COMPLETE
- Migrated Wordprocessingml module (99 explicit autoloads)
- Test improvement: 113 → 32 failures (72% reduction)
- Time: 90 minutes (267% efficiency)

**Current State**:
- Total progress: 99/416 require_relative (24%)
- Week 1 progress: 99/150 (66%)
- Remaining Week 1: Drawing modules + Other modules

---

## Day 3 Objectives

Migrate two drawing-related namespace modules to explicit autoload:

### 1. WpDrawing Module (~15 classes)
**File**: `lib/uniword/wp_drawing.rb`  
**Target**: Replace dynamic pattern with ~15 explicit autoloads

**Expected Classes**:
- Anchor, Inline, Extent
- DocProperties, NonVisualDrawingProps
- EffectExtent, WrapSquare, WrapNone
- PositionH, PositionV
- SimplePos, Distance
- Plus others discovered during analysis

### 2. DrawingML Module (~25 classes)
**File**: `lib/uniword/drawingml.rb`  
**Target**: Replace dynamic pattern with ~25 explicit autoloads

**Expected Classes**:
- Graphic, GraphicData, Blip
- SchemeColor, SrgbColor, RgbColor
- SolidFill, GradientFill, NoFill
- LineProperties, FillProperties
- EffectList, Scene3D, Shape3D
- Transform2D, Offset, Extent
- Plus others discovered during analysis

---

## Implementation Steps

### Step 1: Analyze WpDrawing Module (30 min)

```bash
# List all files
ls -1 lib/uniword/wp_drawing/*.rb

# Check current module file
cat lib/uniword/wp_drawing.rb

# Count require_relative in wp_drawing files
grep -r "require_relative" lib/uniword/wp_drawing/ --include="*.rb" | wc -l
```

**Tasks**:
1. Count total classes in `lib/uniword/wp_drawing/`
2. Verify current autoload pattern (dynamic vs explicit)
3. Check for internal require_relative (should be zero)
4. Identify logical categories for organization

### Step 2: Create Explicit Autoloads for WpDrawing (45 min)

**Pattern** (from Wordprocessingml success):
```ruby
# frozen_string_literal: true

# WpDrawing namespace module
# This file explicitly autoloads all WpDrawing classes
# Using explicit autoload instead of dynamic Dir[] for maintainability

require 'lutaml/model'

module Uniword
  module WpDrawing
    # Drawing Positioning (~5)
    autoload :Anchor, 'uniword/wp_drawing/anchor'
    autoload :Inline, 'uniword/wp_drawing/inline'
    autoload :SimplePos, 'uniword/wp_drawing/simple_pos'
    # ... etc
    
    # Size & Dimensions (~3)
    autoload :Extent, 'uniword/wp_drawing/extent'
    # ... etc
    
    # Properties (~5)
    autoload :DocProperties, 'uniword/wp_drawing/doc_properties'
    # ... etc
    
    # Wrapping (~2)
    autoload :WrapSquare, 'uniword/wp_drawing/wrap_square'
    # ... etc
  end
end
```

### Step 3: Analyze DrawingML Module (30 min)

Same process as WpDrawing:
1. Count classes
2. Check current pattern
3. Verify require_relative
4. Identify categories

### Step 4: Create Explicit Autoloads for DrawingML (60 min)

**Expected Categories**:
- Colors (~5 classes)
- Fills (~5 classes)
- Lines & Borders (~3 classes)
- Effects (~5 classes)
- 3D & Transform (~5 classes)
- Graphics (~2 classes)

### Step 5: Test Changes (30 min)

```bash
# Run baseline tests
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb --format progress

# Expected: Same or better than current (258 examples, 32 failures)
# Target: Zero regressions, possible improvements
```

### Step 6: Commit & Document (15 min)

```bash
git add lib/uniword/wp_drawing.rb lib/uniword/drawingml.rb
git commit -m "refactor(autoload): Replace dynamic Dir[] with explicit autoload in WpDrawing and DrawingML

- WpDrawing: X explicit autoload statements
- DrawingML: Y explicit autoload statements  
- Organize into logical categories for maintainability
- Zero internal require_relative (all clean)
- Maintains lazy-loading performance

Progress: Week 1 Day 3 complete (99+X+Y/150 namespace modules)"
```

---

## Success Criteria

1. ✅ WpDrawing module uses explicit autoload (~15 statements)
2. ✅ DrawingML module uses explicit autoload (~25 statements)
3. ✅ Classes organized into logical categories (MECE)
4. ✅ Zero internal require_relative in both modules
5. ✅ Tests maintain current level (258 examples, ≤32 failures)
6. ✅ Zero regressions introduced
7. ✅ Commit with semantic message
8. ✅ Status tracker updated

---

## Expected Outcomes

### Metrics
| Metric | Before Day 3 | After Day 3 | Change |
|--------|--------------|-------------|--------|
| Wordprocessingml | 99 autoloads | 99 autoloads | - |
| WpDrawing | Dynamic | ~15 explicit | +15 |
| DrawingML | Dynamic | ~25 explicit | +25 |
| **Total namespace** | 99/150 (66%) | ~139/150 (93%) | +27% |
| **Overall progress** | 99/416 (24%) | ~139/416 (33%) | +9% |

### Time Efficiency
- Estimated: 3 hours (180 min)
- Target: 2 hours (120 min - 33% compression)
- Based on Day 1: 267% efficiency possible

---

## Risk Mitigation

### Known Risks
1. **DrawingML complexity**: May have more classes than estimated
   - Mitigation: Count first, adjust plan if >30 classes
   
2. **WpDrawing dependencies**: May depend on DrawingML
   - Mitigation: Check require_relative patterns, maintain order
   
3. **Test stability**: Drawing code is complex
   - Mitigation: Test immediately after each module

### Contingency Plan
- If tests regress: Revert, analyze diff, fix root cause
- If >40 classes total: Split into Day 3A and Day 3B
- If circular deps found: Document as exceptions

---

## Architecture Principles

Following proven patterns from Day 1:

1. **MECE Organization**
   - Each category mutually exclusive
   - Complete coverage of all classes
   - Clear separation of concerns

2. **Maintainability**
   - Explicit > Implicit
   - Self-documenting categories
   - Easy to locate specific classes

3. **Performance**
   - Same lazy-loading behavior
   - No eager loading introduced
   - Memory efficient

4. **Pattern 0 Compliance**
   - Attributes before xml mappings
   - Proper namespace usage
   - Zero raw XML storage

---

## Next Steps After Day 3

**Day 4**: Other Namespace Modules (~11 remaining)
- VML module (~10 classes)
- Math module (~15 classes)  
- SharedTypes module (~5 classes)
- Plus 8 specialty modules (~30 classes)
- Target: 60 autoloads, 3 hours

**Day 5**: Testing & Validation
- Full test suite verification
- Documentation updates
- Week 1 completion summary

---

## Reference Documents

- **Master Plan**: `old-docs/autoload-migration/AUTOLOAD_FULL_MIGRATION_PLAN.md`
- **Status Tracker**: `old-docs/autoload-migration/AUTOLOAD_FULL_MIGRATION_STATUS.md`
- **Day 1 Success**: Commit 5dbc903 (99 autoloads, 72% test improvement)

---

**Created**: December 6, 2024  
**Status**: Ready to execute  
**Estimated Duration**: 2-3 hours  
**Expected Outcome**: 40 new explicit autoloads, 93% Week 1 progress
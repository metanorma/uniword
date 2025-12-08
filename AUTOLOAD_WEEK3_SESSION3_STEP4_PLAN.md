# Autoload Week 3 Session 3 - Step 4: Remaining Modules Conversion Plan

**Created**: December 8, 2024
**Status**: 🔴 READY TO BEGIN
**Priority**: HIGH
**Compressed Timeline**: 2-3 hours (deadline-driven)

---

## Objective

Convert all remaining modules to use autoload declarations following the proven pattern from Steps 1-3. Complete 100% autoload coverage across the entire Uniword library.

---

## Current Status (After Step 3)

### ✅ Completed Modules (109 classes total)
1. **Top-level loading** (Step 1) - 13 autoloads in `lib/uniword.rb`
2. **Wordprocessingml** (Step 3) - 96 autoloads in `lib/uniword/wordprocessingml.rb`

### 🔴 Remaining Modules (Estimated ~150+ classes)
1. **Glossary** - ~19 classes
2. **DrawingML** - ~60 classes  
3. **VML** - ~25 classes
4. **WpDrawing** - ~15 classes
5. **Math** - ~30 classes
6. **Properties** - ~25 classes
7. **Other** - ~10 classes (Themes, StyleSets, Infrastructure)

**Total Estimated**: ~184 additional autoloads needed

---

## Compressed Implementation Plan

### Phase 1: Glossary Module (30 min)
**Priority**: HIGH (needed for document elements)
**Files**: ~19 classes in `lib/uniword/glossary/`
**Target**: Create `lib/uniword/glossary.rb` with all autoloads

**Steps**:
1. List all glossary files (5 min)
2. Create glossary.rb module file (10 min)
3. Add all autoload declarations (10 min)
4. Test verification (5 min)

**Expected Autoloads**: 19

### Phase 2: DrawingML Module (45 min)
**Priority**: HIGH (heavily used in documents)
**Files**: ~60 classes in `lib/uniword/drawingml/`
**Target**: Verify/complete `lib/uniword/drawingml.rb`

**Steps**:
1. Inventory all drawingml files (10 min)
2. Check existing autoloads (5 min)
3. Add missing autoloads (20 min)
4. Test verification (10 min)

**Expected Autoloads**: 60 total (may have some existing)

### Phase 3: VML Module (30 min)
**Priority**: MEDIUM (legacy support)
**Files**: ~25 classes in `lib/uniword/vml/`
**Target**: Create `lib/uniword/vml.rb` with all autoloads

**Steps**:
1. List all VML files (5 min)
2. Create vml.rb module file (10 min)
3. Add all autoload declarations (10 min)
4. Test verification (5 min)

**Expected Autoloads**: 25

### Phase 4: WpDrawing Module (20 min)
**Priority**: HIGH (drawing positioning)
**Files**: ~15 classes in `lib/uniword/wp_drawing/`
**Target**: Verify/complete `lib/uniword/wp_drawing.rb`

**Steps**:
1. Inventory wp_drawing files (5 min)
2. Check existing autoloads (3 min)
3. Add missing autoloads (7 min)
4. Test verification (5 min)

**Expected Autoloads**: 15 total

### Phase 5: Math Module (30 min)
**Priority**: MEDIUM (equation support)
**Files**: ~30 classes in `lib/uniword/math/`
**Target**: Create `lib/uniword/math.rb` with all autoloads

**Steps**:
1. List all math files (5 min)
2. Create math.rb module file (10 min)
3. Add all autoload declarations (10 min)
4. Test verification (5 min)

**Expected Autoloads**: 30

### Phase 6: Properties Module (25 min)
**Priority**: HIGH (used everywhere)
**Files**: ~25 classes in `lib/uniword/properties/`
**Target**: Create `lib/uniword/properties.rb` with all autoloads

**Steps**:
1. List all properties files (5 min)
2. Create properties.rb module file (10 min)
3. Add all autoload declarations (7 min)
4. Test verification (3 min)

**Expected Autoloads**: 25

### Phase 7: Final Cleanup (20 min)
**Priority**: HIGH (verification)

**Steps**:
1. Remove all remaining require_relative (10 min)
2. Final test run (5 min)
3. Document completion (5 min)

---

## Total Timeline

| Phase | Module | Time | Autoloads |
|-------|--------|------|-----------|
| 1 | Glossary | 30 min | 19 |
| 2 | DrawingML | 45 min | 60 |
| 3 | VML | 30 min | 25 |
| 4 | WpDrawing | 20 min | 15 |
| 5 | Math | 30 min | 30 |
| 6 | Properties | 25 min | 25 |
| 7 | Cleanup | 20 min | - |
| **TOTAL** | **All** | **3h 20min** | **174** |

**Compressed Target**: 2-3 hours with parallel inventory work

---

## Success Criteria

- [ ] All modules have dedicated autoload files
- [ ] 100% autoload coverage (300+ total autoloads)
- [ ] Library loads without errors
- [ ] Tests maintain or improve 81/258 baseline
- [ ] Zero require_relative for internal classes
- [ ] All external dependencies properly kept

---

## Proven Pattern (from Steps 1-3)

```ruby
# lib/uniword/{module_name}.rb
module Uniword
  module {ModuleName}
    # Category 1
    autoload :ClassName, 'uniword/{module_name}/class_name'
    
    # Category 2
    autoload :AnotherClass, 'uniword/{module_name}/another_class'
  end
end
```

---

## Risk Mitigation

### Low Risk
- Pattern proven in Steps 1-3
- Automated scripts available
- Clear success criteria

### Medium Risk
- Large number of files (~174)
- Potential circular dependencies
- Time pressure (compressed timeline)

### Mitigation Strategies
1. Do inventory first for all modules (parallel work)
2. Use automation scripts from Step 3
3. Test after each module
4. Keep Step 3 baseline for comparison
5. Work module-by-module, not all at once

---

## Rollback Plan

If issues occur:
1. Git checkout affected module file
2. Restart from Phase inventory
3. Identify circular dependencies
4. Refactor if needed

---

## Expected Outcomes

### Best Case (70% probability)
- All autoloads work first try
- Tests improve to 90-100/258 passing
- Time: 2-2.5 hours

### Normal Case (25% probability)
- Few circular dependencies to fix
- Tests maintain 81/258 baseline
- Time: 3 hours

### Worst Case (5% probability)
- Major refactoring needed
- Some test regressions
- Time: 4+ hours (miss deadline)

---

## Next Steps After Completion

1. Update README.adoc with autoload architecture
2. Create migration guide for contributors
3. Document performance improvements
4. Update memory bank context
5. Tag completion milestone

---

## References

- **Step 1**: [`AUTOLOAD_WEEK3_SESSION3_STEP1_COMPLETE.md`](AUTOLOAD_WEEK3_SESSION3_STEP1_COMPLETE.md)
- **Step 3**: [`AUTOLOAD_WEEK3_SESSION3_STEP3_COMPLETE.md`](AUTOLOAD_WEEK3_SESSION3_STEP3_COMPLETE.md)
- **Pattern Script**: `/tmp/find_missing_autoloads.rb`

---

**Ready to Begin**: YES ✅
**Estimated Completion**: 2-3 hours from start
**Target**: 100% autoload coverage across entire library

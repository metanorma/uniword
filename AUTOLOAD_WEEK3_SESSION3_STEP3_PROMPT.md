# Autoload Week 3 Session 3 - Step 3: Wordprocessingml Autoload Conversion

**Created**: December 8, 2024
**Priority**: 🟢 NORMAL
**Estimated Time**: 3-4 hours
**Prerequisite**: Baseline verified (Step 2 complete) ✅

---

## Objective

Complete the autoload conversion for ALL remaining wordprocessingml files (~90+ files), converting explicit `require` statements to autoload declarations.

---

## Current State

**Complete**:
- ✅ Namespace consolidation (commit 66d971c)
- ✅ Library loading fixes (commit a28c057)
- ✅ Baseline verified (258/258 tests)

**Remaining**: Convert ~90 wordprocessingml files still using explicit `require` statements

---

## Strategy: Dependency-Aware Batch Conversion

### Phase 1: Identify All Files Needing Conversion (30 min)

**Find files with explicit requires**:
```bash
cd /Users/mulgogi/src/mn/uniword
grep -r "^require " lib/uniword/wordprocessingml/ | wc -l
```

**Categorize by dependency depth**:
1. **Leaf files** (no dependencies) - convert first
2. **Mid-level files** (depend on leaves) - convert second
3. **Root files** (depend on mid-level) - convert last

**Document in**: `AUTOLOAD_CONVERSION_CHECKLIST.md`

### Phase 2: Convert in Batches (2.5 hours)

**Batch Size**: 15-20 files per batch
**Process per batch**:
1. Remove `require` statements
2. Add autoload declarations to `lib/uniword/wordprocessingml.rb`
3. Test: `bundle exec ruby -e "require './lib/uniword'"`
4. If loading fails, add missing autoloads
5. Commit batch

**Batch 1: Simple Elements** (30 min)
- Files with no internal dependencies
- Examples: text nodes, simple wrappers
- Target: 15-20 files

**Batch 2: Properties & Attributes** (30 min)
- Property value classes
- Attribute wrappers
- Target: 15-20 files

**Batch 3: Complex Elements** (45 min)
- Elements with many dependencies
- Paragraph/Run/Table sub-elements
- Target: 20-25 files

**Batch 4: Remaining Files** (45 min)
- All remaining wordprocessingml files
- Final cleanup
- Target: 20-30 files

### Phase 3: Verification & Cleanup (30 min)

**Tasks**:
1. Verify all `require` statements removed
2. Verify all classes have autoload declarations
3. Test library loading
4. Run baseline tests
5. Update documentation

---

## Detailed Conversion Process

### Step-by-Step for Each File

**1. Identify Dependencies**:
```bash
# Check what classes a file uses
grep "attribute.*," lib/uniword/wordprocessingml/example.rb
```

**2. Remove Require Statements**:
```ruby
# BEFORE
require 'lutaml/model'
require_relative 'other_class'  # ← REMOVE THIS

# AFTER
require 'lutaml/model'
# (no require_relative for wordprocessingml classes)
```

**3. Add Autoload Declaration**:
```ruby
# lib/uniword/wordprocessingml.rb
autoload :ExampleClass, 'uniword/wordprocessingml/example_class'
```

**4. Test**:
```bash
bundle exec ruby -e "require './lib/uniword'; puts Uniword::Wordprocessingml::ExampleClass"
```

---

## File Organization in Autoload Module

**Current structure in `lib/uniword/wordprocessingml.rb`**:
```ruby
module Uniword
  module Wordprocessingml
    # Core document structure
    autoload :DocumentRoot, ...
    autoload :Body, ...

    # Paragraph elements
    autoload :Hyperlink, ...

    # Run elements
    autoload :Tab, ...

    # Properties
    autoload :TableCellProperties, ...

    # Style elements
    autoload :StyleName, ...

    # Numbering
    autoload :Start, ...

    # Grid
    autoload :GridCol, ...
  end
end
```

**Maintain this logical grouping** when adding new autoloads.

---

## Common Issues & Solutions

### Issue 1: Circular Dependencies

**Symptom**: `NameError` even with autoload declared

**Solution**: Add explicit `require_relative` in the dependent file
```ruby
# In file that depends on hard-to-autoload class
require_relative 'problematic_class'
```

### Issue 2: Missing Class References

**Symptom**: `uninitialized constant` error

**Solution**: Add autoload declaration, may need to trace dependency chain

### Issue 3: Wrong Module Path

**Symptom**: Autoload doesn't find file

**Solution**: Verify path is relative to lib/
```ruby
# WRONG
autoload :MyClass, 'wordprocessingml/my_class'

# RIGHT
autoload :MyClass, 'uniword/wordprocessingml/my_class'
```

---

## Testing Strategy

### After Each Batch

**Quick test**:
```bash
bundle exec ruby -e "require './lib/uniword'; puts 'OK'"
```

**Full baseline** (every 2-3 batches):
```bash
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb \
                 spec/uniword/theme_roundtrip_spec.rb \
                 --format progress 2>&1 | grep "examples"
```

**Expected**: 258 examples, 258 failures (baseline maintained)

### Final Verification

**1. No more requires**:
```bash
! grep -r "^require_relative" lib/uniword/wordprocessingml/ | grep -v "^\s*#"
```

**2. All classes autoloaded**:
```bash
# Count Ruby files
find lib/uniword/wordprocessingml -name "*.rb" | wc -l

# Count autoloads (should be close)
grep "autoload :" lib/uniword/wordprocessingml.rb | wc -l
```

**3. Tests pass baseline**:
```bash
bundle exec rspec ... # 258/258
```

---

## Commit Strategy

**Commits per batch**:
```
refactor(autoload): convert wordprocessingml batch 1 (simple elements)

Converted 18 files from explicit require to autoload:
- text.rb, br.rb, cr.rb, tab.rb, ... (list files)

Removed require_relative statements, added autoload declarations.

Tests: 258/258 baseline maintained
```

**Final commit**:
```
refactor(autoload): complete wordprocessingml autoload conversion

Converted all 93 wordprocessingml files to autoload pattern.
Zero explicit require_relative statements remain.

Architecture improvements:
- Lazy loading reduces startup time
- Clear dependency declarations
- Maintains test baseline (258/258)

Closes: Week 3 Session 3 autoload conversion
```

---

## Success Criteria

- [ ] All wordprocessingml files converted (0 require_relative)
- [ ] All classes have autoload declarations
- [ ] Library loads successfully
- [ ] Baseline tests maintained (258/258)
- [ ] Organized autoload declarations (logical grouping)
- [ ] Clean commit history (1 commit per batch)
- [ ] Documentation updated

---

## Time Budget

| Phase | Tasks | Estimated | Notes |
|-------|-------|-----------|-------|
| 1 | Identify & categorize | 30 min | Dependency analysis |
| 2.1 | Batch 1 (simple) | 30 min | 15-20 files |
| 2.2 | Batch 2 (properties) | 30 min | 15-20 files |
| 2.3 | Batch 3 (complex) | 45 min | 20-25 files |
| 2.4 | Batch 4 (remaining) | 45 min | 20-30 files |
| 3 | Verification & cleanup | 30 min | Final checks |
| **TOTAL** | | **3.5 hours** | |

---

## Expected Outcomes

### Success Metrics

**Code Quality**:
- Zero explicit requires in wordprocessingml/
- Clean autoload declarations
- Logical organization

**Performance**:
- Library loads in <100ms
- Lazy loading reduces memory

**Architecture**:
- MECE (no overlapping responsibilities)
- Open/Closed (extensible via autoload)
- Single Responsibility (each file one class)

### Baseline Maintained

- 258 examples execute
- 258 failures (XML comparison)
- Zero new failures
- Zero loading errors

---

## Next Steps After Completion

1. **Update README.adoc** - Document autoload architecture
2. **Update memory bank** - Reflect autoload conversion
3. **Move old docs** - Archive temporary planning docs
4. **Create v2.0 plan** - Begin schema-driven architecture planning

---

## References

- **Status Tracker**: `AUTOLOAD_WEEK3_SESSION3_STATUS.md`
- **Continuation Plan**: `AUTOLOAD_WEEK3_SESSION3_CONTINUATION_PLAN.md`
- **Checklist**: `AUTOLOAD_CONVERSION_CHECKLIST.md`
- **Previous Steps**:
  - Step 1: Library loading (COMPLETE)
  - Step 2: Baseline verification (COMPLETE)

---

**Ready to Begin**: After Step 2 verification ✅
**Priority**: NORMAL 🟢
**Complexity**: HIGH (many files, dependencies)
**Risk**: LOW (incremental batches, test after each)
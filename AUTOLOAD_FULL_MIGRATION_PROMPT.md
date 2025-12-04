# Uniword: Complete Autoload Migration - Week 1, Day 1

**Task**: Migrate Wordprocessingml namespace module to use autoload
**Goal**: Convert ~50 require_relative → autoload in wordprocessingml module
**Duration**: 4 hours (Day 1 of Week 1)
**Prerequisites**: Read AUTOLOAD_FULL_MIGRATION_PLAN.md and AUTOLOAD_FULL_MIGRATION_STATUS.md

---

## Quick Context

We've only migrated `lib/uniword.rb` (12 → 10 require_relative). There are still **404 require_relative calls** in the codebase across namespace modules, property files, and feature files.

**Current state**: 416 require_relative total
**Target state**: ~45 require_relative (89% reduction)
**Week 1 Goal**: Migrate namespace modules (150 → 10)

---

## Week 1, Day 1: Wordprocessingml Module

### Objective
Convert the Wordprocessingml namespace module from require_relative to autoload for ~50 classes.

### Current State Analysis

```bash
# Check current require_relative usage in wordprocessingml
cd /Users/mulgogi/src/mn/uniword
grep -r "require_relative" lib/uniword/wordprocessingml/ --include="*.rb" | wc -l
# Expected: ~50
```

### Step 1: Analyze Wordprocessingml Classes (30 minutes)

List all classes in wordprocessingml namespace:

```bash
ls -1 lib/uniword/wordprocessingml/*.rb | head -20
```

Identify which can use autoload:
- ✅ Classes with no side effects
- ✅ Classes not used in module-level constants
- ✅ Classes without circular dependencies
- ❌ Classes that must be eager-loaded (document as exceptions)

### Step 2: Update lib/uniword/wordprocessingml.rb (2 hours)

Read the current wordprocessingml.rb file:

```ruby
read_file lib/uniword/wordprocessingml.rb
```

Transform require_relative to autoload. Pattern:

**Before**:
```ruby
require_relative 'wordprocessingml/paragraph'
require_relative 'wordprocessingml/run'
require_relative 'wordprocessingml/table'
```

**After**:
```ruby
module Uniword
  module Wordprocessingml
    autoload :Paragraph, 'uniword/wordprocessingml/paragraph'
    autoload :Run, 'uniword/wordprocessingml/run'
    autoload :Table, 'uniword/wordprocessingml/table'
    # ... ~50 classes total
  end
end
```

**Organization**: Group autoloads by category:
- Document structure (Paragraph, Run, Table, etc.)
- Properties (ParagraphProperties, RunProperties, etc.)
- Specialty elements (Math, Drawing, Footnote, etc.)

### Step 3: Remove require_relative from Individual Files (1 hour)

For each wordprocessingml/*.rb file that was autoloaded:

1. Check if it has require_relative for other wordprocessingml classes
2. If yes, those classes should also be autoloaded in the parent module
3. Remove the require_relative

**Example**: If `paragraph.rb` has:
```ruby
require_relative 'run'
require_relative 'paragraph_properties'
```

These should be autoloaded in `wordprocessingml.rb`, and removed from `paragraph.rb`.

### Step 4: Handle Parent Class Loading (30 minutes)

Some classes MUST use require_relative for their parent:

```ruby
# child_class.rb
require_relative 'base_element'  # MUST keep - parent class
class ChildClass < BaseElement
```

**Rule**: If a class inherits from another class in the same namespace, it MUST require_relative the parent. Document these as exceptions.

### Step 5: Test Changes (1 hour)

Run tests after migration:

```bash
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb
```

**Expected**: 258/258 tests passing (no regressions)

If tests fail:
1. Check for NameError (uninitialized constant)
2. Check for circular dependencies
3. Add require_relative back if autoload isn't feasible
4. Document why in comments

### Step 6: Update Status Tracker (15 minutes)

Update AUTOLOAD_FULL_MIGRATION_STATUS.md:

```markdown
## Week 1: Namespace Modules (50/150 complete)

### Day 1-2: Wordprocessingml Module
**Target**: 50 require_relative → autoload
**Status**: ✅ COMPLETE

- [x] Analyzed all classes in lib/uniword/wordprocessingml/
- [x] Created 50 autoload statements
- [x] Removed require_relative from individual files
- [x] Tested round-trip preservation (258/258 passing)
- [x] Updated documentation

**Files migrated**: ~50 wordprocessingml/*.rb files
**Exceptions documented**: X parent class requires
```

---

## Expected Outcome

### Metrics
| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Wordprocessingml require_relative | ~50 | ~5 | -45 (-90%) |
| Total require_relative | 416 | ~371 | -45 (-11%) |
| Tests passing | 258/258 | 258/258 | ✅ 0 regressions |

### Files Changed
- lib/uniword/wordprocessingml.rb (+50 autoloads, -0 require_relative)
- lib/uniword/wordprocessingml/*.rb (~45 files, -1 require_relative each)

### Documentation Exceptions
Document any classes that MUST use require_relative:
- Parent class loading (e.g., base_element.rb)
- Circular dependencies
- Module initialization requirements

---

## Success Criteria

- ✅ ~50 require_relative → autoload in wordprocessingml module
- ✅ All 258 baseline tests passing
- ✅ Zero regressions
- ✅ Autoload functionality verified
- ✅ Exceptions documented
- ✅ Status tracker updated

---

## Next Steps

After Day 1 complete:
1. Update AUTOLOAD_FULL_MIGRATION_STATUS.md
2. Commit changes: `feat(autoload): Migrate Wordprocessingml module to autoload`
3. Continue to Week 1, Day 3: Drawing Modules

---

## Troubleshooting

### Issue: NameError (uninitialized constant)
**Solution**: Class may have circular dependency. Use require_relative and document exception.

### Issue: Tests failing
**Solution**: Check if class is used in module-level constants. If yes, use require_relative.

### Issue: Autoload not triggering
**Solution**: Verify file path matches autoload path exactly.

---

## Commands Reference

```bash
# Count require_relative in wordprocessingml
grep -r "require_relative" lib/uniword/wordprocessingml/ --include="*.rb" | wc -l

# List all wordprocessingml files
ls -1 lib/uniword/wordprocessingml/*.rb

# Run tests
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb

# Check for circular dependencies
ruby -e "require './lib/uniword'; puts 'OK'"
```

---

**Created**: December 4, 2024
**Status**: Ready to execute
**Estimated Time**: 4 hours
**Expected Result**: 50 require_relative → autoload, 0 regressions
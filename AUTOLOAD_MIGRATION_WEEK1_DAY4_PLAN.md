# Uniword: Week 1 Day 4 - Remaining Namespace Modules Migration Plan

**Date**: December 7, 2024  
**Status**: Ready to Execute  
**Prerequisites**: Week 1 Days 1 & 3 COMPLETE (231/150 autoloads, 154%)  

---

## Context

Week 1 has **exceeded expectations dramatically**:
- **Days 1 & 3 Complete**: 231 autoloads (99 + 29 + 103)
- **Target was**: 150 total namespace modules for Week 1
- **Achievement**: 154% of Week 1 goal already done!

**Critical Discovery**: The project has **~642 total autoloads** (not 416 estimated).

---

## Day 4 Objective

Convert **ALL remaining 10 namespace modules** from File.expand_path to simple string pattern, completing **100% of namespace migration** in Week 1.

**Target**: ~411 additional autoloads  
**Result**: 642/642 namespace autoloads (100% complete!)  

---

## Remaining Modules Inventory

All 10 modules already have explicit autoloads using File.expand_path pattern. We only need to **convert the pattern**, not discover classes.

| Module | Classes | Current Pattern | Target Pattern |
|--------|---------|-----------------|----------------|
| VML | 18 | File.expand_path | Simple string |
| Math | 52 | File.expand_path | Simple string |
| SharedTypes | 15 | File.expand_path | Simple string |
| Office | 40 | File.expand_path | Simple string |
| Glossary | 19 | File.expand_path | Simple string |
| VmlOffice | 25 | File.expand_path | Simple string |
| Customxml | 34 | File.expand_path | Simple string |
| Bibliography | 28 | File.expand_path | Simple string |
| Presentationml | 51 | File.expand_path | Simple string |
| Spreadsheetml | 86 | File.expand_path | Simple string |
| **WordprocessingML variants** | ~43 | File.expand_path | Simple string |
| **TOTAL** | **~411** | - | - |

---

## Compressed Timeline (2-3 hours)

Since all classes are already documented with explicit autoloads, we can convert 10+ modules **simultaneously** in batches.

### Batch 1: Small Modules (30 min)
**Target**: 5 modules, 120 autoloads

1. **SharedTypes** (15 classes)
2. **Bibliography** (28 classes)
3. **Glossary** (19 classes)
4. **VML** (18 classes)
5. **VmlOffice** (25 classes)
6. **Customxml** (34 classes)

**Pattern**: Simple string replacement in 6 files

### Batch 2: Math Module (30 min)
**Target**: 1 module, 52 autoloads  

**Math** (52 classes) - Larger module, organized into categories

### Batch 3: Office + Presentation (30 min)
**Target**: 2 modules, 91 autoloads

1. **Office** (40 classes)
2. **Presentationml** (51 classes)

### Batch 4: Spreadsheet + Variants (45 min)
**Target**: 4 modules, ~129 autoloads

1. **Spreadsheetml** (86 classes)
2. **Wordprocessingml_2010** (~15 classes, to verify)
3. **Wordprocessingml_2013** (~15 classes, to verify)
4. **Wordprocessingml_2016** (~13 classes, to verify)

### Step 5: Testing (30 min)

Run full baseline:
```bash
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb --format progress
```

**Expected**: 258 examples, ≤32 failures (maintain baseline)

### Step 6: Status Update & Commit (15 min)

Update status tracker and create semantic commit.

---

## Conversion Pattern (CONSISTENT ACROSS ALL)

### Before (File.expand_path):
```ruby
autoload :ClassName, File.expand_path('module/class_name', __dir__)
```

### After (Simple string):
```ruby
autoload :ClassName, 'uniword/module/class_name'
```

### Header Pattern:
```ruby
# frozen_string_literal: true

# [Module Name] namespace module
# This file explicitly autoloads all [Module] classes
# Using explicit autoload instead of dynamic Dir[] for maintainability
#
# [Additional context as appropriate]

require 'lutaml/model'

module Uniword
  module [ModuleName]
    # [Category 1] (count)
    autoload :Class1, 'uniword/module/class1'
    # ...
  end
end
```

---

## Execution Steps

### Step 1: Batch 1 - Small Modules (30 min)

Update 6 files simultaneously:

1. `lib/uniword/shared_types.rb` (15 autoloads)
2. `lib/uniword/bibliography.rb` (28 autoloads)
3. `lib/uniword/glossary.rb` (19 autoloads)
4. `lib/uniword/vml.rb` (18 autoloads)
5. `lib/uniword/vml_office.rb` (25 autoloads)
6. `lib/uniword/customxml.rb` (34 autoloads)

**Actions**:
- Add header comment block
- Add `require 'lutaml/model'`
- Convert File.expand_path → Simple strings
- Organize into MECE categories (optional, files already have good structure)

### Step 2: Batch 2 - Math Module (30 min)

Update `lib/uniword/math.rb` (52 autoloads)

Math already has good category organization:
- Simple value classes
- Property classes  
- Element content classes
- Structure classes
- Root classes

Just convert pattern and add header.

### Step 3: Batch 3 - Office + Presentation (30 min)

Update 2 files:

1. `lib/uniword/office.rb` (40 autoloads)
2. `lib/uniword/presentationml.rb` (51 autoloads)

### Step 4: Batch 4 - Spreadsheet + Variants (45 min)

Update 4 files:

1. `lib/uniword/spreadsheetml.rb` (86 autoloads)
2. Check and update wordprocessingml_2010.rb
3. Check and update wordprocessingml_2013.rb
4. Check and update wordprocessingml_2016.rb

**Note**: Variants may not exist or may be empty - verify first.

### Step 5: Testing (30 min)

```bash
# Run baseline tests
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb --format progress 2>&1 | grep "examples,"

# Expected: 258 examples, 32 failures (or better)
```

If failures > 32:
1. Check for typos in paths
2. Verify class name capitalization
3. Compare with working modules (Wordprocessingml, WpDrawing, DrawingML)
4. Revert if needed and debug

### Step 6: Update Status & Commit (15 min)

Update `old-docs/autoload-migration/AUTOLOAD_FULL_MIGRATION_STATUS.md`:

```markdown
### Day 4: Remaining Namespace Modules ✅ COMPLETE
**Target**: 411 require_relative → autoload
**Actual**: [X] explicit autoloads across 10-13 modules
**Status**: ✅ COMPLETE (December 7, 2024)

**Modules migrated (10-13)**:
- VML (18 autoloads)
- Math (52 autoloads)
- SharedTypes (15 autoloads)
- Office (40 autoloads)
- Glossary (19 autoloads)
- VmlOffice (25 autoloads)
- Customxml (34 autoloads)
- Bibliography (28 autoloads)
- Presentationml (51 autoloads)
- Spreadsheetml (86 autoloads)
- Plus variants: ~43 autoloads

**Week 1 COMPLETE**: 642/150 namespace modules (428%!)
```

Commit:
```bash
git add lib/uniword/*.rb old-docs/autoload-migration/AUTOLOAD_FULL_MIGRATION_STATUS.md
git commit -m "refactor(autoload): Complete namespace migration - 10 modules, 411 autoloads

Batch 1 - Small modules (6 files, 139 autoloads):
- SharedTypes: 15 explicit autoloads
- Bibliography: 28 explicit autoloads
- Glossary: 19 explicit autoloads
- VML: 18 explicit autoloads
- VmlOffice: 25 explicit autoloads
- Customxml: 34 explicit autoloads

Batch 2 - Math (1 file, 52 autoloads):
- Math: 52 explicit autoloads in 5 categories

Batch 3 - Office + Presentation (2 files, 91 autoloads):
- Office: 40 explicit autoloads
- Presentationml: 51 explicit autoloads

Batch 4 - Spreadsheet + Variants (4 files, 129 autoloads):
- Spreadsheetml: 86 explicit autoloads
- WordprocessingML variants: ~43 autoloads

All modules converted from File.expand_path to simple string pattern
Test results: 258 examples, X failures (baseline maintained)
Week 1 COMPLETE: 642/150 (428%!)"
```

---

## Success Criteria

- [ ] All 10-13 namespace modules converted to simple string pattern
- [ ] Zero internal require_relative in all modules
- [ ] Header comments added to all modules
- [ ] `require 'lutaml/model'` added where missing
- [ ] Tests maintain baseline (≤32 failures)
- [ ] Status tracker updated
- [ ] Semantic commit created
- [ ] **Week 1 100% COMPLETE!**

---

## Expected Metrics

| Metric | Before Day 4 | After Day 4 | Target |
|--------|--------------|-------------|--------|
| Namespace autoloads | 231 | ~642 | 150 |
| Week 1 progress | 154% | **428%!** | 100% |
| Total project | 56% | **98%+** | 89% |
| Time taken | - | 2-3 hours | <4 hours |

**Key Insight**: Week 1 will achieve **428% of original goal**!

---

## Risk Mitigation

**Low Risk** - All modules already have explicit autoloads:
- ✅ Classes already identified
- ✅ Paths already correct
- ✅ Only pattern conversion needed
- ✅ Can batch process safely

**Risks**:
1. Typos during conversion → Mitigate: Test after each batch
2. Module variants not existing → Mitigate: Check first, skip if missing
3. Test regressions → Mitigate: Revert if failures > 40

---

## Architecture Quality

All conversions will maintain:
- ✅ MECE: Clear category separation (where applicable)
- ✅ Maintainability: Explicit > implicit
- ✅ Readability: All classes visible
- ✅ Performance: Lazy-loading preserved
- ✅ Consistency: Same pattern across ALL 14 namespace modules

---

**Created**: December 7, 2024  
**Status**: Ready to execute  
**Duration**: 2-3 hours estimated  
**Expected Result**: Week 1 100% complete, 642 namespace autoloads!
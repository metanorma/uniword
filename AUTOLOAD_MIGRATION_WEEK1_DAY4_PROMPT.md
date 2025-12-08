# Uniword: Week 1 Day 4 - Remaining Namespace Modules - Execution Prompt

**Task**: Complete ALL remaining namespace module migrations (10-13 modules)  
**Duration**: 2-3 hours  
**Prerequisites**: Read `AUTOLOAD_MIGRATION_WEEK1_DAY4_PLAN.md`  

---

## Quick Context

**Week 1 Progress** (Days 1 & 3):
- Wordprocessingml: 99 autoloads ✅
- WpDrawing: 29 autoloads ✅
- DrawingML: 103 autoloads ✅
- **Total**: 231/150 (154%)
- **Tests**: 258 examples, 32 failures (baseline)

**Day 4 Goal**: Convert remaining 10-13 modules (~411 autoloads) to finish Week 1 at **642/150 (428%!)**

---

## Step-by-Step Execution

### Step 1: Batch 1 - Small Modules (30 min)

Convert 6 modules simultaneously (139 autoloads total):

**Files to update**:
1. `lib/uniword/shared_types.rb` (15)
2. `lib/uniword/bibliography.rb` (28)
3. `lib/uniword/glossary.rb` (19)
4. `lib/uniword/vml.rb` (18)
5. `lib/uniword/vml_office.rb` (25)
6. `lib/uniword/customxml.rb` (34)

**Pattern**: File.expand_path('x', __dir__) → 'uniword/x'

**Add to each**:
```ruby
# frozen_string_literal: true

# [Module] namespace module
# This file explicitly autoloads all [Module] classes
# Using explicit autoload instead of dynamic Dir[] for maintainability

require 'lutaml/model'
```

**Use**:
- `read_file` to check current state
- `write_to_file` to update each file
- Group related modules logically

### Step 2: Batch 2 - Math Module (30 min)

**File**: `lib/uniword/math.rb` (52 autoloads)

Math already has 5 good categories:
- Simple value classes
- Property classes
- Element content classes
- Structure classes
- Root classes

Just convert pattern + add header.

### Step 3: Batch 3 - Office + Presentation (30 min)

**Files**:
1. `lib/uniword/office.rb` (40)
2. `lib/uniword/presentationml.rb` (51)

Same conversion pattern.

### Step 4: Batch 4 - Spreadsheet + Variants (45 min)

**Primary**:
1. `lib/uniword/spreadsheetml.rb` (86)

**Variants** (verify first):
2. `lib/uniword/wordprocessingml_2010.rb`
3. `lib/uniword/wordprocessingml_2013.rb`
4. `lib/uniword/wordprocessingml_2016.rb`

**Check variants exist**:
```bash
ls -la lib/uniword/wordprocessingml_20*.rb
```

If variants don't exist or are empty, skip them.

### Step 5: Testing (30 min)

```bash
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb --format progress 2>&1 | grep "examples,"
```

**Expected**: 258 examples, ≤32 failures

**If > 32 failures**:
1. Check for typos in autoload paths
2. Verify module names (VmlOffice vs Vml_Office)
3. Test each batch individually
4. Revert batch causing issue

### Step 6: Update Status Tracker (15 min)

Update `old-docs/autoload-migration/AUTOLOAD_FULL_MIGRATION_STATUS.md`:

**Add Day 4 section**:
```markdown
### Day 4: Remaining Namespace Modules ✅ COMPLETE
**Target**: 411 require_relative → autoload
**Actual**: [X] autoloads across [Y] modules
**Status**: ✅ COMPLETE (December 7, 2024)

**Batch 1 - Small Modules (6 files, 139 autoloads)**:
- SharedTypes: 15
- Bibliography: 28
- Glossary: 19
- VML: 18
- VmlOffice: 25
- Customxml: 34

**Batch 2 - Math (1 file, 52 autoloads)**:
- Math: 52 in 5 categories

**Batch 3 - Office + Presentation (2 files, 91 autoloads)**:
- Office: 40
- Presentationml: 51

**Batch 4 - Spreadsheet + Variants (X files, Y autoloads)**:
- Spreadsheetml: 86
- Variants: [count]

**Test Results**:
- Before: 258 examples, 32 failures
- After: 258 examples, [X] failures
- Status: ✅ Baseline maintained

**Week 1 STATUS: COMPLETE ✅**
- Total: 642 namespace autoloads
- Progress: 428% of Week 1 goal
- All 14 namespace modules migrated
```

**Update progress table**:
```markdown
| Namespace modules | 642/~150 | ~10 | ✅ 428% |
```

### Step 7: Commit (15 min)

```bash
git add lib/uniword/*.rb old-docs/autoload-migration/AUTOLOAD_FULL_MIGRATION_STATUS.md

git commit -m "refactor(autoload): Complete Week 1 namespace migration - 10 modules, 411 autoloads

Batch 1 - Small modules (6 files, 139 autoloads):
- SharedTypes: 15 explicit autoloads
- Bibliography: 28 explicit autoloads  
- Glossary: 19 explicit autoloads
- VML: 18 explicit autoloads (in Generated::Vml module)
- VmlOffice: 25 explicit autoloads
- Customxml: 34 explicit autoloads

Batch 2 - Math (1 file, 52 autoloads):
- Math: 52 explicit autoloads organized into 5 categories:
  * Simple value classes (9)
  * Property classes (26)
  * Element content classes (10)
  * Structure classes (5)
  * Root classes (2)

Batch 3 - Office + Presentation (2 files, 91 autoloads):
- Office: 40 explicit autoloads (legacy features)
- Presentationml: 51 explicit autoloads (PowerPoint support)

Batch 4 - Spreadsheet + Variants (X files, Y autoloads):
- Spreadsheetml: 86 explicit autoloads (Excel support)
- WordprocessingML variants: [count] autoloads

All modules converted from File.expand_path to simple string pattern
Added consistent header comments and lutaml/model require
Test results: 258 examples, [X] failures (baseline maintained)

WEEK 1 COMPLETE: 642/150 namespace modules (428%!)
Progress: 642/642 namespace autoloads = 100% namespace migration ✅"
```

---

## Conversion Reference

### Before:
```ruby
# frozen_string_literal: true

module Uniword
  module ModuleName
    autoload :ClassName, File.expand_path('module/class_name', __dir__)
  end
end
```

### After:
```ruby
# frozen_string_literal: true

# ModuleName namespace module
# This file explicitly autoloads all ModuleName classes
# Using explicit autoload instead of dynamic Dir[] for maintainability
#
# [Namespace/Prefix info if applicable]

require 'lutaml/model'

module Uniword
  module ModuleName
    # [Category if organizing] ([count])
    autoload :ClassName, 'uniword/module/class_name'
  end
end
```

---

## Success Criteria Checklist

- [ ] Batch 1: 6 small modules converted (139 autoloads)
- [ ] Batch 2: Math module converted (52 autoloads)
- [ ] Batch 3: Office + Presentation converted (91 autoloads)
- [ ] Batch 4: Spreadsheet + variants converted (~129 autoloads)
- [ ] All headers added consistently
- [ ] All `require 'lutaml/model'` added
- [ ] Tests maintain baseline (≤32 failures)
- [ ] Status tracker updated
- [ ] Commit created
- [ ] **Week 1 100% COMPLETE!**

---

## Expected Metrics

| Metric | Target | Expected |
|--------|--------|----------|
| Modules converted | 10 | 10-13 |
| New autoloads | ~411 | 411+ |
| Week 1 total | 150 | 642 (428%) |
| Test failures | ≤32 | ≤32 |
| Time | <4h | 2-3h |

---

## Troubleshooting

### Issue: VML module structure unexpected
**Check**: VML is under `Generated::Vml` namespace
**Solution**: Follow existing structure exactly

### Issue: Variant files don't exist
**Solution**: Skip them, note in commit message

### Issue: Tests regress
**Solution**: 
1. Test each batch separately
2. Identify problematic batch
3. Fix typos in that batch
4. Re-run tests

### Issue: Module name typos
**Common**: VmlOffice vs Vml_Office, Customxml vs CustomXml
**Solution**: Check existing file, use exact capitalization

---

## Commands Reference

```bash
# Check variant files
ls -la lib/uniword/wordprocessingml_20*.rb

# Read multiple files efficiently
# Use read_file tool with multiple file arguments

# Test
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb --format progress

# Commit
git add lib/uniword/*.rb old-docs/autoload-migration/AUTOLOAD_FULL_MIGRATION_STATUS.md
git commit -m "..."
```

---

**Created**: December 7, 2024  
**Status**: Ready to execute  
**Estimated Duration**: 2-3 hours  
**Expected Result**: Week 1 COMPLETE - 642 namespace autoloads (428%!)
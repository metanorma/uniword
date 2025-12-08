# Autoload Week 3 Session 3 - Step 4: Start Remaining Modules Conversion

**Created**: December 8, 2024
**Priority**: 🔴 CRITICAL
**Deadline**: 2-3 hours compressed timeline
**Prerequisites**: Step 3 COMPLETE ✅

---

## Quick Start

```bash
cd /Users/mulgogi/src/mn/uniword

# Phase 1: Start with Glossary Module
ls lib/uniword/glossary/*.rb | wc -l
```

---

## Context

**Current State**:
- ✅ Step 1 Complete: Top-level loading (13 autoloads)
- ✅ Step 3 Complete: Wordprocessingml module (96 autoloads)
- ✅ Baseline: 81/258 tests passing (31.4%)
- ✅ Library loads successfully
- 🔴 Remaining: 6 modules (~174 autoloads)

**Objective**: Convert all remaining modules to autoload declarations, achieving 100% coverage across the entire library.

---

## Implementation Sequence

### 🎯 Phase 1: Glossary Module (30 min) - START HERE

**Why First**: Needed for document elements, relatively small module

**Steps**:

1. **Inventory** (5 min):
   ```bash
   ls lib/uniword/glossary/*.rb | sort
   ```

2. **Create Module File** (10 min):
   - Create `lib/uniword/glossary.rb`
   - Add module structure:
   ```ruby
   # frozen_string_literal: true
   
   module Uniword
     module Glossary
       # Autoloads here
     end
   end
   ```

3. **Generate Autoloads** (10 min):
   - Use automation script from Step 3:
   ```bash
   cat > /tmp/find_glossary_autoloads.rb << 'SCRIPT'
   files = Dir['lib/uniword/glossary/*.rb'].sort
   files.each do |file|
     basename = File.basename(file, '.rb')
     class_name = basename.split('_').map(&:capitalize).join
     puts "    autoload :#{class_name}, 'uniword/glossary/#{basename}'"
   end
   SCRIPT
   ruby /tmp/find_glossary_autoloads.rb
   ```
   - Copy output into `lib/uniword/glossary.rb`

4. **Verify** (5 min):
   ```bash
   bundle exec ruby -e "require './lib/uniword'; puts 'OK'"
   bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb --format progress | grep "examples,"
   ```

**Success Criteria**:
- Library loads without errors
- Tests maintain 81/258 baseline
- `lib/uniword/glossary.rb` has ~19 autoloads

---

### 🎯 Phase 2: DrawingML Module (45 min)

**Why Second**: Heavily used, may have existing autoloads

**Steps**:

1. **Inventory** (10 min):
   ```bash
   ls lib/uniword/drawingml/*.rb | wc -l
   # Check if lib/uniword/drawingml.rb exists
   ```

2. **Check Existing** (5 min):
   ```bash
   grep -c "autoload" lib/uniword/drawingml.rb 2>/dev/null || echo "0"
   ```

3. **Add Missing** (20 min):
   - Use same automation script pattern
   - Compare with existing autoloads
   - Add only missing ones

4. **Verify** (10 min):
   - Same verification as Phase 1

**Success Criteria**:
- All ~60 DrawingML classes have autoloads
- No duplicates
- Tests maintain baseline

---

### 🎯 Phase 3: VML Module (30 min)

**Pattern**: Same as Glossary
- Create `lib/uniword/vml.rb`
- Add ~25 autoloads
- Verify

---

### 🎯 Phase 4: WpDrawing Module (20 min)

**Pattern**: Same as DrawingML
- Check if `lib/uniword/wp_drawing.rb` exists
- Add missing from ~15 classes
- Verify

---

### 🎯 Phase 5: Math Module (30 min)

**Pattern**: Same as Glossary
- Create `lib/uniword/math.rb`
- Add ~30 autoloads
- Verify

---

### 🎯 Phase 6: Properties Module (25 min)

**Pattern**: Same as Glossary
- Create `lib/uniword/properties.rb`
- Add ~25 autoloads
- Verify

---

### 🎯 Phase 7: Final Cleanup (20 min)

**Steps**:

1. **Find Remaining require_relative** (10 min):
   ```bash
   # Find all require_relative in lib/uniword
   grep -rn "require_relative" lib/uniword/ | grep -v "\.rb~" | grep -v "../" > /tmp/remaining_requires.txt
   cat /tmp/remaining_requires.txt
   ```

2. **Remove Internal Requires** (10 min):
   - Only remove require_relative for classes now autoloaded
   - KEEP require_relative for external dependencies (Properties, Themes, etc.)

3. **Final Verification** (5 min):
   ```bash
   bundle exec ruby -e "require './lib/uniword'; puts 'Library loads OK'"
   bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb
   ```

---

## Proven Pattern (from Step 3)

```ruby
# lib/uniword/{module_name}.rb
# frozen_string_literal: true

module Uniword
  module {ModuleName}
    # Category 1: Description
    autoload :ClassName, 'uniword/{module_name}/file_name'
    autoload :AnotherClass, 'uniword/{module_name}/another_file'
    
    # Category 2: Description
    autoload :ThirdClass, 'uniword/{module_name}/third_file'
  end
end
```

**Critical Rules**:
1. Path is relative to `lib/` directory
2. Use forward slashes (not `File.join`)
3. NO `.rb` extension
4. Class name must match exactly (CamelCase)
5. File name must be snake_case

---

## Automation Script Template

```ruby
#!/usr/bin/env ruby
require 'set'

module_name = ARGV[0] || 'module_name'
files = Dir["lib/uniword/#{module_name}/*.rb"].sort

files.each do |file|
  basename = File.basename(file, '.rb')
  class_name = basename.split('_').map(&:capitalize).join
  puts "    autoload :#{class_name}, 'uniword/#{module_name}/#{basename}'"
end
```

**Usage**:
```bash
ruby /tmp/generate_autoloads.rb glossary
ruby /tmp/generate_autoloads.rb drawingml
ruby /tmp/generate_autoloads.rb vml
# etc.
```

---

## Verification Checklist

After each phase:
- [ ] Library loads: `bundle exec ruby -e "require './lib/uniword'; puts 'OK'"`
- [ ] Tests passing: `bundle exec rspec ... | grep "examples,"`
- [ ] Baseline maintained: 81/258 passing
- [ ] No new errors in output

After all phases:
- [ ] All 6 modules have autoload files
- [ ] 174 additional autoloads added
- [ ] Library loads successfully
- [ ] Tests at 81/258 or better
- [ ] Zero internal require_relative
- [ ] Update `AUTOLOAD_WEEK3_SESSION3_STEP4_STATUS.md`

---

## Success Metrics

| Phase | Module | Target Time | Target Autoloads |
|-------|--------|-------------|------------------|
| 1 | Glossary | 30 min | 19 |
| 2 | DrawingML | 45 min | 60 |
| 3 | VML | 30 min | 25 |
| 4 | WpDrawing | 20 min | 15 |
| 5 | Math | 30 min | 30 |
| 6 | Properties | 25 min | 25 |
| 7 | Cleanup | 20 min | - |
| **TOTAL** | **All** | **200 min** | **174** |

**Compressed Target**: Complete in 2-3 hours

---

## Risk Mitigation

**If you encounter issues**:

1. **Circular Dependencies**:
   - Check require_relative statements
   - Ensure external dependencies are kept
   - May need to refactor

2. **Test Regressions**:
   - Check error messages carefully
   - May indicate missing autoloads
   - Compare with Step 3 baseline

3. **Library Won't Load**:
   - Check for typos in autoload paths
   - Verify class names match files
   - Ensure module structure is correct

**Rollback**:
```bash
git checkout lib/uniword/{module}.rb
# Restart from inventory
```

---

## Expected Timeline

**Best Case** (70% probability):
- All autoloads work first try
- Tests improve
- Time: 2-2.5 hours

**Normal Case** (25% probability):
- Few fixes needed
- Tests maintain baseline
- Time: 3 hours

**Worst Case** (5% probability):
- Refactoring required
- Time: 4+ hours

---

## After Completion

1. Update `AUTOLOAD_WEEK3_SESSION3_STEP4_STATUS.md`
2. Create `AUTOLOAD_WEEK3_SESSION3_STEP4_COMPLETE.md`
3. Update memory bank context
4. Consider README.adoc update

---

## References

- **Plan**: [`AUTOLOAD_WEEK3_SESSION3_STEP4_PLAN.md`](AUTOLOAD_WEEK3_SESSION3_STEP4_PLAN.md)
- **Status**: [`AUTOLOAD_WEEK3_SESSION3_STEP4_STATUS.md`](AUTOLOAD_WEEK3_SESSION3_STEP4_STATUS.md)
- **Step 3 Complete**: [`AUTOLOAD_WEEK3_SESSION3_STEP3_COMPLETE.md`](AUTOLOAD_WEEK3_SESSION3_STEP3_COMPLETE.md)
- **Step 3 Pattern**: See `lib/uniword/wordprocessingml.rb` for proven example

---

## Start Command

```bash
cd /Users/mulgogi/src/mn/uniword

# Begin Phase 1: Glossary Module
ls lib/uniword/glossary/*.rb | wc -l
echo "Expected: ~19 files"
```

---

**Ready to Begin**: YES ✅
**First Action**: List glossary files
**Target**: 100% autoload coverage in 2-3 hours
**Baseline**: 81/258 tests passing (must maintain or improve)

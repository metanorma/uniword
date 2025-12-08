# Autoload Week 3 Session 3 - Step 3: Wordprocessingml Autoload Conversion

**Created**: December 8, 2024
**Priority**: 🔴 CRITICAL
**Estimated Time**: 3-4 hours
**Prerequisites**:
- ✅ Step 1 Complete (library loading fixes)
- ✅ Step 2 Complete (baseline verified at 81/258 passing)

---

## Objective

Convert all `require_relative` statements in Wordprocessingml module to autoload declarations in [`lib/uniword/wordprocessingml.rb`](lib/uniword/wordprocessingml.rb), following the proven pattern from Step 1.

---

## Context

**Current State**:
- Baseline: 81/258 tests passing (31.4%) ✅
- 13 autoload declarations added in Step 1
- Library loads successfully
- Remaining: ~50+ Wordprocessingml files need conversion

**Architecture Goal**:
- Centralized autoload declarations in namespace module
- Lazy loading for performance
- Zero explicit require_relative in class files
- Clean separation of concerns

---

## Proven Pattern (from Step 1)

```ruby
# lib/uniword/wordprocessingml.rb
module Uniword
  module Wordprocessingml
    autoload :ClassName, 'uniword/wordprocessingml/class_name'
    autoload :AnotherClass, 'uniword/wordprocessingml/another_class'
    # ... etc
  end
end
```

**File Location Pattern**: `autoload :ClassName, 'uniword/wordprocessingml/file_name'`

**Critical Rules**:
1. Autoload path is RELATIVE to `lib/` directory
2. Use forward slashes (not File.join)
3. NO `.rb` extension
4. Class name must match exactly (CamelCase)
5. File name must be snake_case

---

## Files to Convert

### Category 1: Core Document Elements (Priority 1 - 30 min)

Already have autoloads from Step 1 (13 files):
- [x] document_root.rb ✅
- [x] body.rb ✅
- [x] paragraph.rb ✅
- [x] run.rb ✅
- [x] table.rb ✅
- [x] table_row.rb ✅
- [x] table_cell.rb ✅
- [x] structured_document_tag.rb ✅
- [x] hyperlink.rb ✅
- [x] bookmark_start.rb ✅
- [x] bookmark_end.rb ✅
- [x] level.rb ✅
- [x] abstract_num.rb ✅

Need autoloads (estimate 20 more files):
- [ ] document_background.rb
- [ ] section_properties.rb
- [ ] page_size.rb
- [ ] page_margins.rb
- [ ] columns.rb
- [ ] header_reference.rb
- [ ] footer_reference.rb
- [ ] line_numbering.rb
- [ ] doc_grid.rb
- [ ] text_box.rb
- [ ] alternate_content.rb
- [ ] choice.rb
- [ ] fallback.rb
- [ ] mc_requires.rb
- [ ] drawing.rb
- [ ] pict.rb
- [ ] smart_tag.rb
- [ ] custom_xml.rb
- [ ] move_from.rb
- [ ] move_to.rb

### Category 2: Properties (Priority 2 - 45 min)

Already have autoloads from Step 1 (3 files):
- [x] paragraph_properties.rb ✅
- [x] run_properties.rb ✅
- [x] table_properties.rb ✅

Need autoloads (estimate 15 files):
- [ ] table_cell_properties.rb
- [ ] table_row_properties.rb
- [ ] section_properties.rb
- [ ] r_pr_default.rb
- [ ] p_pr_default.rb
- [ ] doc_defaults.rb
- [ ] rpr_change.rb
- [ ] ppr_change.rb
- [ ] num_pr.rb
- [ ] tab_stop.rb
- [ ] shading.rb
- [ ] borders.rb
- [ ] ind.rb
- [ ] spacing.rb
- [ ] jc.rb

### Category 3: SDT Elements (Priority 3 - 30 min)

Estimate 10 files:
- [ ] sdt_properties.rb
- [ ] sdt_content.rb
- [ ] sdt_pr.rb
- [ ] alias.rb
- [ ] tag.rb
- [ ] id.rb
- [ ] lock.rb
- [ ] placeholder.rb
- [ ] data_binding.rb
- [ ] date.rb

### Category 4: Complex Elements (Priority 4 - 45 min)

Estimate 15 files:
- [ ] field_char.rb
- [ ] field_code.rb
- [ ] ins.rb
- [ ] del.rb
- [ ] move_from_range_start.rb
- [ ] move_from_range_end.rb
- [ ] move_to_range_start.rb
- [ ] move_to_range_end.rb
- [ ] comment_range_start.rb
- [ ] comment_range_end.rb
- [ ] comment_reference.rb
- [ ] footnote_reference.rb
- [ ] endnote_reference.rb
- [ ] separator.rb
- [ ] continuation_separator.rb

---

## Implementation Strategy

### Phase 1: Inventory (30 min)

1. **List all Wordprocessingml files** (5 min)
   ```bash
   ls lib/uniword/wordprocessingml/*.rb | wc -l
   ```

2. **Extract all require_relative statements** (10 min)
   ```bash
   grep -rn "require_relative" lib/uniword/wordprocessingml/ > wordprocessingml_requires.txt
   ```

3. **Build complete class list** (15 min)
   - Read each file
   - Extract class name
   - Match to file name
   - Create autoload mapping

### Phase 2: Autoload Declaration (1 hour)

1. **Add all autoload statements** (45 min)
   - Edit [`lib/uniword/wordprocessingml.rb`](lib/uniword/wordprocessingml.rb)
   - Add ~50 autoload declarations
   - Group by category (Core, Properties, SDT, Complex)
   - Alphabetize within groups

2. **Remove require_relative statements** (15 min)
   - DON'T remove from class files yet
   - Just ensure autoloads work first

### Phase 3: Verification (30 min)

1. **Quick load test** (5 min)
   ```bash
   bundle exec ruby -e "require './lib/uniword'; puts 'OK'"
   ```

2. **Run test suite** (20 min)
   ```bash
   bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb
   ```

3. **Verify no regressions** (5 min)
   - Must maintain 81/258 passing (31.4%)
   - OR improve (better!)
   - No new NameError/LoadError

### Phase 4: Cleanup (30 min)

1. **Remove require_relative** (20 min)
   - Only after autoloads verified
   - Edit each Wordprocessingml class file
   - Remove `require_relative` for Wordprocessingml classes

2. **Final verification** (10 min)
   - Run tests again
   - Confirm still 81/258+ passing

---

## Success Criteria

- [ ] All Wordprocessingml classes have autoload declarations
- [ ] Library loads without errors
- [ ] Tests maintain 81/258 passing (31.4%) OR improve
- [ ] Zero new NameError or LoadError
- [ ] Documentation updated

---

## Risk Assessment

### Low Risk
- Autoload pattern proven in Step 1
- Clear mapping: ClassName → file_name
- Easy to verify (load test)

### Medium Risk
- Large number of files (~50)
- Circular dependencies possible
- Need careful ordering

### Mitigation
- Do inventory first (know what we're converting)
- Add autoloads incrementally
- Test after each batch
- Keep Step 2 baseline for comparison

---

## Time Budget

| Phase | Task | Estimated | Notes |
|-------|------|-----------|-------|
| 1 | Inventory | 30 min | List all files & classes |
| 2 | Autoload declarations | 1 hour | Add ~50 autoloads |
| 3 | Verification | 30 min | Test & verify |
| 4 | Cleanup | 30 min | Remove require_relative |
| **TOTAL** | | **2.5-3 hours** | Conservative estimate |

**Buffer**: +1 hour for unexpected issues
**Total**: 3-4 hours (as planned)

---

## Expected Outcomes

### Best Case (80% probability)
- All autoloads work first try
- Tests improve to 85-90/258 passing
- Time: 2.5 hours

### Normal Case (15% probability)
- Few circular dependency issues
- Tests maintain 81/258 passing
- Time: 3 hours

### Worst Case (5% probability)
- Major circular dependencies
- Need refactoring
- Time: 4+ hours

---

## Rollback Plan

If major issues occur:
1. Revert [`lib/uniword/wordprocessingml.rb`](lib/uniword/wordprocessingml.rb) to Step 2 state
2. git checkout the file
3. Restart from Phase 1 with better inventory

---

## Files to Monitor

### Primary
- [`lib/uniword/wordprocessingml.rb`](lib/uniword/wordprocessingml.rb) - Main autoload file
- `lib/uniword/wordprocessingml/*.rb` - Class files

### Secondary
- [`lib/uniword.rb`](lib/uniword.rb) - Top-level loader
- `test_results_step3.txt` - Test output

### Reference
- [`AUTOLOAD_WEEK3_SESSION3_BASELINE_VERIFIED.md`](AUTOLOAD_WEEK3_SESSION3_BASELINE_VERIFIED.md) - Step 2 baseline
- [`AUTOLOAD_WEEK3_SESSION3_STATUS.md`](AUTOLOAD_WEEK3_SESSION3_STATUS.md) - Overall status

---

## Start Command

```bash
cd /Users/mulgogi/src/mn/uniword

# Phase 1: Inventory
ls lib/uniword/wordprocessingml/*.rb > wordprocessingml_files.txt
wc -l wordprocessingml_files.txt

# Extract requires
grep -rn "require_relative.*wordprocessingml" lib/uniword/wordprocessingml/ > wordprocessingml_requires.txt
wc -l wordprocessingml_requires.txt
```

---

## Key Reminders

1. **Pattern 0**: Attributes BEFORE xml mappings (not relevant for autoload, but good to remember)
2. **MECE**: Each class in ONE file, ONE autoload
3. **OOP**: Infrastructure vs Models separation
4. **No Shortcuts**: Do it right, even if tests initially regress
5. **Incremental**: Test after each batch of autoloads

---

**Ready to Begin**: YES ✅
**Blocker**: None
**Estimated Completion**: 3-4 hours from start

---

## References

- **Step 1 Complete**: [`AUTOLOAD_WEEK3_SESSION3_STEP1_COMPLETE.md`](AUTOLOAD_WEEK3_SESSION3_STEP1_COMPLETE.md)
- **Step 2 Baseline**: [`AUTOLOAD_WEEK3_SESSION3_BASELINE_VERIFIED.md`](AUTOLOAD_WEEK3_SESSION3_BASELINE_VERIFIED.md)
- **Overall Plan**: [`AUTOLOAD_WEEK3_SESSION3_CONTINUATION_PLAN.md`](AUTOLOAD_WEEK3_SESSION3_CONTINUATION_PLAN.md)
- **Status Tracker**: [`AUTOLOAD_WEEK3_SESSION3_STATUS.md`](AUTOLOAD_WEEK3_SESSION3_STATUS.md)
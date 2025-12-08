# Uniword: Week 3 Session 2 - Archive Old Code & Documentation Cleanup

**Task**: Archive obsolete documentation and prepare for Phase 2
**Duration**: 1-1.5 hours
**Prerequisites**: Session 1 Complete (formats/ directory deleted)

---

## Quick Context

**Session 1 Complete**: ✅ lib/uniword/formats/ directory deleted (3 files, ~350 lines)
**Current State**: 163 files with require_relative remaining
**Next Phase**: Element file conversion (Wordprocessingml, Properties)
**Goal**: Clean up temporary docs, prepare architecture for Phase 2

---

## Step-by-Step Execution

### Step 1: Move Obsolete Documentation (20 min)

Move completed work documentation to old-docs/:

```bash
# Create archive structure
mkdir -p old-docs/autoload-migration/week3/

# Move Session 1 completion docs
mv AUTOLOAD_WEEK3_SESSION1_PROMPT.md old-docs/autoload-migration/week3/
mv STYLESET_PACKAGE_COMPLETE.md old-docs/autoload-migration/week2/
mv STYLESET_PACKAGE_IMPLEMENTATION_PLAN.md old-docs/autoload-migration/week2/

# Move Week 2 completion docs
mv AUTOLOAD_WEEK2_SESSION2_COMPLETE.md old-docs/autoload-migration/week2/
mv AUTOLOAD_WEEK2_SESSION4_COMPLETE.md old-docs/autoload-migration/week2/
mv AUTOLOAD_WEEK2_SESSION2_PROMPT.md old-docs/autoload-migration/week2/

# Move Week 1 docs already archived
# (check old-docs/autoload-migration/completed/)
```

### Step 2: Audit Remaining require_relative (15 min)

Count and categorize remaining files:

```bash
# Count total
find lib/uniword -name "*.rb" -type f -exec grep -l "require_relative" {} \; | wc -l

# Group by directory
find lib/uniword -name "*.rb" -type f -exec grep -l "require_relative" {} \; | \
  xargs -I {} dirname {} | sort | uniq -c | sort -rn
```

**Expected categories**:
1. Wordprocessingml elements (~11 files)
2. Properties (~3 files)
3. Feature directories (quality, transformation, assembly, ~17 files)
4. lib/uniword.rb (legitimate namespace requires)
5. Circular dependencies (< 10 files - document these)

### Step 3: Create Conversion Checklist (10 min)

Document which files need conversion in each category:

```markdown
## Element Files to Convert (11 files)
- [ ] lib/uniword/wordprocessingml/table.rb
- [ ] lib/uniword/wordprocessingml/paragraph.rb
- [ ] lib/uniword/wordprocessingml/run.rb
- [ ] lib/uniword/wordprocessingml/level.rb
- [ ] lib/uniword/wordprocessingml/table_cell_properties.rb
- [ ] lib/uniword/wordprocessingml/r_pr_default.rb
- [ ] lib/uniword/wordprocessingml/p_pr_default.rb
- [ ] lib/uniword/wordprocessingml/document_root.rb
- [ ] lib/uniword/wordprocessingml/style.rb
- [ ] lib/uniword/wordprocessingml/structured_document_tag.rb
- [ ] (verify with search)

## Property Files to Convert (3 files)
- [ ] lib/uniword/styles_configuration.rb
- [ ] lib/uniword/structured_document_tag_properties.rb
- [ ] lib/uniword/section_properties.rb
```

### Step 4: Check for Dead Code (15 min)

Search for unused classes or files:

```bash
# Find classes defined but not required anywhere
for file in lib/uniword/**/*.rb; do
  class_name=$(basename "$file" .rb | sed 's/_\([a-z]\)/\U\1/g' | sed 's/^./\U&/')
  if ! grep -r "$class_name" lib/ spec/ --include="*.rb" -q; then
    echo "Possibly unused: $file ($class_name)"
  fi
done
```

**Action**: Document findings, mark for potential deletion

### Step 5: Update README.adoc Plan (10 min)

Check what README.adoc documentation needs updating:

```bash
# Check current Package documentation
grep -n "Package" README.adoc
grep -n "DOCX" README.adoc
grep -n "format" README.adoc
```

**Create plan**:
- [ ] Document new Package architecture
- [ ] Update API examples (from_file, to_file)
- [ ] Remove handler references
- [ ] Add format detection section

### Step 6: Create Phase 2 Conversion Strategy (10 min)

Document the conversion approach for element files:

**Strategy**:
1. Create Wordprocessingml module autoload index
2. Move element requires from files to module
3. Test after each file
4. Use Pattern: `autoload :ClassName, 'uniword/wordprocessingml/file_name'`

**Circular Dependency Handling**:
- Document any true circular deps
- Keep require_relative ONLY for circular deps
- Mark with comment: `# require_relative kept: circular dependency`

### Step 7: Run Baseline Tests (5 min)

Verify current state before Phase 2:

```bash
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb --format progress
```

**Expected**: 258 examples, 177 failures (baseline)

### Step 8: Commit Cleanup (5 min)

```bash
git add old-docs/
git commit -m "docs(autoload): Archive Week 2 and Session 1 documentation

Move completed autoload migration docs to old-docs/:
- Week 3 Session 1 prompts and completions
- Week 2 Package migration documentation
- StyleSet Package implementation docs

Organized structure:
- old-docs/autoload-migration/week2/
- old-docs/autoload-migration/week3/

Preparation for Phase 2 element file conversion."
```

### Step 9: Create Session 3 Prompt (10 min)

Generate detailed prompt for Wordprocessingml element conversion with:
- File list (11 files)
- Conversion pattern
- Testing strategy
- Expected completion time (2 hours)

### Step 10: Update Status Tracker (5 min)

Mark Session 2 complete in [`AUTOLOAD_WEEK3_STATUS.md`](AUTOLOAD_WEEK3_STATUS.md)

---

## Success Criteria Checklist

- [ ] All temporary docs moved to old-docs/
- [ ] require_relative audit complete (count + categories)
- [ ] Conversion checklist created
- [ ] Dead code scan complete
- [ ] README.adoc update plan created
- [ ] Phase 2 strategy documented
- [ ] Baseline tests passing (258/258)
- [ ] Cleanup commit created
- [ ] Session 3 prompt created
- [ ] Status tracker updated

---

## Expected Outcomes

| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| Temporary docs | ~15 files | 0 in root | Moved to old-docs/ |
| require_relative audit | Unknown | Complete | Documented |
| Phase 2 plan | None | Complete | Created |
| Baseline tests | 258/177 | 258/177 | Maintained |

---

## Files to Create

1. **AUTOLOAD_CONVERSION_CHECKLIST.md** - Complete conversion tracking
2. **AUTOLOAD_WEEK3_SESSION3_PROMPT.md** - Next session instructions
3. **README_UPDATE_PLAN.md** - Documentation update tasks

---

## Troubleshooting

### Issue: Can't find all require_relative files
**Solution**: Use `git grep "require_relative" lib/` for comprehensive search

### Issue: Unsure if file is dead code
**Solution**: Search usage with `git grep "ClassName" lib/ spec/` - if no hits, likely dead

### Issue: README.adoc unclear what needs updating
**Solution**: Focus on Package API, format detection, handler removal

---

**Created**: December 8, 2024
**Status**: Ready to execute
**Estimated Duration**: 1-1.5 hours
**Expected Result**: Clean slate for Phase 2, all temporary docs archived
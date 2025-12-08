# Uniword: Week 3 Session 1 - Delete lib/uniword/formats/ Directory

**Task**: Delete obsolete format handler directory and all orchestrator code  
**Duration**: 1.5 hours  
**Prerequisites**: Read [`AUTOLOAD_WEEK3_CONTINUATION_PLAN.md`](AUTOLOAD_WEEK3_CONTINUATION_PLAN.md)

---

## Quick Context

**Current State**: lib/uniword/formats/ contains obsolete orchestrator code  
**Week 2 Achievement**: All formats now use Package classes (DocxPackage, DotxPackage, ThmxPackage, MhtmlPackage)  
**Problem**: Old handler files are dead code, violate model-driven architecture  
**Solution**: Delete entire directory, clean up references

---

## Step-by-Step Execution

### Step 1: Verify Package Replacement (10 min)

Check that all format handlers have Package replacements:

```bash
ls -la lib/uniword/formats/
```

**Expected files** (all obsolete):
- mhtml_handler.rb → Replaced by MhtmlPackage
- format_handler_registry.rb → Replaced by FormatDetector
- base_handler.rb → No longer needed
- docx_handler.rb → Replaced by DocxPackage (if exists)

Verify Package classes exist:
```bash
ls -la lib/uniword/ooxml/*_package.rb
```

**Expected**:
- docx_package.rb ✅
- dotx_package.rb ✅
- thmx_package.rb ✅
- mhtml_package.rb ✅

### Step 2: Search for References (15 min)

Find any code still referencing format handlers:

```bash
# Search for format handler references
grep -r "FormatHandler" lib/ --include="*.rb" | grep -v "old-docs"

# Search for format registry
grep -r "FormatHandlerRegistry" lib/ --include="*.rb" | grep -v "old-docs"

# Search for base handler
grep -r "BaseHandler" lib/ --include="*.rb" | grep -v "old-docs"

# Search for formats/ directory requires
grep -r "formats/" lib/ --include="*.rb" | grep -v "old-docs"
```

**Expected**: Should only find in lib/uniword.rb autoload declarations

### Step 3: Update lib/uniword.rb (10 min)

Remove obsolete autoload declarations:

```ruby
# lib/uniword.rb

# DELETE these lines:
module Formats
  autoload :BaseHandler, 'uniword/formats/base_handler'
  autoload :DocxHandler, 'uniword/formats/docx_handler'
  autoload :MhtmlHandler, 'uniword/formats/mhtml_handler'
  autoload :FormatHandlerRegistry, 'uniword/formats/format_handler_registry'
end

# Formats module is now empty - delete it entirely:
# module Formats
#   ...
# end
```

The Formats module is obsolete. All format handling is now in Ooxml module via Package classes.

### Step 4: Verify No Other References (10 min)

Double-check these files don't reference handlers:
- lib/uniword/document_factory.rb ✅ (uses Package classes)
- lib/uniword/document_writer.rb ✅ (uses Package classes)
- lib/uniword/format_detector.rb ✅ (standalone)

```bash
# Should return nothing:
grep -l "Handler" lib/uniword/document_factory.rb
grep -l "Handler" lib/uniword/document_writer.rb
grep -l "Handler" lib/uniword/format_detector.rb
```

### Step 5: Delete format_handler_registry.rb (5 min)

```bash
git rm lib/uniword/formats/format_handler_registry.rb
```

**Rationale**: FormatDetector.detect_from_path() replaced all registry functionality

### Step 6: Delete mhtml_handler.rb (5 min)

```bash
git rm lib/uniword/formats/mhtml_handler.rb
```

**Rationale**: MhtmlPackage.from_file() replaced all handler functionality

### Step 7: Delete base_handler.rb (5 min)

```bash
git rm lib/uniword/formats/base_handler.rb
```

**Rationale**: No inheritance needed - each Package is self-contained

### Step 8: Delete docx_handler.rb (if exists) (5 min)

```bash
# Check if it still exists
if [ -f lib/uniword/formats/docx_handler.rb ]; then
  git rm lib/uniword/formats/docx_handler.rb
fi
```

**Rationale**: DocxPackage.from_file() replaced all handler functionality

### Step 9: Delete formats/ Directory (5 min)

```bash
# Verify directory is empty
ls -la lib/uniword/formats/

# Delete directory
git rm -r lib/uniword/formats/
```

**Expected**: Directory completely removed from git

### Step 10: Run Tests (15 min)

```bash
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb --format progress
```

**Expected Baseline**: 258 examples, 177 failures

**If failures increase**:
1. Check for missed handler references
2. Verify Package classes work correctly
3. Check lib/uniword.rb for syntax errors

### Step 11: Commit Changes (10 min)

```bash
# Stage changes
git add lib/uniword.rb

# Commit
git commit -m "refactor(architecture): Delete obsolete lib/uniword/formats/ directory

Remove all format handler orchestrator code. All format support now uses
model-driven Package classes.

Deleted files:
- lib/uniword/formats/mhtml_handler.rb (replaced by MhtmlPackage)
- lib/uniword/formats/format_handler_registry.rb (replaced by FormatDetector)
- lib/uniword/formats/base_handler.rb (no longer needed)
- lib/uniword/formats/docx_handler.rb (replaced by DocxPackage, if existed)
- lib/uniword/formats/ directory (entire directory removed)

Updated:
- lib/uniword.rb: Removed Formats module autoload declarations

Architecture improvements:
- ✅ Zero orchestrator layers (all deleted)
- ✅ Model-driven architecture (Package classes own I/O)
- ✅ MECE (no responsibility overlap)
- ✅ Cleaner codebase (~300-400 lines deleted)

Week 2 achievement: All 5 formats (DOCX, DOTX, THMX, MHTML) now use Package
classes with consistent model-driven patterns.

Test results:
- Before: 258 examples, 177 failures
- After: 258 examples, 177 failures
- Status: ✅ Baseline maintained, zero regressions"
```

### Step 12: Update Status Tracker (10 min)

Update AUTOLOAD_WEEK3_STATUS.md:

```markdown
## Phase 1: Delete Obsolete Code (1/2 sessions)

### Session 1: Remove formats/ Directory ✅ COMPLETE
**Actual Duration**: ~90 minutes
**Status**: ✅ COMPLETE

Deleted:
- [x] lib/uniword/formats/mhtml_handler.rb
- [x] lib/uniword/formats/format_handler_registry.rb
- [x] lib/uniword/formats/base_handler.rb
- [x] lib/uniword/formats/docx_handler.rb (if existed)
- [x] lib/uniword/formats/ directory
- [x] Removed Formats module from lib/uniword.rb

Test Results:
- Examples: 258
- Failures: 177 (baseline maintained)
- Status: ✅ Zero regressions
```

---

## Success Criteria Checklist

- [ ] All files in lib/uniword/formats/ identified
- [ ] No references to format handlers found (except old-docs/)
- [ ] lib/uniword.rb Formats module deleted
- [ ] format_handler_registry.rb deleted
- [ ] mhtml_handler.rb deleted
- [ ] base_handler.rb deleted
- [ ] docx_handler.rb deleted (if exists)
- [ ] lib/uniword/formats/ directory deleted
- [ ] Tests: 258 examples, ≤177 failures
- [ ] Commit created
- [ ] Status tracker updated

---

## Expected Metrics

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Files with require_relative | 163 | ~160 | -3 |
| Lines of code | N/A | N/A | -300-400 |
| Orchestrator files | 4 | 0 | -4 |
| Directories | formats/ | (deleted) | -1 |
| Test failures | 177 | ≤177 | 0 |

---

## Troubleshooting

### Issue: grep finds handler references in application code
**Solution**: Those files need updating - create a list and handle in Session 2

### Issue: Tests fail with "uninitialized constant"
**Solution**: Check lib/uniword.rb - may have syntax error from module deletion

### Issue: Tests fail with "undefined method"
**Solution**: Verify Package classes have from_file/to_file methods

### Issue: Directory not empty after deletions
**Solution**: Check for hidden files (.gitkeep, etc.) and delete manually

---

## Post-Session Actions

After completing this session:
1. Verify lib/uniword/formats/ no longer exists
2. Check `git status` shows all deletions staged
3. Confirm tests maintain baseline
4. Note any unexpected issues for Session 2

---

**Created**: December 8, 2024  
**Status**: Ready to execute  
**Estimated Duration**: 1.5 hours  
**Expected Result**: lib/uniword/formats/ directory completely removed, ~400 lines deleted
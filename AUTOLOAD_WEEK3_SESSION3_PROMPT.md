# Uniword: Week 3 Session 3 - Wordprocessingml Element File Conversion

**Task**: Convert 10 Wordprocessingml element files from require_relative to autoload
**Duration**: 2-3 hours
**Prerequisites**: Session 2 Complete (documentation archived, audit complete)

---

## Quick Context

**Session 2 Complete**: ✅ Documentation archived, 160 require_relative files audited
**Current State**: 10 Wordprocessingml element files need conversion
**Goal**: Create Wordprocessingml module autoload index, convert all element files

---

## Files to Convert (10 files)

```
lib/uniword/wordprocessingml/table.rb
lib/uniword/wordprocessingml/paragraph.rb
lib/uniword/wordprocessingml/run.rb
lib/uniword/wordprocessingml/level.rb
lib/uniword/wordprocessingml/table_cell_properties.rb
lib/uniword/wordprocessingml/r_pr_default.rb
lib/uniword/wordprocessingml/p_pr_default.rb
lib/uniword/wordprocessingml/document_root.rb
lib/uniword/wordprocessingml/style.rb
lib/uniword/wordprocessingml/structured_document_tag.rb
```

---

## Step-by-Step Execution

### Step 1: Create Wordprocessingml Module File (15 min)

Create `lib/uniword/wordprocessingml.rb`:

```ruby
# frozen_string_literal: true

module Uniword
  module Wordprocessingml
    # Core elements
    autoload :DocumentRoot, 'uniword/wordprocessingml/document_root'
    autoload :Paragraph, 'uniword/wordprocessingml/paragraph'
    autoload :Run, 'uniword/wordprocessingml/run'
    autoload :Table, 'uniword/wordprocessingml/table'
    
    # Structure and metadata
    autoload :Level, 'uniword/wordprocessingml/level'
    autoload :Style, 'uniword/wordprocessingml/style'
    autoload :StructuredDocumentTag, 'uniword/wordprocessingml/structured_document_tag'
    
    # Properties
    autoload :TableCellProperties, 'uniword/wordprocessingml/table_cell_properties'
    autoload :RPrDefault, 'uniword/wordprocessingml/r_pr_default'
    autoload :PPrDefault, 'uniword/wordprocessingml/p_pr_default'
  end
end
```

**Add to `lib/uniword.rb`** after other module autoloads:
```ruby
autoload :Wordprocessingml, 'uniword/wordprocessingml'
```

### Step 2: Audit Each File's require_relative (30 min)

For each of the 10 files, document what they require:

```bash
for file in lib/uniword/wordprocessingml/{table,paragraph,run,level,table_cell_properties,r_pr_default,p_pr_default,document_root,style,structured_document_tag}.rb; do
  echo "=== $(basename $file) ==="
  grep "require_relative" "$file"
  echo ""
done
```

**Expected findings**:
- Properties classes (already in Properties module)
- Other wordprocessingml classes (now in Wordprocessingml module)
- OOXML classes (may need separate handling)
- Possible circular dependencies

### Step 3: Convert Files One-by-One (60-90 min)

**Pattern for each file**:

1. **Check requires**:
   ```bash
   grep "require_relative" lib/uniword/wordprocessingml/table.rb
   ```

2. **Remove or comment require_relative lines**:
   - Properties: Remove (Properties module handles)
   - Other wordprocessingml: Remove (Wordprocessingml module handles)
   - Circular deps: Keep with comment

3. **Test immediately**:
   ```bash
   bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb \
                    spec/uniword/theme_roundtrip_spec.rb \
                    --format progress
   ```

4. **Expected**: 258/258 baseline maintained

**Conversion Order** (dependencies first):
1. level.rb (likely no deps)
2. r_pr_default.rb (default properties)
3. p_pr_default.rb (default properties)
4. table_cell_properties.rb (properties)
5. run.rb (depends on r_pr_default)
6. paragraph.rb (depends on p_pr_default)
7. table.rb (depends on table_cell_properties)
8. structured_document_tag.rb (metadata)
9. style.rb (uses properties)
10. document_root.rb (uses everything)

### Step 4: Handle Circular Dependencies (15 min)

If any file cannot remove require_relative due to circular dependency:

```ruby
# In the file that must keep require_relative
require_relative 'other_file'  # require_relative kept: circular dependency

# Add comment explaining:
# FileA.initialize needs FileB constant immediately loaded
# FileB.some_method references FileA
# Cannot use autoload - breaks constant resolution
```

**Document in** `AUTOLOAD_CONVERSION_CHECKLIST.md`:
```markdown
### Circular Dependencies Found

1. **table.rb ↔ paragraph.rb**
   - table.rb line 15: needs Paragraph for nested content
   - paragraph.rb line 28: needs Table for table cells
   - Solution: Keep require_relative in both
```

### Step 5: Update Tests (10 min)

Verify autoloading works correctly:

```bash
# Run full baseline
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb \
                 s
pec/uniword/theme_roundtrip_spec.rb \
                 --format progress

# Expected: 258 examples, 177 failures (baseline maintained)
```

**Check for new failures**:
- NameError (constant not found) → autoload missing
- LoadError (file not found) → path incorrect
- NoMethodError (unexpected) → circular dependency issue

### Step 6: Run Full Test Suite (10 min)

```bash
bundle exec rspec --format progress
```

**Expected outcome**:
- No NEW failures beyond baseline
- All autoloads working
- Circular deps documented (if any)

### Step 7: Commit Changes (10 min)

```bash
git add lib/uniword/wordprocessingml.rb \
        lib/uniword/wordprocessingml/*.rb \
        lib/uniword.rb \
        AUTOLOAD_CONVERSION_CHECKLIST.md

git commit -m "refactor(autoload): Convert Wordprocessingml elements to autoload

Create lib/uniword/wordprocessingml.rb module with autoloads for:
- Core elements: DocumentRoot, Paragraph, Run, Table
- Structure: Level, Style, StructuredDocumentTag  
- Properties: TableCellProperties, RPrDefault, PPrDefault

Remove require_relative from 10 element files.
$(if circul ar deps) Document circular dependencies: <list>

Files converted: 10/10
Baseline tests: 258/258 maintained (177 known failures)
Circular dependencies: <N> documented

Phase 2 Session 3 complete."
```

### Step 8: Update Status Tracker (5 min)

Mark Session 3 complete in `AUTOLOAD_WEEK3_STATUS.md`:
- Session 3: ✅ Wordprocessingml conversion complete
- Files converted: 10
- Circular deps: N (if any)

### Step 9: Plan Session 4 (10 min)

Decide next target:
- **Option A**: Properties/ directory (29 files)
- **Option B**: OOXML core (9 files)
- **Option C**: Feature directories (start with smallest)

Create Session 4 prompt based on choice.

---

## Success Criteria Checklist

- [ ] Created lib/uniword/wordprocessingml.rb with 10 autoloads
- [ ] Added autoload to lib/uniword.rb
- [ ] Converted 10 element files (removed require_relative)
- [ ] Documented circular dependencies (if any)
- [ ] Baseline tests passing (258/258)
- [ ] No new test failures
- [ ] Changes committed
- [ ] Status tracker updated
- [ ] Session 4 prompt created

---

## Expected Outcomes

| Metric | Start | Target | Status |
|--------|-------|--------|--------|
| Wordprocessingml require_relative | 10 | 0-2 | Conversion |
| Total require_relative | 160 | ~150 | Progress |
| Baseline tests | 258/177 | 258/177 | Maintained |
| Circular deps | Unknown | Documented | - |

---

## Troubleshooting

### Issue: NameError - uninitialized constant
**Solution**: Add missing autoload to Wordprocessingml module

### Issue: LoadError - cannot load file
**Solution**: Check autoload path matches file location

### Issue: Tests fail after removing require_relative
**Solution**: Likely circular dependency - document and keep require_relative

### Issue: Module Wordprocessingml doesn't exist error
**Solution**: Ensure lib/uniword/wordprocessingml.rb is loaded via lib/uniword.rb

---

**Created**: December 8, 2024
**Status**: Ready to execute
**Estimated Duration**: 2-3 hours
**Expected Result**: Wordprocessingml elements use autoload, 10 files converted
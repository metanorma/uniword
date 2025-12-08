# Uniword Week 3 Session 3: Namespace Consolidation - EXECUTION

**CRITICAL ISSUE DISCOVERED**: Two conflicting WordProcessingML namespaces exist and must be consolidated.

**Context**: During Wordprocessingml autoload conversion, we discovered:
- `Uniword::Wordprocessingml` (90+ element files)
- `Uniword::Ooxml::WordProcessingML` (3 properties files)
- Both coexist, causing circular dependency and autoload failure

**Plan Created**: `AUTOLOAD_WEEK3_SESSION3_NAMESPACE_FIX_PLAN.md` (comprehensive 8-step plan)

**This Task**: Execute the consolidation plan to achieve single namespace

---

## Execution Steps (45-60 minutes)

### Step 1: Backup Current State (2 min)

```bash
git add -A
git commit -m "wip: wordprocessingml conversion before namespace fix"
```

### Step 2: Move Properties Files (5 min)

Move 3 files from `lib/uniword/ooxml/wordprocessingml/` to `lib/uniword/wordprocessingml/`:

```bash
mv lib/uniword/ooxml/wordprocessingml/paragraph_properties.rb lib/uniword/wordprocessingml/
mv lib/uniword/ooxml/wordprocessingml/run_properties.rb lib/uniword/wordprocessingml/
mv lib/uniword/ooxml/wordprocessingml/table_properties.rb lib/uniword/wordprocessingml/
```

### Step 3: Update Namespace in Properties Files (10 min)

For EACH of the 3 properties files, change the module nesting:

**File 1**: `lib/uniword/wordprocessingml/paragraph_properties.rb`
**File 2**: `lib/uniword/wordprocessingml/run_properties.rb`
**File 3**: `lib/uniword/wordprocessingml/table_properties.rb`

**Change:**
```ruby
# FROM:
module Uniword
  module Ooxml
    module WordProcessingML
      class ParagraphProperties < Lutaml::Model::Serializable

# TO:
module Uniword
  module Wordprocessingml
    class ParagraphProperties < Lutaml::Model::Serializable
```

**IMPORTANT**: Update CLOSING `end` statements too (remove one level)

### Step 4: Update References in Element Files (20 min)

Update 10 element files to use new namespace. Change ALL occurrences:

**FROM**: `Uniword::Ooxml::WordProcessingML::ParagraphProperties`
**TO**: `Wordprocessingml::ParagraphProperties`

**Files to update:**
1. `lib/uniword/wordprocessingml/paragraph.rb` (multiple lines)
2. `lib/uniword/wordprocessingml/run.rb` (multiple lines)
3. `lib/uniword/wordprocessingml/document_root.rb` (2 occurrences)
4. `lib/uniword/wordprocessingml/level.rb` (2 occurrences)
5. `lib/uniword/wordprocessingml/r_pr_default.rb` (1 occurrence)
6. `lib/uniword/wordprocessingml/p_pr_default.rb` (1 occurrence)
7. `lib/uniword/wordprocessingml/style.rb` (3 occurrences)
8. `lib/uniword/wordprocessingml/table.rb` (1 occurrence)
9. `lib/uniword/wordprocessingml/body.rb` (check - may have SectionProperties)
10. `lib/uniword/wordprocessingml/table_cell_properties.rb` (check - may already be correct)

**Search command to find all references:**
```bash
grep -r "Ooxml::WordProcessingML" lib/uniword/wordprocessingml/
```

### Step 5: Update Autoload Files (5 min)

**File 1**: `lib/uniword/wordprocessingml.rb`

Add 3 properties class autoloads:
```ruby
# Properties classes (consolidated from Ooxml::WordProcessingML)
autoload :ParagraphProperties, 'uniword/wordprocessingml/paragraph_properties'
autoload :RunProperties, 'uniword/wordprocessingml/run_properties'
autoload :TableProperties, 'uniword/wordprocessingml/table_properties'
```

**File 2**: `lib/uniword.rb`

**Remove** this line (around line 17):
```ruby
require_relative 'uniword/ooxml/wordprocessingml'  # DELETE
```

**Update** aliases (around lines 71-73):
```ruby
# FROM:
ParagraphProperties = Ooxml::WordProcessingML::ParagraphProperties
RunProperties = Ooxml::WordProcessingML::RunProperties
TableProperties = Ooxml::WordProcessingML::TableProperties

# TO:
ParagraphProperties = Wordprocessingml::ParagraphProperties
RunProperties = Wordprocessingml::RunProperties
TableProperties = Wordprocessingml::TableProperties
```

### Step 6: Delete Old Module File (2 min)

```bash
rm lib/uniword/ooxml/wordprocessingml.rb
rmdir lib/uniword/ooxml/wordprocessingml  # if directory is empty
```

### Step 7: Verify & Test (5 min)

**Verify no remaining references:**
```bash
grep -r "Ooxml::WordProcessingML" lib/
```
Expected: No matches (or only in comments/docs)

**Run baseline tests:**
```bash
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb \
                 spec/uniword/theme_roundtrip_spec.rb --format progress
```

**Expected**: 258 examples, 177 failures (baseline maintained)

### Step 8: Commit Changes (3 min)

```bash
git add -A
git commit -m "refactor(namespace): consolidate WordProcessingML into single namespace

- Move 3 properties files from Ooxml::WordProcessingML to Wordprocessingml
- Update namespace declarations in properties files
- Update all references in 10 element files
- Remove duplicate module file and empty directory
- Consolidate autoloads in wordprocessingml.rb

BREAKING: Uniword::Ooxml::WordProcessingML namespace removed
Use Uniword::Wordprocessingml::*Properties instead

This fixes namespace conflict causing autoload failures during
Week 3 Session 3 wordprocessingml element conversion.

Files changed: 16
- Moved: 3 properties files
- Updated: 10 element files + 3 properties files
- Deleted: 1 module file

Baseline tests: 258/258 maintained (177 known failures)"
```

---

## Success Criteria Checklist

- [ ] Step 1: Git backup complete
- [ ] Step 2: 3 properties files moved to wordprocessingml/
- [ ] Step 3: Namespace updated in 3 properties files
- [ ] Step 4: References updated in 10 element files
- [ ] Step 5: Autoloads updated in 2 files
- [ ] Step 6: Old module file deleted
- [ ] Step 7: No remaining Ooxml::WordProcessingML references, tests passing
- [ ] Step 8: Changes committed

---

## Expected Outcome

**BEFORE** (broken):
```
Uniword::
├── Wordprocessingml:: (elements - 90+ files)
└── Ooxml::
    └── WordProcessingML:: (properties - 3 files)  ← CONFLICT!
```

**AFTER** (fixed):
```
Uniword::
└── Wordprocessingml:: (ALL wordprocessingml - 93+ files) ✅
    ├── DocumentRoot, Body, Paragraph, Run, Table...
    └── ParagraphProperties, RunProperties, TableProperties
```

---

## Troubleshooting

**Issue**: NameError after Step 3
**Solution**: Ensure namespace nesting is EXACT (2 levels, not 3)

**Issue**: Tests still failing after Step 7
**Solution**: Run grep to find missed references, update them

**Issue**: Git conflicts
**Solution**: Stash changes, re-apply carefully after backup

---

**Created**: December 8, 2024
**Status**: Ready to execute
**Estimated Time**: 45-60 minutes
**Priority**: CRITICAL - Blocks Session 3 completion
# Uniword Week 3 Session 3: Namespace Consolidation Plan

## Problem Identified

TWO conflicting WordProcessingML namespaces exist:

1. **`Uniword::Wordprocessingml`** (`lib/uniword/wordprocessingml/`)
   - Element classes: DocumentRoot, Body, Paragraph, Run, Table, etc.
   - 90+ files
   - Used in document structure

2. **`Uniword::Ooxml::WordProcessingML`** (`lib/uniword/ooxml/wordprocessingml/`)
   - Properties classes: ParagraphProperties, RunProperties, TableProperties
   - 3 files
   - Used for formatting

**The Conflict**: Element classes reference properties with fully qualified names:
```ruby
# In paragraph.rb
attribute :properties, Uniword::Ooxml::WordProcessingML::ParagraphProperties
```

This creates CIRCULAR dependency issues and namespace confusion.

---

## Root Cause Analysis

**Historical Context:**
- `Ooxml::WordProcessingML` was created FIRST for properties (Phase 4 work)
- `Wordprocessingml` was created LATER for elements (v2.0 schema generation)
- No consolidation happened - both coexist awkwardly

**Why This Breaks Autoload:**
1. `Wordprocessingml` module tries to autoload element classes
2. Element classes reference `Ooxml::WordProcessingML::*Properties`
3. `Ooxml::WordProcessingML` module doesn't exist yet (autoload not triggered)
4. NameError: uninitialized constant

---

## Solution: Consolidate into ONE Namespace

### Option A: Move Properties INTO Wordprocessingml (RECOMMENDED)

**Structure:**
```
Uniword::Wordprocessingml::
├── DocumentRoot, Body, Paragraph, Run, Table (elements)
├── ParagraphProperties, RunProperties, TableProperties (properties)
└── (all other wordprocessingml classes)
```

**Changes Required:**
1. Move `lib/uniword/ooxml/wordprocessingml/*.rb` → `lib/uniword/wordprocessingml/`
2. Update namespace in 3 properties files: `Ooxml::WordProcessingML` → `Wordprocessingml`
3. Update ALL references in element files (10 files already converted)
4. Remove `lib/uniword/ooxml/wordprocessingml.rb` module file
5. Update `lib/uniword/wordprocessingml.rb` autoloads (add 3 properties classes)

**Pros:**
- Single namespace for all WordProcessingML
- Clear, logical organization
- Easier to maintain

**Cons:**
- Must update references in 10+ files

---

### Option B: Keep Separate BUT Fix References (NOT RECOMMENDED)

Keep both namespaces but fix circular dependency by requiring Properties first.

**Cons:**
- Maintains confusing dual-namespace
- Harder to maintain
- Violates DRY principle

---

## Recommended Approach: Option A

### Step 1: Backup Current State
```bash
git add -A
git commit -m "wip: wordprocessingml conversion before namespace fix"
```

### Step 2: Move Properties Files (3 files)
```bash
mv lib/uniword/ooxml/wordprocessingml/paragraph_properties.rb \
   lib/uniword/wordprocessingml/

mv lib/uniword/ooxml/wordprocessingml/run_properties.rb \
   lib/uniword/wordprocessingml/

mv lib/uniword/ooxml/wordprocessingml/table_properties.rb \
   lib/uniword/wordprocessingml/
```

### Step 3: Update Namespace in Properties Files (3 files)

**In each properties file, change:**
```ruby
# BEFORE
module Uniword
  module Ooxml
    module WordProcessingML
      class ParagraphProperties < Lutaml::Model::Serializable
```

**TO:**
```ruby
# AFTER
module Uniword
  module Wordprocessingml
    class ParagraphProperties < Lutaml::Model::Serializable
```

**Files to update:**
- `lib/uniword/wordprocessingml/paragraph_properties.rb`
- `lib/uniword/wordprocessingml/run_properties.rb`
- `lib/uniword/wordprocessingml/table_properties.rb`

### Step 4: Update References in Element Files (10 files)

**Change ALL occurrences:**
```ruby
# BEFORE
Uniword::Ooxml::WordProcessingML::ParagraphProperties

# TO
Wordprocessingml::ParagraphProperties
# OR
ParagraphProperties  # if in same module
```

**Files to update:**
- paragraph.rb (line 14, 61, 70, 113-114, others)
- run.rb (line 13, 48, 55, 62, 69, 76, 83, 90, 97, 104, 111, 118, 125)
- document_root.rb (line 47, 61)
- level.rb (line 19-20)
- r_pr_default.rb (line 13)
- p_pr_default.rb (line 13)
- style.rb (line 25-27)
- table.rb (line 13)
- body.rb (none - SectionProperties is separate)
- table_cell_properties.rb (none - uses Properties namespace)

### Step 5: Update Autoload Files (2 files)

**In `lib/uniword/wordprocessingml.rb`**, add:
```ruby
# Properties classes (moved from Ooxml::WordProcessingML)
autoload :ParagraphProperties, 'uniword/wordprocessingml/paragraph_properties'
autoload :RunProperties, 'uniword/wordprocessingml/run_properties'
autoload :TableProperties, 'uniword/wordprocessingml/table_properties'
```

**In `lib/uniword.rb`**, remove:
```ruby
require_relative 'uniword/ooxml/wordprocessingml'  # DELETE THIS LINE
```

**Also update aliases (lines 71-73):**
```ruby
# BEFORE
ParagraphProperties = Ooxml::WordProcessingML::ParagraphProperties
RunProperties = Ooxml::WordProcessingML::RunProperties
TableProperties = Ooxml::WordProcessingML::TableProperties

# AFTER
ParagraphProperties = Wordprocessingml::ParagraphProperties
RunProperties = Wordprocessingml::RunProperties
TableProperties = Wordprocessingml::TableProperties
```

### Step 6: Delete Old Module File
```bash
rm lib/uniword/ooxml/wordprocessingml.rb
rmdir lib/uniword/ooxml/wordprocessingml  # if empty
```

### Step 7: Test
```bash
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb \
                 spec/uniword/theme_roundtrip_spec.rb --format progress
```

**Expected**: 258/258 baseline maintained

### Step 8: Commit
```bash
git add -A
git commit -m "refactor(namespace): consolidate WordProcessingML into single namespace

- Move 3 properties files from Ooxml::WordProcessingML to Wordprocessingml
- Update namespace declarations in properties files
- Update all references in 10 element files
- Remove duplicate module file
- Consolidate autoloads

BREAKING: Uniword::Ooxml::WordProcessingML namespace removed
Use Uniword::Wordprocessingml::*Properties instead

Fixes namespace conflict causing autoload failures"
```

---

## Estimated Duration

**Total**: 45-60 minutes

- Step 1-2 (Backup + Move): 5 min
- Step 3 (Update namespace in 3 files): 10 min
- Step 4 (Update references in 10 files): 20 min
- Step 5 (Update autoloads): 5 min
- Step 6 (Cleanup): 2 min
- Step 7 (Test): 3 min
- Step 8 (Commit): 2 min

---

## Success Criteria

- [x] Only ONE WordProcessingML namespace exists
- [x] All 13 files (3 properties + 10 elements) use same namespace
- [x] Zero require_relative statements
- [x] Baseline tests passing (258/258)
- [x] No NameError exceptions
- [x] Clean git history

---

## Risks & Mitigation

**Risk**: Breaking existing code that references `Ooxml::WordProcessingML`
**Mitigation**:
- This is internal refactoring

 (pre-v1.1.0)
- Add deprecation warning if needed
- Document in CHANGELOG

**Risk**: Missing references in untested code paths
**Mitigation**:
- Comprehensive grep for `Ooxml::WordProcessingML`
- Run full test suite

---

**Created**: December 8, 2024
**Status**: Ready to execute
**Priority**: CRITICAL (blocks Session 3 completion)
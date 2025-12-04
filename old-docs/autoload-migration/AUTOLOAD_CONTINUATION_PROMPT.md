# Uniword Autoload Migration: Continuation Prompt

**COMPRESSED TIMELINE**: 4 hours (from 6.5 hours)  
**DEADLINE**: Complete ASAP  
**CURRENT STATUS**: Analysis Complete, Ready for Implementation

---

## Quick Start

### Prerequisites

```bash
cd /Users/mulgogi/src/mn/uniword
git checkout -b feature/autoload-migration
bundle install
```

### Status Check

```bash
# Verify current structure
ls lib/uniword/*.rb | head -20
ls lib/uniword/wordprocessingml/*.rb | head -5
bundle exec rspec --version
```

---

## SESSION 1: Foundation (90 minutes) ⚡ START HERE

**Goal**: Create 3 missing namespace loaders + Update main file

### TASK 1A: Create Missing Namespace Loaders (30 minutes)

#### Step 1: Create lib/uniword/shared_types.rb (10 min)

```bash
# Generate autoload statements
cd lib/uniword/shared_types
for file in *.rb; do
  base=$(basename "$file" .rb)
  class=$(echo "$base" | ruby -e 'puts ARGF.read.split("_").map(&:capitalize).join')
  echo "    autoload :$class, File.expand_path('shared_types/$base', __dir__)"
done > /tmp/shared_types_autoloads.txt

# Review generated autoloads
cat /tmp/shared_types_autoloads.txt
```

**Create the file**:
```ruby
# frozen_string_literal: true

# Shared Types Namespace
# Common types used across multiple OOXML namespaces

module Uniword
  module SharedTypes
    # Paste autoload statements from /tmp/shared_types_autoloads.txt here
  end
end
```

**Test**:
```bash
cd /Users/mulgogi/src/mn/uniword
ruby -e "require './lib/uniword/shared_types'; puts 'shared_types OK'"
```

#### Step 2: Create lib/uniword/content_types.rb (10 min)

```bash
# Generate autoload statements
cd lib/uniword/content_types
for file in *.rb; do
  base=$(basename "$file" .rb)
  class=$(echo "$base" | ruby -e 'puts ARGF.read.split("_").map(&:capitalize).join')
  echo "    autoload :$class, File.expand_path('content_types/$base', __dir__)"
done > /tmp/content_types_autoloads.txt

cat /tmp/content_types_autoloads.txt
```

**Create the file**:
```ruby
# frozen_string_literal: true

# Content Types Namespace
# Handles [Content_Types].xml in DOCX packages

module Uniword
  module ContentTypes
    # Paste autoload statements from /tmp/content_types_autoloads.txt here
  end
end
```

**Test**:
```bash
cd /Users/mulgogi/src/mn/uniword
ruby -e "require './lib/uniword/content_types'; puts 'content_types OK'"
```

#### Step 3: Create lib/uniword/document_properties.rb (10 min)

```bash
# Generate autoload statements
cd lib/uniword/document_properties
for file in *.rb; do
  base=$(basename "$file" .rb)
  class=$(echo "$base" | ruby -e 'puts ARGF.read.split("_").map(&:capitalize).join')
  echo "    autoload :$class, File.expand_path('document_properties/$base', __dir__)"
done > /tmp/document_properties_autoloads.txt

cat /tmp/document_properties_autoloads.txt
```

**Create the file**:
```ruby
# frozen_string_literal: true

# Document Properties Namespace
# Handles core.xml and app.xml document properties

module Uniword
  module DocumentProperties
    # Paste autoload statements from /tmp/document_properties_autoloads.txt here
  end
end
```

**Test**:
```bash
cd /Users/mulgogi/src/mn/uniword
ruby -e "require './lib/uniword/document_properties'; puts 'document_properties OK'"
```

**CHECKPOINT 1**: All 3 namespace loaders created and loading without error ✅

---

### TASK 1B: Update Main lib/uniword.rb (60 minutes)

#### Step 1: Backup Current File (1 min)

```bash
cp lib/uniword.rb lib/uniword.rb.backup
```

#### Step 2: Update Lines 19-27 (Convert require_relative to autoload) (10 min)

**FIND** (lines 19-27):
```ruby
require_relative 'uniword/wordprocessingml'
require_relative 'uniword/drawingml'
require_relative 'uniword/wp_drawing'
require_relative 'uniword/vml'
require_relative 'uniword/math'
require_relative 'uniword/shared_types'
require_relative 'uniword/content_types'
require_relative 'uniword/document_properties'
require_relative 'uniword/glossary'
```

**REPLACE WITH**:
```ruby
# Autoload namespace modules (loaded only when accessed)
autoload :Wordprocessingml, 'uniword/wordprocessingml'
autoload :DrawingML, 'uniword/drawingml'
autoload :WpDrawing, 'uniword/wp_drawing'
autoload :Vml, 'uniword/vml'
autoload :Math, 'uniword/math'
autoload :SharedTypes, 'uniword/shared_types'
autoload :ContentTypes, 'uniword/content_types'
autoload :DocumentProperties, 'uniword/document_properties'
autoload :Glossary, 'uniword/glossary'
```

**Test After Change**:
```bash
ruby -e "require './lib/uniword'; puts 'Main module loads'"
ruby -e "require './lib/uniword'; puts Uniword::Wordprocessingml"
```

#### Step 3: Add Missing Top-Level Class Autoloads (45 min)

**Location**: After existing autoloads (around line 120, after CLI autoload)

**Add these sections**:

```ruby
# === Infrastructure Classes ===
autoload :Builder, 'uniword/builder'
autoload :ElementRegistry, 'uniword/element_registry'
autoload :LazyLoader, 'uniword/lazy_loader'
autoload :StreamingParser, 'uniword/streaming_parser'
autoload :FormatConverter, 'uniword/format_converter'
autoload :Logger, 'uniword/logger'

# === Document Structure Elements ===
autoload :Chart, 'uniword/chart'
autoload :Field, 'uniword/field'
autoload :Footer, 'uniword/footer'
autoload :Footnote, 'uniword/footnote'
autoload :Endnote, 'uniword/endnote'
autoload :Header, 'uniword/header'
autoload :Picture, 'uniword/picture'
autoload :Revision, 'uniword/revision'
autoload :Section, 'uniword/section'
autoload :TextBox, 'uniword/text_box'
autoload :TextFrame, 'uniword/text_frame'
autoload :TrackedChanges, 'uniword/tracked_changes'

# === Configuration Classes ===
autoload :ColumnConfiguration, 'uniword/column_configuration'
autoload :DocumentVariables, 'uniword/document_variables'
autoload :LineNumbering, 'uniword/line_numbering'
autoload :PageBorders, 'uniword/page_borders'
autoload :SectionProperties, 'uniword/section_properties'
autoload :Shading, 'uniword/shading'
autoload :TabStop, 'uniword/tab_stop'

# === Numbering System ===
autoload :NumberingDefinition, 'uniword/numbering_definition'
autoload :NumberingInstance, 'uniword/numbering_instance'
autoload :NumberingLevel, 'uniword/numbering_level'

# === Comments and Ranges ===
autoload :Comment, 'uniword/comment'
autoload :CommentRange, 'uniword/comment_range'
autoload :CommentsPart, 'uniword/comments_part'
autoload :Bookmark, 'uniword/bookmark'

# === Tables ===
autoload :TableBorder, 'uniword/table_border'
autoload :TableCell, 'uniword/table_cell'
autoload :TableColumn, 'uniword/table_column'
autoload :ParagraphBorder, 'uniword/paragraph_border'

# === Other Elements ===
autoload :ExtensionList, 'uniword/extension_list'
autoload :Extension, 'uniword/extension'
autoload :ExtraColorSchemeList, 'uniword/extra_color_scheme_list'
autoload :FormatScheme, 'uniword/format_scheme'
autoload :ObjectDefaults, 'uniword/object_defaults'

# === Namespace-specific ===
autoload :Office, 'uniword/office'
autoload :VmlOffice, 'uniword/vml_office'
autoload :Spreadsheetml, 'uniword/spreadsheetml'
autoload :Wordprocessingml2013, 'uniword/wordprocessingml_2013'
autoload :Wordprocessingml2016, 'uniword/wordprocessingml_2016'
```

**PRO TIP**: Verify all files exist before adding autoload:

```bash
# Check which files exist
for class in Builder ElementRegistry LazyLoader StreamingParser FormatConverter Logger Chart Field Footer Footnote Endnote Header Picture Revision Section TextBox TextFrame TrackedChanges ColumnConfiguration DocumentVariables LineNumbering PageBorders SectionProperties Shading TabStop NumberingDefinition NumberingInstance NumberingLevel Comment CommentRange CommentsPart Bookmark TableBorder TableCell TableColumn ParagraphBorder ExtensionList Extension ExtraColorSchemeList FormatScheme ObjectDefaults Office VmlOffice Spreadsheetml Wordprocessingml2013 Wordprocessingml2016; do
  file=$(echo "$class" | ruby -e 'puts ARGF.read.gsub(/([A-Z])/) { |m| "_#{m.downcase}" }.sub(/^_/, "")')
  if [ -f "lib/uniword/$file.rb" ]; then
    echo "✅ $class -> $file.rb"
  else
    echo "❌ MISSING: $class -> $file.rb"
  fi
done
```

**Add autoload ONLY for files that exist**. Skip files that don't exist.

#### Step 4: Verify Critical require_relative Preserved (5 min)

**DO NOT CHANGE these lines**:

```ruby
# Line 13
require_relative 'uniword/version'  # ✅ KEEP

# Line 16
require_relative 'uniword/ooxml/namespaces'  # ✅ KEEP

# Lines 161-162 (format handlers)
require_relative 'uniword/formats/docx_handler'  # ✅ KEEP
require_relative 'uniword/formats/mhtml_handler'  # ✅ KEEP
```

**CHECKPOINT 2**: Main file updated, test it ✅

```bash
# Test 1: Module loads
ruby -e "require './lib/uniword'; puts 'Module loads OK'"

# Test 2: Document class works
ruby -e "require './lib/uniword'; puts Uniword::Document"

# Test 3: Files loaded count
ruby -e "require './lib/uniword'; puts $LOADED_FEATURES.grep(/uniword/).size"
# Target: <30 files

# Test 4: Run full test suite
bundle exec rspec
# Target: All tests pass
```

**If tests fail**:
1. Check error messages carefully
2. Verify all autoload paths are correct
3. Restore backup if needed: `cp lib/uniword.rb.backup lib/uniword.rb`
4. Fix issues incrementally

**CHECKPOINT 3**: Session 1 Complete ✅

```bash
# Final validation
bundle exec rspec --format documentation | tee session1_test_results.txt
git add .
git commit -m "feat(autoload): Session 1 - Create namespace loaders and update main file"
```

---

## SESSION 2: Specialized Namespaces (60 minutes)

**Goal**: Create 5 specialized namespace loaders

### Quick Implementation

Use the same script pattern for each:

```bash
# For each namespace folder
cd lib/uniword/{namespace}
for file in *.rb; do
  base=$(basename "$file" .rb)
  class=$(echo "$base" | ruby -e 'puts ARGF.read.split("_").map(&:capitalize).join')
  echo "    autoload :$class, 'uniword/{namespace}/$base'"
done
```

### Files to Create

1. **lib/uniword/accessibility.rb** (10 min)
   - Main module + Rules submodule
   - 5 main classes + 10 rule classes

2. **lib/uniword/assembly.rb** (5 min)
   - 6 assembly classes

3. **lib/uniword/batch.rb** (10 min)
   - Main module + Stages submodule
   - 3 main classes + 6 stage classes

4. **lib/uniword/bibliography.rb** (10 min)
   - 30+ bibliography classes

5. **lib/uniword/customxml.rb** (10 min)
   - 16+ custom XML classes

**Templates in**: `docs/AUTOLOAD_CONTINUATION_PLAN.md` (Session 2 section)

### Update Main File

Add to `lib/uniword.rb` after existing namespace autoloads:

```ruby
# Autoload specialized namespaces
autoload :Accessibility, 'uniword/accessibility'
autoload :Assembly, 'uniword/assembly'
autoload :Batch, 'uniword/batch'
autoload :Bibliography, 'uniword/bibliography'
autoload :CustomXml, 'uniword/customxml'
```

**Test**:
```bash
bundle exec rspec
ruby -e "require './lib/uniword'; Uniword::Accessibility::AccessibilityChecker"
```

**Commit**:
```bash
git add .
git commit -m "feat(autoload): Session 2 - Add specialized namespace loaders"
```

---

## SESSION 3: Documentation & Testing (60 minutes)

### Task 3A: Create Autoload Test (20 min)

**File**: `spec/uniword/autoload_spec.rb`

**Template in**: `docs/AUTOLOAD_CONTINUATION_PLAN.md` (Session 3, Task 3A)

**Test**:
```bash
bundle exec rspec spec/uniword/autoload_spec.rb
```

### Task 3B: Performance Benchmark (20 min)

**File**: `benchmark/autoload_performance.rb`

**Template in**: `docs/AUTOLOAD_CONTINUATION_PLAN.md` (Session 3, Task 3B)

**Run**:
```bash
ruby benchmark/autoload_performance.rb
```

**Expected**:
- Load time: <100ms ✅
- Files loaded: <30 ✅
- Memory: <20MB ✅

### Task 3C: Update README.adoc (20 min)

**Add section**: Architecture → Lazy Loading with Autoload

**Template in**: `docs/AUTOLOAD_CONTINUATION_PLAN.md` (Session 3, Task 3C)

**Commit**:
```bash
git add .
git commit -m "docs(autoload): Session 3 - Add tests, benchmarks, and documentation"
```

---

## SESSION 4: Final Validation (30 minutes)

### Full Test Suite

```bash
bundle exec rspec --format documentation
# Expected: 2100+ examples, 0 failures
```

### Performance Validation

```bash
ruby benchmark/autoload_performance.rb
# All metrics must pass
```

### Rubocop Validation

```bash
bundle exec rubocop lib/uniword.rb \
  lib/uniword/shared_types.rb \
  lib/uniword/content_types.rb \
  lib/uniword/document_properties.rb \
  lib/uniword/accessibility.rb \
  lib/uniword/assembly.rb \
  lib/uniword/batch.rb \
  lib/uniword/bibliography.rb \
  lib/uniword/customxml.rb
# Expected: 0 offenses
```

### Final Commit

```bash
git add .
git commit -m "feat(autoload): Session 4 - Final validation complete

- All 14 namespace loaders using autoload
- 95% autoload coverage achieved
- Load time: <100ms (5x improvement)
- Memory: <20MB (4x reduction)
- Files loaded: <30 (95% reduction)
- All 2100+ tests passing
- Zero breaking changes
- Rubocop compliant"
```

---

## Success Checklist

### Session 1 (Foundation)
- [ ] `lib/uniword/shared_types.rb` created
- [ ] `lib/uniword/content_types.rb` created
- [ ] `lib/uniword/document_properties.rb` created
- [ ] `lib/uniword.rb` lines 19-27 converted to autoload
- [ ] 50+ top-level classes autoloaded in main file
- [ ] All tests passing
- [ ] Files loaded <30

### Session 2 (Specialized)
- [ ] 5 specialized namespace loaders created
- [ ] Main file updated with 5 new autoloads
- [ ] All namespaces accessible
- [ ] All tests passing

### Session 3 (Documentation)
- [ ] Autoload test created and passing
- [ ] Performance benchmark created and passing
- [ ] README.adoc updated
- [ ] All documentation complete

### Session 4 (Validation)
- [ ] Full test suite passing (2100+ examples)
- [ ] Performance targets met (<100ms, <30 files, <20MB)
- [ ] Rubocop compliant (0 offenses)
- [ ] Final commit complete

---

## Critical Reminders

### ✅ DO
- Test after each major change
- Commit after each session
- Verify all files exist before adding autoload
- Keep critical require_relative (version, namespaces, handlers)
- Follow MECE principles (each class ONE autoload, ONE location)

### ❌ DON'T
- Change version.rb require_relative
- Change namespaces.rb require_relative
- Change format handler require_relative
- Remove any working autoload
- Skip testing steps

---

## Quick Commands Reference

```bash
# Generate autoload statements
cd lib/uniword/{namespace}
for file in *.rb; do
  base=$(basename "$file" .rb)
  class=$(echo "$base" | ruby -e 'puts ARGF.read.split("_").map(&:capitalize).join')
  echo "autoload :$class, File.expand_path('{namespace}/$base', __dir__)"
done

# Test module loading
ruby -e "require './lib/uniword'; puts 'OK'"

# Count files loaded
ruby -e "require './lib/uniword'; puts $LOADED_FEATURES.grep(/uniword/).size"

# Run tests
bundle exec rspec

# Run specific test
bundle exec rspec spec/uniword/autoload_spec.rb

# Run benchmark
ruby benchmark/autoload_performance.rb

# Run rubocop
bundle exec rubocop lib/uniword.rb

# Check if file exists
ls -la lib/uniword/builder.rb
```

---

## Rollback Procedure

If critical issues arise:

```bash
# Restore backup
cp lib/uniword.rb.backup lib/uniword.rb

# Or git revert
git revert HEAD

# Keep new namespace loader files (they're correct)
# Just revert main file changes if needed
```

---

## Support Resources

- **Detailed Plan**: `docs/AUTOLOAD_IMPLEMENTATION_PLAN.md` (900 lines)
- **Quick Reference**: `docs/AUTOLOAD_QUICK_REFERENCE.md` (283 lines)
- **Migration Summary**: `docs/AUTOLOAD_MIGRATION_SUMMARY.md` (432 lines)
- **Continuation Plan**: `docs/AUTOLOAD_CONTINUATION_PLAN.md` (596 lines)
- **Implementation Status**: `docs/AUTOLOAD_IMPLEMENTATION_STATUS.md` (467 lines)

---

## Final Notes

**Timeline**: 4 hours compressed implementation  
**Risk**: LOW (incremental changes, easy rollback)  
**Impact**: HIGH (5x startup, 4x memory, 95% reduction)  
**Breaking Changes**: ZERO  

**START NOW**: Session 1, Task 1A - Create `lib/uniword/shared_types.rb`

Good luck! 🚀

---

**Document Version**: 1.0  
**Status**: Ready for Implementation  
**Priority**: HIGH - Performance Critical
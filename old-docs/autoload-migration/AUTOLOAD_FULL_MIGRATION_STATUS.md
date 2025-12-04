# Uniword: Full Autoload Migration - Implementation Status

**Goal**: 100% autoload coverage for maintenance simplification
**Strategy**: Revised - maintenance priority over performance
**Timeline**: 3 sessions, ~4 hours
**Current Phase**: Session 2 (Ready to Start)

---

## Overall Progress

| Component | Status | Progress | Notes |
|-----------|--------|----------|-------|
| Session 1: Foundation | ✅ Complete | 100% | 3 namespaces autoloaded |
| Session 2: Main File | 🔄 Ready | 0% | Convert require_relative → autoload |
| Session 3: Specialized Namespaces | ⏳ Pending | 0% | Create 3 missing loaders |
| Session 4: Testing & Docs | ⏳ Pending | 0% | Validate & document |

---

## Session 1: Foundation ✅ COMPLETE

### Accomplished
- ✅ Analyzed dependency structure
- ✅ Converted 3 namespaces to autoload (ContentTypes, DocumentProperties, Glossary)
- ✅ All 84 tests passing
- ✅ Documented architectural constraints
- ✅ Committed changes (211b9d6, 42a1146)

### Files Modified
- `lib/uniword.rb` - Partial autoload conversion

### Key Learning
- Cross-dependencies cause cascade loading
- Constant assignments at module load time prevent full autoload
- Solution: Convert constants to class methods

---

## Session 2: Complete Main File Autoload 🔄 READY

**Estimated Time**: 2 hours
**Priority**: HIGH - Core infrastructure change

### Task 2.1: Remove Namespace require_relative ⏳

**Files to Modify**: `lib/uniword.rb` lines 18-30

**Current State**:
```ruby
require_relative 'uniword/wordprocessingml'  # line 19
require_relative 'uniword/wp_drawing'        # line 20
require_relative 'uniword/drawingml'         # line 21
require_relative 'uniword/vml'               # line 22
require_relative 'uniword/math'              # line 23
require_relative 'uniword/shared_types'      # line 24
```

**Target State**:
```ruby
autoload :Wordprocessingml, 'uniword/wordprocessingml'
autoload :WpDrawing, 'uniword/wp_drawing'
autoload :DrawingML, 'uniword/drawingml'
autoload :Vml, 'uniword/vml'
autoload :Math, 'uniword/math'
autoload :SharedTypes, 'uniword/shared_types'
```

**Blockers**: Lines 59-79 constant assignments
**Solution**: See Task 2.4

- [ ] Convert 6 require_relative to autoload
- [ ] Test basic loading
- [ ] Verify no immediate errors

### Task 2.2: Add Missing Top-Level Autoloads ⏳

**Files to Modify**: `lib/uniword.rb` (add ~50 autoload statements)

**Target Location**: After existing autoloads (around line 120)

**Classes to Add** (partial list):
```ruby
# Infrastructure
autoload :Builder, 'uniword/builder'
autoload :ElementRegistry, 'uniword/element_registry'
autoload :LazyLoader, 'uniword/lazy_loader'
autoload :StreamingParser, 'uniword/streaming_parser'
autoload :FormatConverter, 'uniword/format_converter'
autoload :Logger, 'uniword/logger'

# Document Structure
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

# Configuration
autoload :ColumnConfiguration, 'uniword/column_configuration'
autoload :DocumentVariables, 'uniword/document_variables'
autoload :LineNumbering, 'uniword/line_numbering'
autoload :PageBorders, 'uniword/page_borders'
autoload :SectionProperties, 'uniword/section_properties'
autoload :Shading, 'uniword/shading'
autoload :TabStop, 'uniword/tab_stop'

# Numbering
autoload :NumberingDefinition, 'uniword/numbering_definition'
autoload :NumberingInstance, 'uniword/numbering_instance'
autoload :NumberingLevel, 'uniword/numbering_level'

# Comments & Ranges
autoload :Comment, 'uniword/comment'
autoload :CommentRange, 'uniword/comment_range'
autoload :CommentsPart, 'uniword/comments_part'
autoload :Bookmark, 'uniword/bookmark'

# Tables
autoload :TableBorder, 'uniword/table_border'
autoload :TableCell, 'uniword/table_cell'
autoload :TableColumn, 'uniword/table_column'
autoload :ParagraphBorder, 'uniword/paragraph_border'

# Other
autoload :ExtensionList, 'uniword/extension_list'
autoload :Extension, 'uniword/extension'
autoload :ExtraColorSchemeList, 'uniword/extra_color_scheme_list'
autoload :FormatScheme, 'uniword/format_scheme'
autoload :ObjectDefaults, 'uniword/object_defaults'
```

**Method**: Scan lib/uniword/*.rb, extract class names, generate autoload statements

- [ ] Generate autoload statements for all top-level classes
- [ ] Add to lib/uniword.rb
- [ ] Verify file paths are correct
- [ ] Test loading

### Task 2.3: Handle Format Handler Registration ⏳

**Files to Keep**: Lines 161-162 in `lib/uniword.rb`

**Current State**:
```ruby
require_relative 'uniword/formats/docx_handler'
require_relative 'uniword/formats/mhtml_handler'
```

**Action**: Keep as-is (self-registration pattern requires eager loading)

**Documentation**: Add comment explaining why these remain require_relative

- [ ] Add explanatory comment
- [ ] Verify handlers still self-register
- [ ] Test format handling works

### Task 2.4: Convert Constant Assignments to Methods ⏳

**Files to Modify**: `lib/uniword.rb` lines 59-79

**Current State** (constants):
```ruby
Document = Wordprocessingml::DocumentRoot
Body = Wordprocessingml::Body
Paragraph = Wordprocessingml::Paragraph
Run = Wordprocessingml::Run
Table = Wordprocessingml::Table
# ... etc
```

**Target State** (methods):
```ruby
class << self
  def Document
    Wordprocessingml::DocumentRoot
  end
  
  def Body
    Wordprocessingml::Body
  end
  
  def Paragraph
    Wordprocessingml::Paragraph
  end
  
  def Run
    Wordprocessingml::Run
  end
  
  def Table
    Wordprocessingml::Table
  end
  
  # ... etc for all 15+ constants
end
```

**API Compatibility**: `Uniword::Document.new` still works (method → class)

- [ ] Convert all constant assignments to class methods
- [ ] Test API compatibility
- [ ] Verify `Uniword::Document.new` works
- [ ] Verify `Uniword.Document` works

**Estimated Progress**: 0% → 70% after Session 2

---

## Session 3: Specialized Namespace Loaders ⏳ PENDING

**Estimated Time**: 1.5 hours
**Priority**: MEDIUM - New feature support

### Missing Loaders to Create

| File | Classes | Estimated Time |
|------|---------|----------------|
| `lib/uniword/accessibility.rb` | 5 main + 10 rules | 15 min |
| `lib/uniword/assembly.rb` | 6 classes | 10 min |
| `lib/uniword/batch.rb` | 3 main + 6 stages | 15 min |

**Already Exist**:
- ✅ `lib/uniword/bibliography.rb` (30 classes)
- ✅ `lib/uniword/customxml.rb` (29 classes)

### Task 3.1: Create accessibility.rb ⏳

- [ ] Create file with module structure
- [ ] Add 5 main class autoloads
- [ ] Add Rules submodule with 10 autoloads
- [ ] Test loading

### Task 3.2: Create assembly.rb ⏳

- [ ] Create file with module structure
- [ ] Add 6 class autoloads
- [ ] Test loading

### Task 3.3: Create batch.rb ⏳

- [ ] Create file with module structure
- [ ] Add 3 main class autoloads
- [ ] Add Stages submodule with 6 autoloads
- [ ] Test loading

### Task 3.4: Register in Main File ⏳

**Files to Modify**: `lib/uniword.rb`

**Add**:
```ruby
autoload :Accessibility, 'uniword/accessibility'
autoload :Assembly, 'uniword/assembly'
autoload :Batch, 'uniword/batch'
```

- [ ] Add 3 autoload statements
- [ ] Test namespace access

**Estimated Progress**: 70% → 95% after Session 3

---

## Session 4: Testing & Documentation ⏳ PENDING

**Estimated Time**: 30 minutes
**Priority**: HIGH - Quality assurance

### Task 4.1: Run Full Test Suite ⏳

**Command**: `bundle exec rspec`

**Expected**: All tests pass

- [ ] Run styleset tests (84 examples)
- [ ] Run theme tests (if any)
- [ ] Run unit tests
- [ ] Document any failures

### Task 4.2: Verify Autoload Coverage ⏳

**Metrics to Collect**:
```bash
# Count autoload statements
grep -r "autoload" lib/uniword/**/*.rb | wc -l

# Count require_relative (should be ~3)
grep -r "require_relative" lib/uniword.rb | wc -l
```

**Expected**:
- Autoload count: ~500+
- require_relative count: ~3 (version, namespaces, format handlers)

- [ ] Count autoloads
- [ ] Verify minimal require_relative
- [ ] Document coverage percentage

### Task 4.3: Update README.adoc ⏳

**Section to Add**: Architecture → Autoload-Based Loading

**Content**:
```asciidoc
== Architecture: Autoload-Based Loading

Uniword uses Ruby's `autoload` feature throughout for clean dependency management:

* **Declarative structure**: All available classes visible in loader files
* **Reduced maintenance**: No manual dependency tracking needed
* **Self-documenting**: Loader files serve as module indexes
* **Lazy loading**: Classes load only when accessed

All namespace modules use autoload exclusively, making the codebase structure transparent and easy to navigate.
```

- [ ] Add architecture section to README.adoc
- [ ] Document autoload pattern
- [ ] Add examples

### Task 4.4: Archive Old Documentation ⏳

**Files to Move to old-docs/**:
- `AUTOLOAD_MIGRATION_COMPLETE.md` (outdated - Session 1 only analysis)
- `AUTOLOAD_CONTINUATION_PLAN.md` (interim plan)
- `AUTOLOAD_CONTINUATION_PROMPT.md` (interim prompt)

- [ ] Move 3 files to old-docs/
- [ ] Update references if needed

**Estimated Progress**: 95% → 100% after Session 4

---

## Critical Decision Points

### Constant vs Method API

**Decision Required**: How to handle constant assignments?

**Option 1: Pure Methods** (Recommended)
```ruby
class << self
  def Document
    Wordprocessingml::DocumentRoot
  end
end
```

**Pros**: Clean, enables full autoload
**Cons**: `Uniword::Document` constant reference won't work initially

**Option 2: Lazy Constant Definition**
```ruby
def self.Document
  @document_class ||= begin
    klass = Wordprocessingml::DocumentRoot
    const_set(:Document, klass) unless const_defined?(:Document, false)
    klass
  end
end
```

**Pros**: Maintains constant compatibility
**Cons**: More complex, const_set at runtime

**Recommendation**: Option 1 (methods) - simpler and still API compatible

### Format Handler Registration

**Decision**: Keep require_relative for format handlers

**Rationale**: Self-registration pattern needs side effects
**Impact**: 2 files remain eagerly loaded (acceptable)

---

## Success Metrics

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| Autoload Coverage | 95%+ | 33% | 🔄 In Progress |
| require_relative Count | ≤3 | ~9 | 🔄 In Progress |
| Tests Passing | 100% | 100% | ✅ Passing |
| API Compatibility | 100% | 100% | ✅ Compatible |
| Files Loaded on Require | <50 | 254 | ⏳ Pending |

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| API breaking changes | Low | High | Use methods instead of constants |
| Test failures | Low | Medium | Incremental testing after each task |
| Performance regression | Very Low | Low | Accept trade-off for maintenance |
| Constant reference issues | Medium | Medium | Document method-based access |

---

## Rollback Strategy

1. **Git Revert**: All changes are in feature branch
2. **Backup Files**: .backup files created before changes
3. **Incremental Commits**: Each session committed separately
4. **Test Validation**: Tests run after each session

**Recovery Time**: <5 minutes (git checkout or revert)

---

## Timeline

| Session | Duration | Status | Start | Complete |
|---------|----------|--------|-------|----------|
| Session 1 | 90 min | ✅ Done | Dec 3 | Dec 3 |
| Session 2 | 2 hours | 🔄 Ready | - | - |
| Session 3 | 1.5 hours | ⏳ Pending | - | - |
| Session 4 | 30 min | ⏳ Pending | - | - |

**Total Estimated**: 4 hours (compressed from 6.5 hours)

---

**Document Version**: 1.0
**Last Updated**: December 4, 2024
**Status**: Ready for Session 2 Implementation
# Uniword: Week 3 Autoload Migration - Final Cleanup & Architecture Polish

**Status**: Week 2 COMPLETE (All 5 formats migrated)  
**Remaining**: 163 files with require_relative + architecture cleanup  
**Goal**: Complete autoload migration, delete obsolete code, finalize architecture

---

## Current State Summary

### Week 1 Achievements ✅
- **675 namespace autoloads** created (450% of goal)
- 13 namespace modules converted
- Pattern established: `File.expand_path → 'uniword/path'`

### Week 2 Achievements ✅
- **All 5 format packages migrated**
- DocxPackage, DotxPackage, ThmxPackage, MhtmlPackage created
- Model-driven architecture achieved
- Zero orchestrator layers in Package classes

### Week 3 Remaining
- **163 files still use require_relative**
- Old format handlers still exist in `lib/uniword/formats/`
- Element files (wordprocessingml/*.rb) need autoload
- Feature directories need cleanup
- Final lib/uniword.rb optimization

---

## Critical Architectural Tasks

### 1. DELETE lib/uniword/formats/ Directory

**Files to delete** (obsolete orchestrators):
- `lib/uniword/formats/mhtml_handler.rb` - Replaced by MhtmlPackage
- `lib/uniword/formats/format_handler_registry.rb` - Replaced by FormatDetector
- `lib/uniword/formats/base_handler.rb` - No longer needed
- Any other files in formats/

**Rationale**: These are orchestrator anti-patterns. Package classes replaced them.

### 2. Convert Element Files to Autoload

**Wordprocessingml elements** (~11 files with require_relative):
- table.rb, paragraph.rb, run.rb
- level.rb, table_cell_properties.rb
- r_pr_default.rb, p_pr_default.rb
- document_root.rb, style.rb
- structured_document_tag.rb

**Pattern**: Replace `require_relative` with module autoload declarations

### 3. Property Files Cleanup

**Files**:
- styles_configuration.rb
- structured_document_tag_properties.rb
- section_properties.rb

**Pattern**: Use autoload for property class loading

### 4. Feature Directory Conversion

**Directories to convert**:
- quality/ (6 files)
- transformation/ (4 files)
- assembly/ (3 files)
- stylesets/ (2 files)
- configuration/ (1 file)
- mhtml/ (1 file)

---

## Week 3 Compressed Timeline (12-15 hours)

### Phase 1: Delete Obsolete Code (2-3 hours)

**Session 1**: Remove formats/ directory (1.5 hours)
- Delete lib/uniword/formats/*.rb (all files)
- Remove formats/ directory
- Update any remaining references
- Test baseline (258 examples)

**Session 2**: Archive old handlers and utilities (1-1.5 hours)
- Move old serialization code to old-docs/
- Clean up lib/uniword.rb (remove dead requires)
- Document deletions

---

### Phase 2: Element File Conversion (3-4 hours)

**Session 3**: Wordprocessingml elements (2 hours)
- Convert 11 element files to use autoload
- Pattern: Create Wordprocessingml::Elements module
- Test after conversion

**Session 4**: Property files (1-2 hours)
- Convert styles_configuration.rb
- Convert structured_document_tag_properties.rb
- Convert section_properties.rb
- Test baseline

---

### Phase 3: Feature Directory Conversion (4-5 hours)

**Session 5**: Quality & Transformation (2-2.5 hours)
- Convert quality/ directory (6 files)
- Convert transformation/ directory (4 files)
- Create module autoload indexes

**Session 6**: Assembly & Configuration (1.5-2 hours)
- Convert assembly/ directory (3 files)
- Convert stylesets/ directory (2 files)
- Convert configuration/ (1 file)
- Convert mhtml/ (1 file)

**Session 7**: Remaining files (0.5-1 hour)
- Convert any remaining require_relative files
- Document legitimate circular dependencies

---

### Phase 4: Final Optimization & Documentation (3-4 hours)

**Session 8**: lib/uniword.rb optimization (1.5 hours)
- Review all require_relative statements
- Convert to autoload where possible
- Document remaining requires
- Test full suite

**Session 9**: Documentation update (1.5-2 hours)
- Update README.adoc with new architecture
- Document Package API
- Create migration guide
- Archive temporary docs to old-docs/

**Session 10**: Final validation (0.5-1 hour)
- Run full test suite
- Verify < 20 require_relative remaining
- Create final status report
- Celebrate completion! 🎉

---

## Success Metrics

### Autoload Migration
- **Start**: 163 files with require_relative
- **Target**: < 20 files (only legitimate circular dependencies)
- **Reduction**: ~143 files (88% reduction)
- **Total reduction**: From 416 → < 20 (95% total reduction)

### Architecture Quality
- ✅ Zero orchestrator layers
- ✅ All formats use Package classes
- ✅ lib/uniword/formats/ directory deleted
- ✅ Model-driven architecture throughout
- ✅ MECE separation maintained

### Code Quality
- **Files deleted**: ~10-15 (obsolete handlers, utilities)
- **Lines removed**: ~800-1000 (redundant code)
- **Directories deleted**: 1 (lib/uniword/formats/)
- **Maintainability**: Significantly improved

### Tests
- **Baseline**: 258 examples maintained
- **Target**: Zero new failures
- **Stretch**: Fix existing failures (177 theme tests)

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Breaking tests | Low | Medium | Test after each phase |
| Circular dependencies | Medium | Low | Document; keep require_relative where needed |
| Missing references | Low | Medium | Comprehensive search before deletion |
| Performance regression | Very Low | Low | Autoload improves performance |

---

## Key Principles (CRITICAL)

1. **Delete Fearlessly**: Obsolete code must go
2. **Test Continuously**: After every change
3. **Document Decisions**: Why keeping require_relative
4. **MECE Always**: Each file one responsibility
5. **Model-Driven**: No orchestrators, no serializers
6. **Autoload-First**: Only require_relative for circular deps

---

## Conversion Patterns

### Pattern 1: Element Files

**Before** (table.rb):
```ruby
require_relative '../properties/table_properties'
require_relative 'table_row'
```

**After**:
```ruby
# In wordprocessingml.rb module
module Wordprocessingml
  autoload :TableProperties, 'uniword/properties/table_properties'
  autoload :TableRow, 'uniword/wordprocessingml/table_row'
end
```

### Pattern 2: Feature Directories

**Before** (quality/document_checker.rb):
```ruby
require_relative 'rules/heading_hierarchy_rule'
require_relative 'rules/link_validation_rule'
```

**After** (quality.rb):
```ruby
module Uniword
  module Quality
    autoload :DocumentChecker, 'uniword/quality/document_checker'
    autoload :HeadingHierarchyRule, 'uniword/quality/rules/heading_hierarchy_rule'
    autoload :LinkValidationRule, 'uniword/quality/rules/link_validation_rule'
  end
end
```

### Pattern 3: Property Files

**Before** (styles_configuration.rb):
```ruby
require_relative 'style'
require_relative 'properties/paragraph_properties'
```

**After** (in uniword.rb):
```ruby
autoload :StylesConfiguration, 'uniword/styles_configuration'
# Properties already autoloaded in main module
```

---

## Timeline Estimate

**Compressed Schedule** (deadline-driven):

- **Week 3 Day 1**: Phase 1 (Delete obsolete) - 2-3 hours
- **Week 3 Day 2**: Phase 2 (Element conversion) - 3-4 hours
- **Week 3 Day 3**: Phase 3 (Feature directories) - 4-5 hours
- **Week 3 Day 4**: Phase 4 (Final polish) - 3-4 hours

**Total**: 12-16 hours (2-3 working days compressed)

**Target Completion**: End of Week 3

---

## Expected Final State

### File Statistics
- **require_relative count**: < 20 (from 416 originally)
- **Autoload count**: ~850+ total
- **Deleted files**: 10-15
- **Deleted directories**: 1

### Architecture
- **Package classes**: 5 (DocxPackage, DotxPackage, ThmxPackage, MhtmlPackage, + base)
- **Orchestrator layers**: 0
- **Format handlers**: 0 (deleted)
- **Model-driven**: 100%

### Documentation
- README.adoc updated
- Migration guide created
- API documentation current
- Temporary docs archived

---

**Created**: December 8, 2024  
**Status**: Ready to execute  
**Next**: Phase 1 Session 1 - Delete lib/uniword/formats/ directory
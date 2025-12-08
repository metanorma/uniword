# Uniword: Week 2+ Continuation Plan - Architecture & Autoload Completion

**Status**: Week 1 COMPLETE (675 namespace autoloads - 450% of goal!)
**Remaining**: 161 files with require_relative + architectural improvements
**Goal**: Complete autoload migration + fix architectural violations

---

## Critical Architectural Issue Discovered

### Problem: DocxHandler Violates Model-Driven Architecture

**Current (WRONG)**:
```ruby
# lib/uniword/formats/docx_handler.rb - Orchestrator layer
class DocxHandler
  def read(path)
    content = ZipExtractor.extract(path)
    package = DocxPackage.from_zip_content(content)
    # ...
  end
end

# lib/uniword/ooxml/docx_package.rb - Just a model
class DocxPackage
  def self.from_zip_content(content)
    # Parse XML parts
  end
end
```

**This violates**:
- Model-driven architecture (model should handle its own persistence)
- Single Responsibility (DocxHandler is redundant orchestration)
- MECE (overlapping responsibilities)

**Correct (Model-Driven)**:
```ruby
# lib/uniword/ooxml/docx_package.rb - Model handles its own I/O
class DocxPackage < Lutaml::Model::Serializable
  def self.from_file(path)
    content = Infrastructure::ZipExtractor.new.extract(path)
    from_zip_content(content)
  end

  def to_file(path)
    content = to_zip_content
    Infrastructure::ZipPackager.new.package(content, path)
  end
end
```

**Benefits**:
- Model owns its serialization (proper OOP)
- No orchestrator layer needed
- Simpler, clearer architecture
- Follows lutaml-model pattern

### Similar Issues

1. **MhtmlHandler** → Should be merged into **MhtmlPackage** (to be created)
2. **BaseHandler** → Delete (no longer needed)
3. **FormatHandlerRegistry** → Simplify to FormatDetector (or delete entirely)

**GOAL**: Delete entire `lib/uniword/formats/` directory (4 files, ~400 lines)

---

## Week 2: Architecture Refactoring (Compressed Timeline)

### Phase 1: Merge Format Handlers into Package Classes (6-8 hours)

**Goal**: Eliminate orchestrator anti-pattern, move I/O into models, **DELETE lib/uniword/formats/ directory**

**Day 1 - Session 1**: Merge DocxHandler into DocxPackage (3 hours)
- Move all DOCX I/O logic into DocxPackage
- Update DocumentFactory to use DocxPackage.from_file directly
- Delete lib/uniword/formats/docx_handler.rb (1 of 4 files)
- Update tests (maintain 258/32 baseline)

**Day 1 - Session 2**: Create MhtmlPackage and merge MhtmlHandler (2 hours)
- Create lib/uniword/ooxml/mhtml_package.rb
- Move MHTML logic from MhtmlHandler
- Delete lib/uniword/formats/mhtml_handler.rb (2 of 4 files)
- Update tests

**Day 1 - Session 3**: Clean up format infrastructure (1-2 hours)
- Delete lib/uniword/formats/base_handler.rb (3 of 4 files)
- Delete or simplify lib/uniword/formats/format_handler_registry.rb (4 of 4 files)
- **Delete lib/uniword/formats/ directory entirely**
- Update DocumentFactory to use package classes directly
- Update lib/uniword.rb to remove Formats module and all format requires
- Run full test suite

**Expected Reduction**: ~400 lines of redundant code deleted, entire directory removed

---

### Phase 2: Property File Autoload Migration (4-6 hours)

**Current State**: Property files have internal require_relative chains

**Files to migrate** (~50 property files):
- lib/uniword/ooxml/wordprocessingml/*.rb (26 files)
- lib/uniword/properties/*.rb (24 files)

**Pattern**: Each property container file should use autoload, not require_relative

**Day 2 - Session 1**: Migrate WordProcessingML property files (2 hours)
- Convert run_properties.rb (16 require_relative → autoload in module)
- Convert paragraph_properties.rb (10 require_relative → autoload)
- Convert table_properties.rb (4 require_relative)

**Day 2 - Session 2**: Migrate remaining property files (2-4 hours)
- Convert structured_document_tag_properties.rb (13 require_relative)
- Convert all lib/uniword/properties/*.rb wrappers

**Expected Reduction**: ~100 require_relative eliminated

---

### Phase 3: Infrastructure & Feature File Cleanup (6-8 hours)

**Remaining require_relative clusters**:

1. **Wordprocessingml element files** (~15 files):
   - table.rb, paragraph.rb, run.rb, etc.
   - These require properties - should use autoload

2. **Infrastructure files** (~20 files):
   - Most in lib/uniword/infrastructure/
   - lib/uniword/ooxml/
   - Should use autoload where possible

3. **Feature files** (~80 files):
   - stylesets/, validation/, quality/, etc.
   - Convert to autoload pattern

**Day 3 - Session 1**: Wordprocessingml element cleanup (2 hours)
- Update table.rb, paragraph.rb, run.rb, etc.
- Replace require_relative with autoload

**Day 3 - Session 2**: Infrastructure cleanup (2 hours)
- Audit infrastructure files
- Convert to autoload where circular dependencies allow

**Day 3 - Session 3**: Feature file cleanup (4 hours)
- Batch convert feature directories
- Test after each batch

**Expected Reduction**: ~150 require_relative eliminated

---

### Phase 4: Final Cleanup & Validation (2-3 hours)

**Day 4 - Session 1**: Remaining require_relative audit (1 hour)
- Find any remaining require_relative
- Determine if legitimate (circular dependencies) or can be converted

**Day 4 - Session 2**: Test suite validation (1-2 hours)
- Run full test suite (342 tests ideally)
- Verify baseline maintained (258/32 minimum)
- Fix any regressions

**Day 4 - Session 3**: Documentation update (1 hour)
- Update README.adoc with new architecture
- Move temporary docs to old-docs/
- Update CHANGELOG.md

---

## Success Metrics

**Architecture**:
- ✅ Zero orchestrator layers (entire lib/uniword/formats/ directory deleted)
- ✅ Model-driven I/O (packages handle own persistence)
- ✅ MECE (no overlapping responsibilities)
- ✅ Open/Closed (easy to add new formats)

**Autoload Migration**:
- Target: < 20 require_relative remaining (only genuine circular dependencies)
- Current: 161 files with require_relative
- Reduction: ~140 files (87%)

**Tests**:
- Baseline: 258 examples, 32 failures maintained
- Target: 342 examples, 0 failures (stretch goal)

**Code Quality**:
- Deleted directory: lib/uniword/formats/ (4 files)
- Lines removed: ~400-500 (redundant orchestration)
- Maintainability: Significantly improved

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Breaking format I/O | Low | High | Test after each merge, maintain baseline |
| Circular dependencies | Medium | Medium | Keep require_relative where truly needed |
| Test regressions | Low | Medium | Test after each phase |
| Documentation lag | Low | Low | Update docs continuously |

---

## Timeline Estimate

**Compressed Schedule** (deadline-driven):

- **Week 2 Day 1**: Phase 1 (Architecture refactoring) - 6-8 hours
- **Week 2 Day 2**: Phase 2 (Property files) - 4-6 hours
- **Week 2 Day 3**: Phase 3 (Infrastructure + Features) - 6-8 hours
- **Week 2 Day 4**: Phase 4 (Cleanup + Validation) - 2-3 hours

**Total**: 18-25 hours (2.5-3 working days compressed)

**Target Completion**: Week 2 complete

---

## Key Principles (CRITICAL)

1. **Model-Driven**: Models handle their own persistence
2. **No Orchestrators**: Delete unnecessary coordination layers
3. **MECE**: Each class has ONE clear responsibility
4. **Open/Closed**: Easy to extend, hard to break
5. **Autoload-First**: Only use require_relative for circular dependencies
6. **Test-Driven**: Maintain baseline, test after each change

---

**Created**: December 8, 2024
**Status**: Ready to execute
**Next**: Phase 1 Session 1 - Merge DocxHandler into DocxPackage
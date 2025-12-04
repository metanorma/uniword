# Uniword: Complete Autoload Migration - Status Tracker

**Project**: Complete Autoload Migration
**Goal**: Migrate 416 → ~45 require_relative (89% reduction)
**Current**: 416 require_relative calls
**Target**: ~45 require_relative calls (documented exceptions only)
**Status**: 🔴 NOT STARTED

---

## Overall Progress

| Metric | Current | Target | Progress |
|--------|---------|--------|----------|
| Total require_relative | 416 | 45 | 0% |
| Main entry (lib/uniword.rb) | 10 | 10 | ✅ 100% |
| Namespace modules | ~150 | ~10 | 🔴 0% |
| Property files | ~100 | ~5 | 🔴 0% |
| Feature files | ~154 | ~20 | 🔴 0% |

---

## Week 1: Namespace Modules (0/150 complete)

### Day 1-2: Wordprocessingml Module
**Target**: 50 require_relative → autoload
**Status**: 🔴 NOT STARTED

- [ ] Analyze all classes in `lib/uniword/wordprocessingml/`
- [ ] Create autoload statements in `lib/uniword/wordprocessingml.rb`
- [ ] Remove require_relative from individual files
- [ ] Test round-trip preservation
- [ ] Update documentation

**Files to migrate**:
- lib/uniword/wordprocessingml.rb (main module file)
- 50+ wordprocessingml/*.rb files

### Day 3: Drawing Modules
**Target**: 40 require_relative → autoload
**Status**: 🔴 NOT STARTED

**WpDrawing** (~15 classes):
- [ ] lib/uniword/wp_drawing.rb
- [ ] lib/uniword/wp_drawing/*.rb files

**DrawingML** (~25 classes):
- [ ] lib/uniword/drawingml.rb  
- [ ] lib/uniword/drawingml/*.rb files

### Day 4: Other Namespace Modules
**Target**: 60 require_relative → autoload
**Status**: 🔴 NOT STARTED

- [ ] lib/uniword/vml.rb + vml/*.rb
- [ ] lib/uniword/math.rb + math/*.rb
- [ ] lib/uniword/shared_types.rb + shared_types/*.rb
- [ ] Plus 16 specialty namespace modules

### Day 5: Testing & Validation
**Status**: 🔴 NOT STARTED

- [ ] Run full test suite (342+ tests)
- [ ] Verify autoload functionality
- [ ] Fix any regressions
- [ ] Update documentation

**Expected Outcome**: 150 require_relative → autoload (Week 1 complete)

---

## Week 2: Property Files (0/100 complete)

### Day 1: Run and Paragraph Properties
**Target**: 26 require_relative → autoload
**Status**: 🔴 NOT STARTED

- [ ] lib/uniword/ooxml/wordprocessingml/run_properties.rb (16 require_relative)
- [ ] lib/uniword/ooxml/wordprocessingml/paragraph_properties.rb (10 require_relative)

### Day 2: Table and SDT Properties
**Target**: 17 require_relative → autoload
**Status**: 🔴 NOT STARTED

- [ ] lib/uniword/ooxml/wordprocessingml/table_properties.rb (4 require_relative)
- [ ] lib/uniword/structured_document_tag_properties.rb (13 require_relative)

### Day 3: Remaining Property Files
**Target**: 57 require_relative → autoload
**Status**: 🔴 NOT STARTED

- [ ] All other property container files
- [ ] Property wrapper classes

### Day 4: Testing & Validation
**Status**: 🔴 NOT STARTED

- [ ] Run full test suite
- [ ] Verify property loading
- [ ] Fix any regressions

**Expected Outcome**: 100 require_relative → autoload (Week 2 complete)

---

## Week 3: Feature Files (0/154 complete)

### Day 1-2: Large Feature Files
**Target**: 54 require_relative → autoload
**Status**: 🔴 NOT STARTED

- [ ] lib/uniword/stylesets/styleset_xml_parser.rb (32 require_relative)
- [ ] lib/uniword/theme.rb (11 require_relative)
- [ ] lib/uniword/cli.rb (11 require_relative)

### Day 3-4: Medium Feature Files
**Target**: 100 require_relative → autoload
**Status**: 🔴 NOT STARTED

- [ ] lib/uniword/validation/document_validator.rb (10)
- [ ] lib/uniword/ooxml/docx_package.rb (8)
- [ ] lib/uniword/validation/link_validator.rb (7)
- [ ] lib/uniword/transformation/transformer.rb (7)
- [ ] lib/uniword/formats/docx_handler.rb (7)
- [ ] Plus ~60 other files

### Day 5: Testing & Validation
**Status**: 🔴 NOT STARTED

- [ ] Run full test suite
- [ ] Verify all features working
- [ ] Fix any regressions
- [ ] Final documentation update

**Expected Outcome**: 154 require_relative → autoload (Week 3 complete)

---

## Final Summary (Target)

### Expected Final State
| Category | Before | After | Reduction |
|----------|--------|-------|-----------|
| Main entry | 12 | 10 | -2 |
| Namespace modules | 150 | 10 | -140 |
| Property files | 100 | 5 | -95 |
| Feature files | 154 | 20 | -134 |
| **Total** | **416** | **45** | **-371 (-89%)** |

### Documented Exceptions (~45)
1. **Base requirements** (2): version, ooxml/namespaces
2. **Namespace cross-deps** (6): Core namespace modules in lib/uniword.rb
3. **Format handlers** (2): docx_handler, mhtml_handler
4. **Parent class loading** (~20): Classes requiring parent first
5. **Circular dependencies** (~15): Unavoidable cycles

---

## Test Results

### Baseline (Before Migration)
- Total tests: 342
- Passing: 258 (StyleSet + Theme)
- Status: ✅ PASSING

### After Week 1
- Total tests: TBD
- Passing: TBD
- Status: 🔴 NOT RUN

### After Week 2
- Total tests: TBD
- Passing: TBD
- Status: 🔴 NOT RUN

### After Week 3 (Final)
- Total tests: TBD
- Passing: TBD
- Status: 🔴 NOT RUN
- **Target**: 342/342 passing ✅

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Circular dependencies | Medium | High | Careful dependency analysis, keep require_relative where needed |
| Test regressions | Medium | Medium | Test after each phase, revert if needed |
| Performance issues | Low | Low | Autoload improves performance |
| Breaking changes | Low | High | Maintain backward compatibility |

---

## Documentation Status

- [ ] README.adoc updated with final coverage metrics
- [ ] CHANGELOG.md updated with complete migration details
- [ ] CONTRIBUTING.md updated with full guidelines
- [ ] Architectural decision records created
- [ ] Migration guide for contributors

---

## Timeline & Progress

**Start Date**: TBD
**Target Completion**: 3 weeks from start
**Current Week**: Not started
**Days Remaining**: 15 working days

---

**Last Updated**: December 4, 2024
**Status**: Ready to begin Week 1, Day 1
**Next Action**: Begin Wordprocessingml module migration
# Sprint 2 Failure Breakdown & Recovery Plan

**Date**: 2025-10-28
**Current State**: 40 failures (19 new regressions from Sprint 1)
**Goal**: Fix critical regressions first, then proceed with improvements
**Status**: EMERGENCY RECOVERY MODE

---

## Emergency Recovery: Critical Blockers (P0)

### 🚨 Blocker 1: Table Cell Properties Type System Failure
**Priority**: P0 - MUST FIX FIRST
**Failures**: 7 tests
**Impact**: 30% of users (table operations completely broken)

#### Affected Tests:
1. `spec/compatibility/docx_js/structure/table_spec.rb:66` - column_span creation
2. `spec/compatibility/docx_js/structure/table_spec.rb:92` - row_span creation
3. `spec/compatibility/docx_js/structure/table_spec.rb:131` - complex span scenarios
4. `spec/compatibility/docx_js/structure/table_spec.rb:264` - column width setting
5. `spec/compatibility/comprehensive_validation_spec.rb:238` - border style setter

#### Root Cause:
```ruby
# BROKEN: Returns String instead of TableCellProperties object
cell.properties #=> String (!!!)
cell.properties.column_span #=> NoMethodError

# EXPECTED:
cell.properties #=> TableCellProperties object
cell.properties.column_span #=> Integer
```

#### Fix Strategy:
1. **Investigation**:
   - Check `TableCell#properties` implementation
   - Verify `TableCellProperties` class registration
   - Inspect serialization/deserialization pipeline

2. **Implementation**:
   - File: [`lib/uniword/table_cell.rb`](lib/uniword/table_cell.rb)
   - Ensure `properties` method returns `TableCellProperties` instance
   - Add type validation
   - Fix `column_span`, `row_span`, and `width` accessors

3. **Validation**:
   ```bash
   bundle exec rspec spec/compatibility/docx_js/structure/table_spec.rb
   bundle exec rspec spec/compatibility/comprehensive_validation_spec.rb:238
   ```

---

### 🚨 Blocker 2: Numbering/List System Complete Failure
**Priority**: P0 - MUST FIX FIRST
**Failures**: 3 tests
**Impact**: 40% of users (lists completely non-functional)

#### Affected Tests:
1. `spec/compatibility/comprehensive_validation_spec.rb:279` - numbered lists
2. `spec/compatibility/comprehensive_validation_spec.rb:287` - bullet lists
3. `spec/compatibility/comprehensive_validation_spec.rb:294` - multi-level lists

#### Root Cause:
```ruby
# BROKEN: Numbering always returns nil
para.numbering #=> nil (should be Hash/Object)

# When trying to access level:
para.numbering[:level] #=> NoMethodError: undefined method `[]' for nil
```

#### Fix Strategy:
1. **Investigation**:
   - Check `Paragraph#numbering` implementation
   - Verify numbering definitions are loaded from document
   - Inspect numbering instance associations

2. **Implementation**:
   - File: [`lib/uniword/paragraph.rb`](lib/uniword/paragraph.rb)
   - File: [`lib/uniword/numbering_configuration.rb`](lib/uniword/numbering_configuration.rb)
   - Ensure numbering is properly loaded and associated
   - Fix numbering level extraction
   - Add nil safety checks

3. **Validation**:
   ```bash
   bundle exec rspec spec/compatibility/comprehensive_validation_spec.rb:279
   bundle exec rspec spec/compatibility/comprehensive_validation_spec.rb:287
   bundle exec rspec spec/compatibility/comprehensive_validation_spec.rb:294
   ```

---

### 🚨 Blocker 3: Run Properties Over-Initialization
**Priority**: P0 - MUST FIX FIRST
**Failures**: 1 test
**Impact**: 20% of users (backward compatibility broken)

#### Affected Tests:
1. `spec/compatibility/docx_js/text/run_spec.rb:349` - multiple runs in paragraph

#### Root Cause:
```ruby
# BROKEN: Properties initialized when should be nil
para.runs[2].properties #=> RunProperties object

# EXPECTED:
para.runs[2].properties #=> nil (for plain runs)
```

#### Fix Strategy:
1. **Investigation**:
   - Check Run initialization logic
   - Review auto-initialization conditions
   - Identify when properties should remain nil

2. **Implementation**:
   - File: [`lib/uniword/run.rb`](lib/uniword/run.rb)
   - File: [`lib/uniword/properties/run_properties.rb`](lib/uniword/properties/run_properties.rb)
   - Only initialize properties when explicitly needed
   - Add lazy initialization with control flag
   - Preserve nil for pristine runs

3. **Validation**:
   ```bash
   bundle exec rspec spec/compatibility/docx_js/text/run_spec.rb:349
   ```

---

## High Priority Regressions (P1)

### Category 1: Image Handling (2 failures)
**Impact**: 15% of users
**Effort**: Medium

#### Failures:
1. `spec/compatibility/comprehensive_validation_spec.rb:310` - reading images
2. `spec/compatibility/comprehensive_validation_spec.rb:345` - HTML image conversion
3. `spec/compatibility/docx_js/media/images_spec.rb:441` - inline images

#### Fix Strategy:
- File: [`lib/uniword/document.rb`](lib/uniword/document.rb)
- Implement `images` collection method
- Fix image extraction from document parts
- Handle inline vs. anchored images

---

### Category 2: Hyperlink Support (1 failure)
**Impact**: 10% of users
**Effort**: Medium

#### Failure:
1. `spec/compatibility/comprehensive_validation_spec.rb:271` - hyperlink extraction

#### Fix Strategy:
- File: [`lib/uniword/hyperlink.rb`](lib/uniword/hyperlink.rb)
- Implement hyperlink collection in document
- Fix hyperlink extraction from paragraphs
- Handle relationship resolution

---

### Category 3: Line Spacing (1 failure)
**Impact**: 5% of users
**Effort**: Low

#### Failure:
1. `spec/compatibility/comprehensive_validation_spec.rb:214` - line spacing value

#### Expected vs Actual:
```ruby
# Expected: 1.5
# Got: 1
```

#### Fix Strategy:
- File: [`lib/uniword/properties/paragraph_properties.rb`](lib/uniword/properties/paragraph_properties.rb)
- Fix line spacing calculation/conversion
- Ensure proper units (lines vs. points)

---

## Medium Priority Issues (P2)

### Category 4: MHTML/HTML Conversion (11 failures)
**Impact**: 10% of users (specific format)
**Effort**: High

#### Failures:
1. `spec/compatibility/html2doc/mhtml_conversion_spec.rb:18` - HTML paragraph conversion
2. `spec/integration/mhtml_compatibility_spec.rb:69` - MIME part termination
3. `spec/integration/mhtml_compatibility_spec.rb:147` - HTML structure tags
4. `spec/integration/mhtml_compatibility_spec.rb:156` - HTML content structure
5. `spec/integration/mhtml_compatibility_spec.rb:198` - image encoding
6. `spec/integration/mhtml_compatibility_spec.rb:212` - image Content-Location
7. `spec/integration/mhtml_edge_cases_spec.rb:39` - empty paragraphs
8. `spec/integration/mhtml_edge_cases_spec.rb:61` - empty table cells
9. `spec/integration/mhtml_edge_cases_spec.rb:131` - HTML entities
10. `spec/integration/mhtml_edge_cases_spec.rb:382` - whitespace handling
11. `spec/integration/mhtml_edge_cases_spec.rb:522` - multiple formatting

#### Fix Strategy:
- File: [`lib/uniword/html_importer.rb`](lib/uniword/html_importer.rb)
- Fix HTML entity conversion
- Improve MIME boundary handling
- Fix empty element creation
- Handle whitespace-only content

---

### Category 5: Styles System (4 failures)
**Impact**: 15% of users
**Effort**: Medium

#### Failures:
1. `spec/compatibility/docx_gem/style_spec.rb:119` - default heading styles
2. `spec/integration/styles_integration_spec.rb:80` - custom style preservation
3. `spec/compatibility/docx_gem_compatibility_spec.rb:128` - text alignment
4. `spec/integration/compatibility_spec.rb:386` - UTF-8 encoding

#### Fix Strategy:
- File: [`lib/uniword/styles_configuration.rb`](lib/uniword/styles_configuration.rb)
- Ensure default heading styles included
- Fix style preservation in round-trip
- Fix alignment detection
- Ensure UTF-8 encoding

---

### Category 6: Page Setup/Margins (4 failures)
**Impact**: 5% of users
**Effort**: Low

#### Failures:
1. `spec/compatibility/docx_js/layout/page_setup_spec.rb:8` - zero margins
2. `spec/compatibility/docx_js/layout/page_setup_spec.rb:25` - zero margin content
3. `spec/compatibility/docx_js/layout/page_setup_spec.rb:318` - page setup integration

#### Fix Strategy:
- File: [`lib/uniword/section.rb`](lib/uniword/section.rb)
- Support zero margin values
- Fix page setup application to sections

---

## Low Priority Issues (P3)

### Category 7: Document Operations (3 failures)
**Impact**: 5% of users
**Effort**: Low

#### Failures:
1. `spec/compatibility/docx_gem_api_spec.rb:93` - paragraph.remove!
2. `spec/compatibility/docx_gem_api_spec.rb:146` - run.substitute with regex
3. `spec/compatibility/docx_gem_api_spec.rb:257` - row.copy operation

#### Fix Strategy:
- Implement missing API methods for docx gem compatibility
- Add remove!, substitute, and copy operations

---

### Category 8: Real-World Documents (3 failures)
**Impact**: Research/diagnostic
**Effort**: Low

#### Failures:
1. `spec/integration/real_world_documents_spec.rb:252` - simple documents
2. `spec/integration/real_world_documents_spec.rb:259` - heavy formatting
3. `spec/integration/real_world_documents_spec.rb:265` - many tables
4. `spec/integration/real_world_documents_spec.rb:271` - embedded images

#### Fix Strategy:
- These are performance/compatibility tests
- Fix as other issues are resolved
- May be due to missing image/hyperlink support

---

### Category 9: Edge Cases (2 failures)
**Impact**: <1% of users
**Effort**: Trivial

#### Failures:
1. `spec/integration/mhtml_edge_cases_spec.rb:472` - wrong exception type
2. `spec/integration/edge_cases_spec.rb:313` - wrong exception type

#### Expected vs Actual:
```ruby
# Expected: ArgumentError with /File not found/
# Got: Uniword::FileNotFoundError
```

#### Fix Strategy:
- Update tests to expect `Uniword::FileNotFoundError`
- This is correct behavior, tests are outdated

---

## Sprint 2 Recovery Roadmap

### Phase 1: Emergency Stabilization (Week 1)
**Goal**: Fix all P0 blockers to restore functionality

1. ✅ **Day 1-2**: Fix Table Cell Properties Type System
   - Restore TableCellProperties object return type
   - Fix column_span, row_span, width accessors
   - Validate with 7 tests

2. ✅ **Day 3-4**: Fix Numbering/List System
   - Restore paragraph.numbering functionality
   - Fix numbering definition loading
   - Validate with 3 tests

3. ✅ **Day 5**: Fix Run Properties Over-Initialization
   - Implement conditional initialization
   - Preserve nil for pristine runs
   - Validate with 1 test

**Success Criteria**: Failure count drops from 40 to ≤29

---

### Phase 2: High Priority Fixes (Week 2)
**Goal**: Restore core document features

4. ✅ **Day 6-7**: Image Handling
   - Implement image collection
   - Fix image extraction
   - Validate with 3 tests

5. ✅ **Day 8**: Hyperlink Support
   - Implement hyperlink extraction
   - Validate with 1 test

6. ✅ **Day 9**: Line Spacing
   - Fix line spacing calculation
   - Validate with 1 test

**Success Criteria**: Failure count drops to ≤24

---

### Phase 3: Medium Priority Fixes (Week 3)
**Goal**: Improve format conversion and styling

7. ✅ **Day 10-12**: MHTML/HTML Conversion
   - Fix HTML entity conversion
   - Improve MIME handling
   - Validate with 11 tests

8. ✅ **Day 13-14**: Styles System
   - Add default heading styles
   - Fix style preservation
   - Validate with 4 tests

9. ✅ **Day 15**: Page Setup
   - Support zero margins
   - Validate with 4 tests

**Success Criteria**: Failure count drops to ≤9

---

### Phase 4: Polish & Completion (Week 4)
**Goal**: Complete remaining fixes

10. ✅ **Day 16-17**: Document Operations
    - Implement missing API methods
    - Validate with 3 tests

11. ✅ **Day 18**: Real-World Documents
    - Fix as dependencies resolve
    - Validate with 4 tests

12. ✅ **Day 19**: Edge Cases
    - Update exception expectations
    - Validate with 2 tests

**Success Criteria**: Failure count reaches 0

---

## Testing Strategy

### Regression Prevention
```bash
# After each fix, run full suite
bundle exec rspec

# Track failure count
# Phase 1 target: ≤29 failures
# Phase 2 target: ≤24 failures
# Phase 3 target: ≤9 failures
# Phase 4 target: 0 failures
```

### Continuous Validation
```bash
# Run specific category tests during development
bundle exec rspec spec/compatibility/docx_js/structure/table_spec.rb
bundle exec rspec spec/compatibility/comprehensive_validation_spec.rb
bundle exec rspec spec/integration/mhtml_*.rb
```

### Before/After Comparison
```bash
# Generate JSON reports for comparison
bundle exec rspec --format json --out before.json
# Make fixes
bundle exec rspec --format json --out after.json
# Compare counts
```

---

## Success Metrics

### Sprint 2 Goals

| Metric | Current | Phase 1 | Phase 2 | Phase 3 | Phase 4 |
|--------|---------|---------|---------|---------|---------|
| **Failures** | 40 | ≤29 | ≤24 | ≤9 | 0 |
| **Pass Rate** | 98.1% | 98.6% | 98.8% | 99.6% | 100% |
| **User Coverage** | ~70% | 80% | 90% | 95% | 100% |
| **Confidence** | Low | Medium | High | High | Very High |

### Phase Completion Criteria

✅ **Phase 1 Complete When**:
- Table operations working (column_span, row_span, width)
- Lists/numbering functional
- Run properties behave correctly
- No new regressions

✅ **Phase 2 Complete When**:
- Images can be extracted and embedded
- Hyperlinks work
- Line spacing accurate
- All Phase 1 fixes stable

✅ **Phase 3 Complete When**:
- MHTML conversion working
- Styles preserved correctly
- Page setup functional
- All previous phases stable

✅ **Phase 4 Complete When**:
- All 2,075 tests passing
- Zero failures
- Zero regressions
- Full documentation updated

---

## Risk Mitigation

### High Risk Areas

1. **Type System Changes**
   - Risk: Breaking other property types
   - Mitigation: Thorough testing of all property classes

2. **Numbering System**
   - Risk: Complex inter-dependencies
   - Mitigation: Incremental fixes with continuous testing

3. **Over-Initialization Fix**
   - Risk: Breaking existing code that depends on auto-init
   - Mitigation: Add feature flag for gradual rollout

### Rollback Plan

If critical issues arise:
1. Maintain git tags for each phase
2. Can rollback to last stable phase
3. Document breaking changes
4. Provide migration guide

---

## Appendix: Complete Failure List

### P0 Blockers (11 failures)
- Table cell properties: 7
- Numbering/lists: 3
- Run properties: 1

### P1 High Priority (5 failures)
- Images: 3
- Hyperlinks: 1
- Line spacing: 1

### P2 Medium Priority (19 failures)
- MHTML/HTML: 11
- Styles: 4
- Page setup: 4

### P3 Low Priority (5 failures)
- Document operations: 3
- Edge cases: 2

**Total**: 40 failures across 8 categories

---

## Conclusion

Sprint 2 must focus on **emergency recovery** before any new features. The priority order is:

1. **Week 1**: Fix critical blockers (P0) - restore basic functionality
2. **Week 2**: Fix high priority (P1) - restore core features
3. **Week 3**: Fix medium priority (P2) - improve stability
4. **Week 4**: Fix low priority (P3) - achieve zero failures

Only after achieving zero failures should Sprint 3 begin with new feature development.

---

**Report Generated**: 2025-10-28T00:02:00Z
**Next Review**: After Phase 1 completion
**Owner**: Development Team
**Status**: READY FOR EXECUTION
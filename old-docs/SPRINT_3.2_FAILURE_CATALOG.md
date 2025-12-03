# Sprint 3.2 Failure Catalog

**Date:** 2025-10-28 16:58 JST
**Total Failures:** 31
**Pass Rate:** 98.4%

---

## Failure Categories

### Category 1: MHTML Format Issues (9 failures)

**Priority:** P2 - High Value
**Impact:** MHTML format completeness
**Effort:** Medium-High

#### 1.1 HTML Import/Export (1 failure)

| # | Test | Issue | Root Cause |
|---|------|-------|------------|
| 1 | `mhtml_conversion_spec.rb:18` | No paragraphs created | `<p>` tags not parsed |

#### 1.2 Empty Element Preservation (3 failures)

| # | Test | Issue | Root Cause |
|---|------|-------|------------|
| 2 | `mhtml_edge_cases_spec.rb:39` | Empty runs dropped | Serializer skips empty |
| 3 | `mhtml_edge_cases_spec.rb:61` | Empty cells dropped | No empty paragraph |
| 4 | `mhtml_edge_cases_spec.rb:382` | Whitespace-only lost | Text stripped |

#### 1.3 Character Encoding (1 failure)

| # | Test | Issue | Root Cause |
|---|------|-------|------------|
| 5 | `mhtml_edge_cases_spec.rb:131` | Entities not decoded | `&copy;` → `©` missing |

#### 1.4 CSS Formatting (1 failure)

| # | Test | Issue | Root Cause |
|---|------|-------|------------|
| 6 | `mhtml_edge_cases_spec.rb:522` | Multi-property broken | Underline conflicts |

#### 1.5 MIME Structure (3 failures)

| # | Test | Issue | Root Cause |
|---|------|-------|------------|
| 7 | `mhtml_compatibility_spec.rb:69` | No final newline | Boundary incomplete |
| 8 | `mhtml_compatibility_spec.rb:147` | Missing `<body>` | Test expectation issue |
| 9 | `mhtml_compatibility_spec.rb:198` | No base64 encoding | Images not embedded |
| 10 | `mhtml_compatibility_spec.rb:212` | No Content-Location | Image headers missing |

---

### Category 2: Page Setup API (3 failures)

**Priority:** P2 - Medium Value
**Impact:** Page layout control
**Effort:** Medium

| # | Test | Issue | Root Cause |
|---|------|-------|------------|
| 11 | `page_setup_spec.rb:8` | Method missing | `page_margins` not defined |
| 12 | `page_setup_spec.rb:25` | Method missing | `page_margins` not defined |
| 13 | `page_setup_spec.rb:318` | Method missing | `page_margins` not defined |

**Common Fix:** Implement `Section#page_margins` method

---

### Category 3: Style System (2 failures)

**Priority:** P2 - Medium Value
**Impact:** Style consistency
**Effort:** Low

| # | Test | Issue | Root Cause |
|---|------|-------|------------|
| 14 | `style_spec.rb:119` | Wrong name format | "Heading1" vs "Heading 1" |
| 15 | `styles_integration_spec.rb:80` | Name changed | "MyCustomStyle" normalized |

**Common Fix:** Preserve exact style names, normalize only for lookup

---

### Category 4: Round-Trip Accuracy (2 failures)

**Priority:** P2 - High Value
**Impact:** Data integrity
**Effort:** Medium

| # | Test | Issue | Root Cause |
|---|------|-------|------------|
| 16 | `round_trip_spec.rb:78` | Missing empty run | Empty runs not serialized |
| 17 | `round_trip_spec.rb:152` | Space lost/added | "Directive" vs " Directive" |

---

### Category 5: API Compatibility (4 failures)

**Priority:** P1/P3 - Varies
**Impact:** API surface
**Effort:** Low-Medium

| # | Test | Issue | Priority | Root Cause |
|---|------|-------|----------|------------|
| 18 | `run_spec.rb:349` | Properties auto-created | **P1** | Run initialization |
| 19 | `docx_gem_api_spec.rb:93` | Wrong method call | P3 | Test calls Run#remove! |
| 20 | `docx_gem_api_spec.rb:146` | Wrong substitution | P3 | Regex logic error |
| 21 | `docx_gem_api_spec.rb:257` | Shallow copy | P3 | Marshal not deep |

---

### Category 6: Error Handling (2 failures)

**Priority:** P3 - Low Value
**Impact:** Error messages
**Effort:** Very Low

| # | Test | Issue | Root Cause |
|---|------|-------|------------|
| 22 | `edge_cases_spec.rb:313` | Wrong error type | Test expects ArgumentError |
| 23 | `mhtml_edge_cases_spec.rb:472` | Wrong error type | Test expects ArgumentError |

**Fix:** Update tests to expect `FileNotFoundError` (correct behavior)

---

### Category 7: Real-World Documents (2 failures)

**Priority:** P2 - Medium Value
**Impact:** Production use
**Effort:** Medium

| # | Test | Issue | Root Cause |
|---|------|-------|------------|
| 24 | `real_world_documents_spec.rb:97` | Content mismatch | Links → empty strings |
| 25 | `compatibility_spec.rb:386` | Encoding mismatch | ASCII-8BIT vs UTF-8 |

---

### Category 8: Bonus - Now Passing (4)

**Status:** ✅ Fixed automatically
**Impact:** Positive surprise

| # | Test | Status | Note |
|---|------|--------|------|
| 26 | `real_world_documents_spec.rb:252` | ✅ PASS | Simple documents |
| 27 | `real_world_documents_spec.rb:259` | ✅ PASS | Heavy formatting |
| 28 | `real_world_documents_spec.rb:265` | ✅ PASS | Many tables |
| 29 | `real_world_documents_spec.rb:271` | ✅ PASS | Embedded images |

**Note:** These were marked as pending but now pass. Tests need updating.

---

### Category 9: HTML Compatibility (1 failure)

**Priority:** P2 - Medium Value
**Impact:** HTML conversion
**Effort:** Low

| # | Test | Issue | Root Cause |
|---|------|-------|------------|
| 30 | `comprehensive_validation_spec.rb:345` | No images | HTML images not imported |

---

### Category 10: Text Alignment (1 failure)

**Priority:** P3 - Low Value
**Impact:** Feature detection
**Effort:** Low

| # | Test | Issue | Root Cause |
|---|------|-------|------------|
| 31 | `docx_gem_compatibility_spec.rb:128` | No aligned paras | Test fixture issue |

---

## Failure Breakdown by Priority

### P1 - Critical (1 failure)
- Run properties inheritance: 1

### P2 - High Value (18 failures)
- MHTML format: 9
- Page setup: 3
- Styles: 2
- Round-trip: 2
- Real-world: 2

### P3 - Low Value (8 failures)
- API compatibility: 3
- Error handling: 2
- Text alignment: 1
- HTML images: 1
- Encoding: 1

### Bonus - Fixed (4)
- Pending tests now passing: 4

---

## Effort Estimation

### Quick Wins (< 1 hour each)

1. **Error Type Tests** - Just update expectations
2. **Style Name Handling** - Simple normalization map
3. **HTML Entity Decoding** - Standard entity map
4. **Boundary Termination** - Add newline

**Total Quick Wins:** 4 failures, ~2 hours

### Medium Effort (2-4 hours each)

1. **Empty Element Preservation** - 3 failures, ~3 hours
2. **Page Setup API** - 3 failures, ~2 hours
3. **Image Embedding** - 2 failures, ~3 hours
4. **Round-Trip Fixes** - 2 failures, ~2 hours

**Total Medium:** 10 failures, ~10 hours

### Higher Effort (4+ hours each)

1. **HTML Paragraph Import** - 1 failure, ~2 hours
2. **CSS Multi-Property** - 1 failure, ~1 hour
3. **API Compatibility** - 4 failures, ~3 hours
4. **Real-World Issues** - 2 failures, ~4 hours

**Total Higher:** 8 failures, ~10 hours

---

## Sprint 3.2 Target Selection

### Primary Targets (10 failures → 17 total)

**MHTML Format Completion:**
- HTML paragraph import (1)
- Empty elements (3)
- HTML entities (1)
- CSS multi-property (1)
- MIME structure (3)
- **Subtotal:** 9 failures

**Page Setup API:**
- Page margins method (3)
- **Subtotal:** 3 failures

**Style System:**
- Name normalization (2)
- **Subtotal:** 2 failures

**Quick Fixes:**
- Error type tests (2)
- **Subtotal:** 2 failures

**Total Sprint 3.2:** 16 failures addressed → ~15 remaining

### Deferred to Sprint 3.3

- Run properties inheritance (1)
- Round-trip fixes (2)
- API compatibility (3)
- Real-world issues (2)
- Other (3)

---

## Implementation Order

### Phase 1: Quick Wins (Session 1, Part A)
1. HTML entity decoding
2. Error type test fixes
3. Boundary termination

**Time:** 1-2 hours
**Fixes:** 4 failures

### Phase 2: MHTML Core (Session 1, Part B)
1. HTML paragraph import
2. Empty element preservation
3. CSS multi-property

**Time:** 3-4 hours
**Fixes:** 5 failures

### Phase 3: MHTML Polish (Session 2)
1. Image base64 encoding
2. Content-Location headers
3. Validate MHTML compatibility

**Time:** 2-3 hours
**Fixes:** 2 failures

### Phase 4: API Features (Session 3)
1. Page margins API
2. Style name handling
3. Full validation

**Time:** 2-3 hours
**Fixes:** 5 failures

---

## Success Metrics

### Sprint 3.2 Goals

| Metric | Current | Target | Method |
|--------|---------|--------|--------|
| Total Failures | 31 | 17 | Fix 14 issues |
| MHTML Issues | 9 | 0 | Complete format |
| Page Setup | 3 | 0 | Implement API |
| Pass Rate | 98.4% | 99.0% | Reduce failures |

### Acceptance Criteria

✅ All MHTML format tests passing
✅ Page margins API functional
✅ Style names handled correctly
✅ No new regressions introduced
✅ Performance maintained
✅ Documentation updated

---

## Risk Mitigation

### High Risk Areas

1. **Empty Element Changes**
   - **Risk:** Break existing serialization
   - **Mitigation:** Test all round-trips thoroughly
   - **Rollback:** Preserve current behavior as fallback

2. **MIME Structure**
   - **Risk:** Word can't open files
   - **Mitigation:** Test with actual Word application
   - **Validation:** Follow RFC 2557 exactly

### Testing Strategy

1. **Unit Tests** - Each feature isolated
2. **Integration Tests** - Full MHTML cycle
3. **Real Document Tests** - MN samples
4. **Regression Tests** - Existing functionality
5. **Manual Testing** - Open in Word

---

## Dependencies

### Sprint 3.2 Prerequisites

✅ Sprint 3.1 complete (3/4 P1 features)
✅ Test suite stable at 31 failures
✅ No blocking regressions
✅ Performance acceptable

### External Dependencies

- None - all work uses existing gems

### Internal Dependencies

- HTML serializer/deserializer
- MIME packager/parser
- Section properties
- Style configuration

---

## Rollback Plan

If critical regressions occur:

1. **Identify Issue** - Which feature caused regression
2. **Isolate Change** - Git diff to find change
3. **Revert Feature** - Back out specific change
4. **Re-test** - Confirm stability restored
5. **Fix Properly** - Address in isolation
6. **Re-integrate** - With better testing

---

## Next Steps

### Immediate (Today)

1. ✅ Complete validation report
2. Review and approve Sprint 3.2 plan
3. Begin Feature 1: HTML paragraph import

### Short Term (This Week)

1. Complete MHTML format features
2. Implement page setup API
3. Fix style name handling
4. Validate against real documents

### Medium Term (Next Week)

1. Sprint 3.3: API compatibility
2. Sprint 3.4: Final polish
3. Reach 99% pass rate
4. Prepare release notes

---

## Conclusion

Sprint 3.1 successfully delivered **3 critical P1 features** and maintained excellent test stability at **98.4% pass rate**. The remaining 31 failures are well-categorized and have clear resolution paths.

Sprint 3.2 is ready to execute with detailed specifications for **MHTML format completion**, targeting **14-16 failures** fixed and bringing the project to **~15 remaining failures** (99%+ pass rate).

**Recommendation:** Proceed with Sprint 3.2 focusing on MHTML format as highest-value target.
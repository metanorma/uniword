# Sprint 3.2 Implementation Plan: Real-World Document Support

## Test Results Summary

### ISO 8601-2 Document Import Test (Real-World Documents)

**Test Date:** 2025-10-28

#### Document 1: `iso-wd-8601-2-2026.docx` (DOCX format)
- ✅ Import: **SUCCESSFUL** (6.99s)
- Document Statistics:
  - Paragraphs: 2,399
  - Tables: 31
  - Images: 4
  - Text length: 197,231 characters
- Features:
  - ✅ Styles: Present
  - ✅ Headers: Present
  - ✅ Footers: Present
  - ❌ Numbering: None detected
- Round-trip Results:
  - ✅ Paragraphs: Preserved (2,399 → 2,399)
  - ✅ Tables: Preserved (31 → 31)
  - ✅ Images: Preserved (4 → 4)
  - ❌ **Text: LOST 10,706 chars (5.4% loss)** (197,231 → 186,525)

**Critical Issue Found:**
```
First difference at position 1102:
Original:  " 22 749 01 11Email: copyright@iso.orgWebs"
Round-trip: " 22 749 01 11Email: Website: \nPublished i"
```
This indicates **hyperlink text loss** during round-trip.

#### Document 2: `document.doc` (MHTML format)
- ✅ Import: **SUCCESSFUL** (0.98s)
- Document Statistics:
  - Paragraphs: 2,339
  - Tables: 31
  - Images: 0 (MHTML image extraction issue?)
  - Text length: 203,871 characters
- Features:
  - ✅ Styles: Present
  - ✅ Headers: Present
  - ✅ Footers: Present
  - ❌ Numbering: None detected
- Round-trip Results:
  - ✅ Text: **100% PRESERVED** (203,871 → 203,871)
  - ✅ Paragraphs: Preserved (2,339 → 2,339)
  - ✅ Tables: Preserved (31 → 31)
  - ✅ Images: Preserved (0 → 0)

### Current Test Status

```
2131 examples, 0 failures, 2 pending
```

**ALL TESTS PASSING!** 🎉

---

## Sprint 3.2 Priority Issues

Based on real-world document testing, prioritize in this order:

### Priority 1: CRITICAL - Hyperlink Text Loss (DOCX)

**Impact:** 5.4% text loss in ISO 8601-2 document
**Root Cause:** Hyperlink text not being properly serialized/deserialized
**Files to investigate:**
- `lib/uniword/hyperlink.rb`
- `lib/uniword/serialization/ooxml_serializer.rb`
- `lib/uniword/serialization/ooxml_deserializer.rb`

**Action Items:**
1. Investigate hyperlink serialization in OOXML
2. Ensure hyperlink text is preserved in round-trip
3. Add comprehensive hyperlink round-trip tests
4. Test with ISO document to verify fix

### Priority 2: MEDIUM - MHTML Image Support

**Impact:** 4 images in DOCX but 0 in MHTML version
**Root Cause:** MHTML handler may not be extracting embedded images
**Files to investigate:**
- `lib/uniword/formats/mhtml_handler.rb`
- `lib/uniword/infrastructure/mime_parser.rb`

**Action Items:**
1. Verify MHTML image extraction in parser
2. Add image round-trip tests for MHTML
3. Ensure base64 embedded images are handled

### Priority 3: LOW - Performance Optimization

**Impact:** DOCX import takes 7x longer than MHTML (6.99s vs 0.98s)
**Files to investigate:**
- `lib/uniword/formats/docx_handler.rb`
- `lib/uniword/serialization/ooxml_deserializer.rb`

**Action Items:**
1. Profile DOCX import to identify bottlenecks
2. Consider lazy loading for large documents
3. Optimize XML parsing

---

## Implementation Plan

### Phase 1: Fix Hyperlink Text Loss (Priority 1)

**Estimated Time:** 2-3 hours

1. **Investigate Current Hyperlink Handling**
   - Read hyperlink.rb to understand structure
   - Check OOXML serializer/deserializer for hyperlink handling
   - Identify where text is being lost

2. **Fix Hyperlink Serialization**
   - Ensure hyperlink text is included in OOXML output
   - Handle both external URLs and internal anchors
   - Preserve tooltip and display text

3. **Add Comprehensive Tests**
   - Create hyperlink round-trip test with ISO-like content
   - Test email hyperlinks specifically
   - Test mixed hyperlink types (URLs, emails, anchors)

4. **Verify with Real Document**
   - Re-run ISO 8601-2 import test
   - Verify 100% text preservation
   - Check specific email/URL hyperlinks

### Phase 2: MHTML Image Support (Priority 2)

**Estimated Time:** 2-3 hours

1. **Investigate MHTML Image Handling**
   - Check MIME parser for image extraction
   - Verify base64 decoding
   - Check image relationship handling

2. **Implement Missing Features**
   - Add image extraction from MHTML
   - Handle inline images
   - Support common image formats (PNG, JPEG, GIF)

3. **Add Tests**
   - Create MHTML document with embedded images
   - Test round-trip preservation
   - Verify image data integrity

### Phase 3: Performance Optimization (Priority 3)

**Estimated Time:** 1-2 hours

1. **Profile Current Implementation**
   - Identify slow operations in DOCX import
   - Check for unnecessary parsing
   - Look for repeated operations

2. **Optimize**
   - Implement lazy loading where appropriate
   - Cache frequently accessed data
   - Optimize XML parsing

3. **Benchmark**
   - Re-run ISO document import
   - Target <3s for DOCX import
   - Maintain <1s for MHTML import

---

## Success Criteria

### Phase 1 (Hyperlinks)
- ✅ ISO 8601-2 DOCX: 100% text preservation in round-trip
- ✅ All hyperlink types (URL, email, anchor) work correctly
- ✅ Hyperlink formatting (color, underline) preserved
- ✅ All existing tests still pass

### Phase 2 (MHTML Images)
- ✅ MHTML documents with images import correctly
- ✅ Image count matches between formats
- ✅ Image data integrity verified
- ✅ All existing tests still pass

### Phase 3 (Performance)
- ✅ DOCX import <3s for ISO-sized documents (~200K chars)
- ✅ MHTML import <1s for ISO-sized documents
- ✅ Memory usage reasonable (<100MB for typical documents)
- ✅ All existing tests still pass

---

## Next Steps

1. **Start with Priority 1** (Hyperlink Text Loss)
   - This is critical for data integrity
   - Affects real-world documents immediately
   - Should be quick to fix

2. **Then Priority 2** (MHTML Images)
   - Important for format parity
   - Affects visual fidelity
   - May uncover other MHTML issues

3. **Finally Priority 3** (Performance)
   - Nice-to-have improvement
   - Already acceptable for most use cases
   - Can be iterative

---

## Risk Assessment

### Low Risk
- Hyperlink fix (well-defined problem)
- Test additions (no breaking changes)

### Medium Risk
- MHTML image support (may affect parsing)
- Performance optimization (could introduce regressions)

### Mitigation
- Run full test suite after each change
- Test with real ISO documents frequently
- Keep changes small and focused
- Maintain backward compatibility

---

## Timeline

- **Day 1:** Priority 1 - Hyperlink text preservation
- **Day 2:** Priority 2 - MHTML image support
- **Day 3:** Priority 3 - Performance optimization + final validation

**Total Estimated Time:** 5-8 hours of focused development

---

## Appendix: Test Output

See `test_iso_8601_results.txt` for full test output.

### Key Metrics
- Total paragraphs processed: 4,738 (across both documents)
- Total tables processed: 62
- Total images processed: 4
- Text processed: 401,102 characters
- Average import speed: 100K chars/second (MHTML) vs 28K chars/second (DOCX)
- Round-trip success rate: 50% perfect (MHTML), 95% near-perfect (DOCX)
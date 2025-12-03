# Final 21 Test Failures Analysis for v2.0.0

## Current Status
- **Pass Rate**: 2167/2188 (99.04%)
- **Failures**: 21
- **Goal**: 100% pass rate for v2.0.0

## Failure Categories

### Category 1: Run Properties API (7 failures) - CRITICAL
**Root Cause**: `run.properties` returns `nil` instead of a `RunProperties` object

**Failures**:
1. Edge case: Font size setter (spec/integration/edge_cases_spec.rb:378)
2. Comprehensive: Highlight setter (spec/compatibility/comprehensive_validation_spec.rb:251)
3. Comprehensive: Font size setter (spec/compatibility/comprehensive_validation_spec.rb:178)
4. Comprehensive: Font color setter (spec/compatibility/comprehensive_validation_spec.rb:186)
5. Comprehensive: Font name setter (spec/compatibility/comprehensive_validation_spec.rb:194)
6. Comprehensive: Bold setter (spec/compatibility/comprehensive_validation_spec.rb:162)
7. Comprehensive: Italic setter (spec/compatibility/comprehensive_validation_spec.rb:170)

**Fix**: Ensure `Run#properties` always returns a `RunProperties` object, auto-initializing if nil

---

### Category 2: Style Name Format (5 failures)
**Root Cause**: Inconsistent style naming - some tests expect spaces ("Heading 1"), others expect no spaces ("Heading1")

**Failures**:
9. Uniword::ParagraphStyle heading styles (spec/uniword/styles_spec.rb:113) - expects "Heading1", gets "Heading 1"
14. Styles Integration styled paragraphs (spec/integration/styles_integration_spec.rb:60) - expects "Heading 1", gets "Heading1"
15. Styles Integration custom styles (spec/integration/styles_integration_spec.rb:122) - expects "My Custom Style", gets "MyCustomStyle"
16. Styles Integration all heading levels (spec/integration/styles_integration_spec.rb:217) - expects "Heading 1", gets "Heading1"
21. Docx Gem Compatibility document styles (spec/compatibility/docx_gem/document_spec.rb:293) - expects "Heading 1", gets "Heading1"

**Fix**: Standardize to match OOXML spec - heading styles use "Heading1", "Heading2", etc. (no spaces), but display name can have spaces

---

### Category 3: MHTML Issues (5 failures)
**Root Cause**: MHTML serialization missing HTML structure elements and image handling

**Failures**:
11. HTML structure tags - missing `<body>` tag (spec/integration/mhtml_compatibility_spec.rb:220)
12. Image encoding (spec/integration/mhtml_compatibility_spec.rb:198)
13. Image Content-Location (spec/integration/mhtml_compatibility_spec.rb:212)
17. Empty runs handling - 0 paragraphs instead of 1 (spec/integration/mhtml_edge_cases_spec.rb:50)
19. Whitespace only - 0 paragraphs instead of 1 (spec/integration/mhtml_edge_cases_spec.rb:391)

**Fix**: Update MHTML handler to properly include HTML body tags and handle edge cases

---

### Category 4: Other Issues (4 failures)
**Failures**:
2. HTML to DOCX image conversion (spec/compatibility/comprehensive_validation_spec.rb:348) - images.count is 0
10. Reading paragraph styles returns nil (spec/compatibility/docx_gem/style_spec.rb:98)
18. Underline property returns "single" instead of true (spec/integration/mhtml_edge_cases_spec.rb:544)
20. Text alignment detection (spec/compatibility/docx_gem_compatibility_spec.rb:136)

**Fix**: Various API compatibility and deserialization fixes

---

## Fix Priority Order

1. **Run Properties API** (7 fixes) - Most critical, affects multiple areas
2. **Style Name Format** (5 fixes) - Architectural decision needed
3. **MHTML Issues** (5 fixes) - Format handler updates
4. **Other Issues** (4 fixes) - Individual fixes

## Architectural Principles

All fixes must follow:
- Object-oriented design
- MECE (Mutually Exclusive, Collectively Exhaustive)
- Separation of concerns
- DRY (Don't Repeat Yourself)
- Open/Closed Principle
- Single Responsibility Principle
- No hardcoded solutions - use model-driven architecture
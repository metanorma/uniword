# Test Failure Analysis - 21 Failures

## Summary
- **Total Examples**: 1,152
- **Failures**: 21
- **Pending**: 21 (8 are PendingExampleFixedError - tests passing but marked pending)
- **Pass Rate**: 98.2%

## Critical Failures by Category

### 1. Validator Registration Issues (3 failures) - HIGH PRIORITY
**Impact**: Validator system not working correctly

#### Failures:
1. `spec/uniword/validators/element_validator_spec.rb:14` - Returns ElementValidator instead of ParagraphValidator for Paragraph class
2. `spec/uniword/validators/element_validator_spec.rb:19` - Returns ElementValidator instead of TableValidator for Table class
3. `spec/uniword/validators/paragraph_validator_spec.rb:116` - ParagraphValidator not returned from registry

**Root Cause**: Validators not being registered in the registry during initialization

**Fix Location**: [`lib/uniword/validators/paragraph_validator.rb`](lib/uniword/validators/paragraph_validator.rb) and [`lib/uniword/validators/table_validator.rb`](lib/uniword/validators/table_validator.rb)

**Fix Strategy**: Add registration calls in validator class definitions

---

### 2. Document#add_element Validation (2 failures) - HIGH PRIORITY
**Impact**: Cannot add elements to documents properly

#### Failures:
1. `spec/uniword/document_spec.rb:22` - ArgumentError: Unsupported element type: Uniword::Element
2. `spec/uniword/logger_spec.rb:115` - ArgumentError: Unsupported element type: Uniword::Run

**Root Cause**: Document#add_element has overly strict validation that rejects abstract Element class and Run elements

**Fix Location**: [`lib/uniword/document.rb:201`](lib/uniword/document.rb:201) in `add_element` method

**Fix Strategy**:
- Allow abstract Element for testing
- Add Run to supported element types (should be wrapped in Paragraph)
- Improve error message to suggest wrapping Run in Paragraph

---

### 3. OOXML Pending Tests (8 PendingExampleFixedError) - MEDIUM PRIORITY
**Impact**: Tests are actually passing but marked as pending

#### Failures:
1. `spec/uniword/ooxml/namespace_spec.rb:7` - Document namespaces
2. `spec/uniword/ooxml/namespace_spec.rb:15` - WordProcessingML namespace
3. `spec/uniword/ooxml/namespace_spec.rb:23` - Relationships namespace
4. `spec/uniword/ooxml/namespace_spec.rb:93` - Table namespaces
5. `spec/uniword/ooxml/namespace_spec.rb:100` - Table root element
6. `spec/uniword/ooxml/namespace_spec.rb:119` - TableRow namespaces
7. `spec/uniword/ooxml/namespace_spec.rb:126` - TableRow root element
8. `spec/uniword/ooxml/namespace_spec.rb:145,152,171` - TableCell and Image namespaces

**Root Cause**: Tests marked with `pending` but implementation already works

**Fix Location**: [`spec/uniword/ooxml/namespace_spec.rb`](spec/uniword/ooxml/namespace_spec.rb)

**Fix Strategy**: Remove `pending` declarations from passing tests or update pending message

---

### 4. Serialization Method Mismatch (2 failures) - MEDIUM PRIORITY
**Impact**: DocxHandler serialization tests failing

#### Failures:
1. `spec/uniword/formats/docx_handler_spec.rb:95` - Expected `serialize` method call
2. `spec/uniword/formats/docx_handler_spec.rb:203` - Same issue with custom serializer

**Root Cause**: OoxmlSerializer API changed from `serialize` to `serialize_package`

**Fix Location**: [`spec/uniword/formats/docx_handler_spec.rb`](spec/uniword/formats/docx_handler_spec.rb)

**Fix Strategy**: Update mock expectations to use `serialize_package` instead of `serialize`

---

### 5. Text Extraction from Tables (1 failure) - LOW PRIORITY
**Impact**: Table text not extracted in visitor

#### Failure:
`spec/uniword/visitor/text_extractor_spec.rb:181` - Missing table text in output

**Expected**:
```
"This is a paragraph.\nHeader 1 | Header 2\nData 1 | Data 2\nFinal paragraph"
```

**Got**:
```
"This is a paragraph.\nFinal paragraph"
```

**Root Cause**: TextExtractor visitor not properly visiting table elements

**Fix Location**: [`lib/uniword/visitor/text_extractor.rb`](lib/uniword/visitor/text_extractor.rb)

**Fix Strategy**: Ensure visit_table method is being called for table elements in document

---

### 6. Builder Paragraph Count (1 failure) - LOW PRIORITY
**Impact**: Builder creating extra paragraph

#### Failure:
`spec/uniword/builder_spec.rb:157` - Expected 6 paragraphs, got 7

**Root Cause**: Builder or document adding an extra empty paragraph

**Fix Location**: [`lib/uniword/builder.rb`](lib/uniword/builder.rb) or test expectations

**Fix Strategy**:
- Check if Builder#add_heading creates extra paragraph
- Or update test expectation if behavior is correct

---

### 7. Format Detector Error Type (1 failure) - LOW PRIORITY
**Impact**: Wrong exception type for missing files

#### Failure:
`spec/uniword/format_detector_spec.rb:133` - Expected ArgumentError, got FileNotFoundError

**Root Cause**: FormatDetector correctly raises FileNotFoundError but test expects ArgumentError

**Fix Location**: [`spec/uniword/format_detector_spec.rb:133`](spec/uniword/format_detector_spec.rb:133)

**Fix Strategy**: Update test to expect `Uniword::FileNotFoundError` instead of ArgumentError

---

### 8. Comment XML Serialization (1 PendingExampleFixedError) - LOW PRIORITY
**Impact**: Test passing but marked pending

#### Failure:
`spec/uniword/comment_spec.rb:180` - XML serialization works

**Root Cause**: Test marked pending but implementation complete

**Fix Location**: [`spec/uniword/comment_spec.rb:180`](spec/uniword/comment_spec.rb:180)

**Fix Strategy**: Remove pending marker

---

### 9. Heading Style Name Mapping (2 failures) - LOW PRIORITY
**Impact**: Style names have spaces instead of no spaces

#### Failures:
1. Multiple tests expecting "Heading1" but getting "Heading 1"
2. Multiple tests expecting "Heading2" but getting "Heading 2"

**Root Cause**: Style naming convention changed to include spaces

**Fix Location**: Tests or [`lib/uniword/styles.rb`](lib/uniword/styles.rb)

**Fix Strategy**:
- Either update tests to expect "Heading 1", "Heading 2"
- Or update style generation to use "Heading1", "Heading2"

---

## Recommended Fix Order

### Phase 1: Critical Fixes (Must Fix)
1. ✅ **Validator Registration** - Fix ElementValidator.for to return correct validators
2. ✅ **Document#add_element** - Allow proper element types

### Phase 2: High Priority Fixes
3. ✅ **OOXML Pending Tests** - Remove pending markers from passing tests
4. ✅ **Serialization Method** - Update mock expectations

### Phase 3: Low Priority Fixes
5. ✅ **Text Extraction** - Fix table text extraction
6. ✅ **Builder Count** - Fix or adjust paragraph count
7. ✅ **Format Detector** - Update exception expectation
8. ✅ **Comment Serialization** - Remove pending marker
9. ✅ **Heading Styles** - Align style naming

---

## Next Steps

1. Start with Phase 1 critical fixes (validators and document)
2. Run tests after each fix to verify
3. Move to Phase 2 and Phase 3 incrementally
4. Final full test suite run to ensure no regressions

---

## Test Command
```bash
bundle exec rspec spec/uniword/validators/element_validator_spec.rb
bundle exec rspec spec/uniword/document_spec.rb
bundle exec rspec spec/uniword/ooxml/namespace_spec.rb
bundle exec rspec spec/uniword/formats/docx_handler_spec.rb
bundle exec rspec spec/uniword/visitor/text_extractor_spec.rb
bundle exec rspec spec/uniword/builder_spec.rb
bundle exec rspec spec/uniword/format_detector_spec.rb
bundle exec rspec spec/uniword/comment_spec.rb
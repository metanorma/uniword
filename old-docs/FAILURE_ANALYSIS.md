# Unit Test Failure Analysis

**Total**: 75 failures out of 1152 examples (93.5% pass rate)

## Failure Categories

### Category 1: Format Handler Registration (CRITICAL - 24 failures)
**Issue**: Format handlers not being registered at startup
**Error**: `No handler registered for format: docx. Available formats:`

**Affected Tests**:
- document_writer_spec.rb (4 tests)
- document_factory_spec.rb (10 tests)
- theme_extraction_spec.rb (6 tests)
- errors_spec.rb (4 tests)

**Root Cause**: Format handlers need explicit registration during library initialization

### Category 2: Serialization Infrastructure (20 failures)
**Issue**: `NoMethodError: undefined method 'collection?' for nil:NilClass`

**Affected Elements**:
- Paragraph.to_xml
- TableRow.to_xml
- TableCell.to_xml
- Table.to_xml
- Comment.to_xml

**Root Cause**: lutaml-model attribute definitions missing or not properly configured

### Category 3: Run Text Serialization (5 failures)
**Issue**: `NoMethodError: undefined method 'space' for String`

**Affected Tests**:
- Run.to_xml tests in ooxml/namespace_spec.rb

**Root Cause**: Text attribute mapping expects TextElement but gets String

### Category 4: Properties Immutability (3 failures)
**Issue**: ParagraphProperties not frozen after initialization

**Tests**:
- properties/paragraph_properties_spec.rb

**Root Cause**: Design change - properties are now mutable, tests expect frozen

### Category 5: Style Name Format (3 failures)
**Issue**: Style names changed from "Heading1" to "Heading 1" (with space)

**Tests**:
- builder_spec.rb heading tests

**Root Cause**: Style normalization added spaces

### Category 6: Validator Error Messages (5 failures)
**Issue**: Validators return generic "Element validation failed" instead of specific messages

**Tests**:
- validators/paragraph_validator_spec.rb
- validators/table_validator_spec.rb

**Root Cause**: Validator error aggregation changed

### Category 7: XML Namespace Prefixes (3 failures)
**Issue**: XML using `r:` prefix instead of `w:` for some elements

**Tests**:
- ooxml/namespace_spec.rb

**Root Cause**: Namespace mapping configuration issue

### Category 8: Document Structure (2 failures)
**Issue**: Various structural issues
- Paragraph count mismatch
- Unsupported element type

**Tests**:
- builder_spec.rb
- logger_spec.rb

### Category 9: Comments Serialization (2 failures)
**Issue**: Comments not serializing author attribute

**Tests**:
- comments_part_spec.rb

## Fix Priority

1. **Format Handler Registration** - Blocks 24 tests, affects document I/O
2. **Serialization Infrastructure** - Blocks 20 tests, core functionality
3. **Run Text Serialization** - Blocks 5 tests, affects all text content
4. **Properties Immutability** - 3 tests, design decision needed
5. **Style Names** - 3 tests, API compatibility issue
6. **Validators** - 5 tests, error reporting quality
7. **XML Namespaces** - 3 tests, correctness issue
8. **Misc Issues** - 10 tests, various small fixes
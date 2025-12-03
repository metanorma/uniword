# Sprint 3 Implementation Plan

**Created:** 2025-10-28 15:14 JST
**Status:** Ready to Execute (after Sprint 2.5 emergency fix)
**Goal:** Reduce failures from 31 → 15 (48% reduction)

---

## Prerequisites

### ⚠️ Sprint 2.5 MUST Complete First

Before starting Sprint 3, **Sprint 2.5 emergency fix** must resolve the 13 image-related regressions.

**Current State:** 44 failures
**After Sprint 2.5:** 31 failures ← **Sprint 3 starting point**

---

## Sprint 3 Overview

### Objectives

1. **Complete MHTML format support** (6 failures)
2. **Polish style system** (4 failures)
3. **Implement page setup API** (3 failures)
4. **Fix core API bugs** (4 failures)

### Success Metrics

| Metric | Start | Target | Improvement |
|--------|-------|--------|-------------|
| Total Failures | 31 | 15 | -16 (52%) |
| Pass Rate | 88.5% | 93.3% | +4.8% |
| P1 Bugs | 4 | 0 | -4 (100%) |
| P2 Issues | 19 | 11 | -8 (42%) |

---

## Sprint 3.1: Core API Fixes (P1)

**Duration:** 1 session
**Priority:** P1 (High)
**Failures:** 4 → 0

### Feature 1: Table Border API

**File:** [`lib/uniword/table.rb`](lib/uniword/table.rb)

**Current Issue:**
```ruby
# spec/compatibility/comprehensive_validation_spec.rb:238
NoMethodError: undefined method `border_style=' for nil
```

**Implementation:**
```ruby
class Table < Element
  # Add border accessor methods
  def border
    @properties ||= Properties::TableProperties.new
    @properties.border ||= TableBorder.new
  end

  def border_style=(style)
    border.style = style
  end

  def border_color=(color)
    border.color = color
  end

  def border_width=(width)
    border.width = width
  end
end
```

**Tests to Pass:**
- [`comprehensive_validation_spec.rb:238`](spec/compatibility/comprehensive_validation_spec.rb:238)

### Feature 2: Run Properties Inheritance Fix

**File:** [`lib/uniword/run.rb`](lib/uniword/run.rb)

**Current Issue:**
```ruby
# spec/compatibility/docx_js/text/run_spec.rb:349
# Expected nil properties, got inherited properties
```

**Implementation:**
```ruby
class Run < Element
  def initialize(text: nil, properties: nil, **opts)
    super(**opts)
    @text_element = text
    # Don't auto-create properties - let them be nil
    @properties = properties # Only set if explicitly provided
  end
end
```

**Tests to Pass:**
- [`run_spec.rb:349`](spec/compatibility/docx_js/text/run_spec.rb:349)

### Feature 3: Image Inline Positioning

**File:** [`lib/uniword/image.rb`](lib/uniword/image.rb)

**Current Issue:**
```ruby
# spec/compatibility/docx_js/media/images_spec.rb:441
NoMethodError: undefined method `inline' for Image
```

**Implementation:**
```ruby
class Image < Element
  attribute :inline, :boolean, default: -> { true }
  attribute :floating, :boolean, default: -> { false }

  def inline?
    inline
  end

  def floating?
    floating
  end
end
```

**Tests to Pass:**
- [`images_spec.rb:441`](spec/compatibility/docx_js/media/images_spec.rb:441)

### Feature 4: CSS Number Formatting

**File:** [`lib/uniword/serialization/html_serializer.rb`](lib/uniword/serialization/html_serializer.rb)

**Current Issue:**
```ruby
# Expected: "line-height:360pt"
# Got: "line-height:360.0pt"
```

**Implementation:**
```ruby
def format_css_value(value, unit = '')
  return value unless value.is_a?(Numeric)

  # Format whole numbers without decimal
  formatted = value == value.to_i ? value.to_i.to_s : value.to_s
  "#{formatted}#{unit}"
end

# Usage in line height:
"line-height:#{format_css_value(line_height, 'pt')}"
```

**Tests to Pass:**
- [`html_serializer_spec.rb:147`](spec/uniword/serialization/html_serializer_spec.rb:147)

**Expected Outcome:** 31 failures → 27 failures

---

## Sprint 3.2: MHTML Format Completion (P2)

**Duration:** 2-3 sessions
**Priority:** P2 (Medium)
**Failures:** 27 → 21

### Feature 1: HTML Paragraph Import

**Files:**
- [`lib/uniword/serialization/html_deserializer.rb`](lib/uniword/serialization/html_deserializer.rb)
- [`lib/uniword/html_importer.rb`](lib/uniword/html_importer.rb)

**Current Issue:**
```ruby
# spec/compatibility/html2doc/mhtml_conversion_spec.rb:18
# HTML paragraphs not being imported correctly
# Expected 1 paragraph, got 0
```

**Implementation:**
```ruby
class HtmlDeserializer
  def parse_paragraph(p_element)
    # Ensure <p> tags always create paragraphs
    para = Paragraph.new

    # Parse children (text nodes and inline elements)
    p_element.children.each do |child|
      case child.name
      when 'text'
        para.add_text(child.content) unless child.content.strip.empty?
      when 'strong', 'b'
        para.add_text(child.content, bold: true)
      when 'em', 'i'
        para.add_text(child.content, italic: true)
      # ... other inline elements
      end
    end

    # Even if empty, return the paragraph
    para
  end
end
```

**Tests to Pass:**
- [`mhtml_conversion_spec.rb:18`](spec/compatibility/html2doc/mhtml_conversion_spec.rb:18)

### Feature 2: Empty Element Preservation

**Files:**
- [`lib/uniword/serialization/html_serializer.rb`](lib/uniword/serialization/html_serializer.rb)
- [`lib/uniword/serialization/html_deserializer.rb`](lib/uniword/serialization/html_deserializer.rb)

**Current Issues:**
- Empty runs being dropped
- Empty table cells being dropped
- Whitespace-only text being dropped

**Implementation:**
```ruby
class HtmlSerializer
  def serialize_run(run)
    # Always serialize runs, even if empty
    text = run.text_element || ""

    # Preserve whitespace-only content
    if text.strip.empty? && !text.empty?
      # Use non-breaking space to preserve whitespace
      text = text.gsub(' ', '&nbsp;')
    end

    # ... rest of serialization
  end

  def serialize_table_cell(cell)
    # Always include cell, even if empty
    paragraphs = cell.paragraphs

    if paragraphs.empty? || paragraphs.all?(&:empty?)
      # Add empty paragraph to preserve cell structure
      "<p class=\"MsoNormal\"></p>"
    else
      # ... serialize paragraphs
    end
  end
end
```

**Tests to Pass:**
- [`mhtml_edge_cases_spec.rb:39`](spec/integration/mhtml_edge_cases_spec.rb:39) - Empty runs
- [`mhtml_edge_cases_spec.rb:61`](spec/integration/mhtml_edge_cases_spec.rb:61) - Empty cells
- [`mhtml_edge_cases_spec.rb:382`](spec/integration/mhtml_edge_cases_spec.rb:382) - Whitespace-only

### Feature 3: HTML Entity Decoding

**File:** [`lib/uniword/serialization/html_deserializer.rb`](lib/uniword/serialization/html_deserializer.rb)

**Current Issue:**
```ruby
# spec/integration/mhtml_edge_cases_spec.rb:131
# Expected "©" but got "&copy;"
```

**Implementation:**
```ruby
class HtmlDeserializer
  ENTITY_MAP = {
    '&nbsp;'  => "\u00A0",  # Non-breaking space
    '&copy;'  => "\u00A9",  # ©
    '&reg;'   => "\u00AE",  # ®
    '&trade;' => "\u2122",  # ™
    '&lt;'    => '<',
    '&gt;'    => '>',
    '&amp;'   => '&',
    '&quot;'  => '"',
    '&apos;'  => "'"
  }.freeze

  def decode_entities(text)
    return text unless text

    result = text.dup
    ENTITY_MAP.each do |entity, char|
      result.gsub!(entity, char)
    end

    # Handle numeric entities &#169; → ©
    result.gsub!(/&#(\d+);/) { |m| $1.to_i.chr(Encoding::UTF_8) }
    result.gsub!(/&#x([0-9a-fA-F]+);/) { |m| $1.to_i(16).chr(Encoding::UTF_8) }

    result
  end

  def parse_text_content(element)
    decode_entities(element.content)
  end
end
```

**Tests to Pass:**
- [`mhtml_edge_cases_spec.rb:131`](spec/integration/mhtml_edge_cases_spec.rb:131)

### Feature 4: CSS Multi-Property Formatting

**File:** [`lib/uniword/serialization/html_serializer.rb`](lib/uniword/serialization/html_serializer.rb)

**Current Issue:**
```ruby
# spec/integration/mhtml_edge_cases_spec.rb:522
# Multiple formatting properties not working with underline
```

**Implementation:**
```ruby
def build_run_styles(properties)
  return {} unless properties

  styles = {}

  # Ensure underline is preserved as string 'single', not boolean
  if properties.underline
    styles['text-decoration'] = 'underline'
    styles['text-underline'] = properties.underline.is_a?(String) ?
                                properties.underline : 'single'
  end

  styles['font-weight'] = 'bold' if properties.bold
  styles['font-style'] = 'italic' if properties.italic
  styles['color'] = properties.color if properties.color
  styles['font-size'] = "#{properties.size / 2}pt" if properties.size

  styles
end
```

**Tests to Pass:**
- [`mhtml_edge_cases_spec.rb:522`](spec/integration/mhtml_edge_cases_spec.rb:522)

**Expected Outcome:** 27 failures → 21 failures

---

## Sprint 3.3: Style System Enhancement (P2)

**Duration:** 1-2 sessions
**Priority:** P2 (Medium)
**Failures:** 21 → 17

### Feature 1: Style Name Normalization

**File:** [`lib/uniword/styles_configuration.rb`](lib/uniword/styles_configuration.rb)

**Current Issues:**
- [`style_spec.rb:119`](spec/compatibility/docx_gem/style_spec.rb:119) - Expected "Heading 1", got "Heading1"
- [`styles_integration_spec.rb:80`](spec/integration/styles_integration_spec.rb:80) - Custom style name change

**Implementation:**
```ruby
class StylesConfiguration
  # Normalize style names for consistency
  STYLE_NAME_NORMALIZATION = {
    'Heading1' => 'Heading 1',
    'Heading2' => 'Heading 2',
    'Heading3' => 'Heading 3',
    'Heading4' => 'Heading 4',
    'Heading5' => 'Heading 5',
    'Heading6' => 'Heading 6'
  }.freeze

  def normalize_style_name(name)
    STYLE_NAME_NORMALIZATION[name] || name
  end

  def add_style(style)
    # Preserve exact name as provided
    @styles[style.id] = style
    style
  end

  def find(name_or_id)
    # Try exact match first
    @styles[name_or_id] ||
    # Try normalized name
    @styles.values.find { |s| normalize_style_name(s.name) == normalize_style_name(name_or_id) }
  end
end
```

**Tests to Pass:**
- [`style_spec.rb:119`](spec/compatibility/docx_gem/style_spec.rb:119)
- [`styles_integration_spec.rb:80`](spec/integration/styles_integration_spec.rb:80)

### Feature 2: Round-Trip Accuracy

**Files:**
- [`lib/uniword/serialization/ooxml_serializer.rb`](lib/uniword/serialization/ooxml_serializer.rb)
- [`lib/uniword/serialization/ooxml_deserializer.rb`](lib/uniword/serialization/ooxml_deserializer.rb)

**Current Issues:**
- [`round_trip_spec.rb:78`](spec/integration/round_trip_spec.rb:78) - Missing formatting run
- [`round_trip_spec.rb:152`](spec/integration/round_trip_spec.rb:152) - Missing "Directive" prefix in table cell

**Implementation:**
```ruby
# Fix 1: Ensure empty runs are preserved
class OoxmlSerializer
  def build_run(element)
    # Always create run element, even if no text
    run_node = Nokogiri::XML::Node.new('w:r', @doc)

    # Add properties if present
    if element.respond_to?(:properties) && element.properties
      run_node << build_run_properties(element.properties)
    end

    # Add text element (even if empty to preserve structure)
    text_node = Nokogiri::XML::Node.new('w:t', @doc)
    text_node.content = element.text_element.to_s
    text_node['xml:space'] = 'preserve' if element.text_element.to_s.match?(/^\s|\s$/)
    run_node << text_node

    run_node
  end
end

# Fix 2: Preserve exact table cell text with whitespace
class OoxmlDeserializer
  def parse_text_element(node)
    # Preserve leading/trailing spaces
    node.text # Don't strip!
  end
end
```

**Tests to Pass:**
- [`round_trip_spec.rb:78`](spec/integration/round_trip_spec.rb:78)
- [`round_trip_spec.rb:152`](spec/integration/round_trip_spec.rb:152)

**Expected Outcome:** 21 failures → 17 failures

---

## Sprint 3.4: Page Setup API Implementation (P2)

**Duration:** 1 session
**Priority:** P2 (Medium)
**Failures:** 17 → 14

### Feature: Page Margins API

**File:** [`lib/uniword/section_properties.rb`](lib/uniword/section_properties.rb)

**Current Issues:**
- [`page_setup_spec.rb:8`](spec/compatibility/docx_js/layout/page_setup_spec.rb:8)
- [`page_setup_spec.rb:25`](spec/compatibility/docx_js/layout/page_setup_spec.rb:25)
- [`page_setup_spec.rb:318`](spec/compatibility/docx_js/layout/page_setup_spec.rb:318)

**Implementation:**
```ruby
class SectionProperties
  attribute :page_margin_top, :integer, default: -> { 1440 }    # 1 inch
  attribute :page_margin_bottom, :integer, default: -> { 1440 }
  attribute :page_margin_left, :integer, default: -> { 1440 }
  attribute :page_margin_right, :integer, default: -> { 1440 }
  attribute :page_margin_header, :integer, default: -> { 720 }  # 0.5 inch
  attribute :page_margin_footer, :integer, default: -> { 720 }
  attribute :page_margin_gutter, :integer, default: -> { 0 }

  def page_margins(top: nil, bottom: nil, left: nil, right: nil,
                   header: nil, footer: nil, gutter: nil)
    @page_margin_top = top if top
    @page_margin_bottom = bottom if bottom
    @page_margin_left = left if left
    @page_margin_right = right if right
    @page_margin_header = header if header
    @page_margin_footer = footer if footer
    @page_margin_gutter = gutter if gutter
    self
  end
end

class Section
  def page_margins(**opts)
    properties.page_margins(**opts)
    self
  end
end
```

**Serialization:**
```ruby
# In OoxmlSerializer
def build_page_margins(props)
  return nil unless props

  margins = Nokogiri::XML::Node.new('w:pgMar', @doc)
  margins['w:top'] = props.page_margin_top if props.page_margin_top
  margins['w:bottom'] = props.page_margin_bottom if props.page_margin_bottom
  margins['w:left'] = props.page_margin_left if props.page_margin_left
  margins['w:right'] = props.page_margin_right if props.page_margin_right
  margins['w:header'] = props.page_margin_header if props.page_margin_header
  margins['w:footer'] = props.page_margin_footer if props.page_margin_footer
  margins['w:gutter'] = props.page_margin_gutter if props.page_margin_gutter
  margins
end
```

**Tests to Pass:**
- [`page_setup_spec.rb:8`](spec/compatibility/docx_js/layout/page_setup_spec.rb:8)
- [`page_setup_spec.rb:25`](spec/compatibility/docx_js/layout/page_setup_spec.rb:25)
- [`page_setup_spec.rb:318`](spec/compatibility/docx_js/layout/page_setup_spec.rb:318)

**Expected Outcome:** 17 failures → 14 failures

---

## Sprint 3.5: API Compatibility Polish (P2-P3)

**Duration:** 1 session
**Priority:** P3 (Low)
**Failures:** 14 → ~10

### Remaining Issues to Address

#### 1. Error Type Standardization (2 failures)

**Files:**
- [`edge_cases_spec.rb:313`](spec/integration/edge_cases_spec.rb:313)
- [`mhtml_edge_cases_spec.rb:472`](spec/integration/mhtml_edge_cases_spec.rb:472)

**Fix:** Tests expect `ArgumentError` but we raise `FileNotFoundError`. Update tests to expect correct error.

#### 2. API Method Implementations (3 failures)

**Files:**
- [`docx_gem_api_spec.rb:257`](spec/compatibility/docx_gem_api_spec.rb:257) - Row copy
- [`docx_gem_api_spec.rb:146`](spec/compatibility/docx_gem_api_spec.rb:146) - Run substitution
- [`docx_gem_api_spec.rb:93`](spec/compatibility/docx_gem_api_spec.rb:93) - Paragraph remove

**Implementation:**
```ruby
class TableRow
  def copy
    # Deep copy the row
    Marshal.load(Marshal.dump(self))
  end
end

class Run
  def substitute(pattern, replacement)
    @text_element = @text_element.to_s.gsub(pattern, replacement)
    self
  end
end

class Paragraph
  def remove!
    # Remove from parent document/table cell
    parent.elements.delete(self) if parent.respond_to?(:elements)
    self
  end
end
```

#### 3. Minor Fixes (2 failures)

- XPath optimization performance tuning
- UTF-8 encoding fix
- TableValidator registration

**Expected Outcome:** 14 failures → ~10 failures

---

## Sprint 3 Implementation Sequence

### Week 1: Core Fixes

```
Day 1: Sprint 3.1 - Core API Fixes (P1)
├─ Table border API
├─ Run properties inheritance
├─ Image inline positioning
└─ CSS number formatting
   → 31 failures → 27 failures

Day 2-3: Sprint 3.2 - MHTML Format (P2)
├─ HTML paragraph import
├─ Empty element preservation
├─ HTML entity decoding
└─ CSS multi-property formatting
   → 27 failures → 21 failures
```

### Week 2: Polish

```
Day 4: Sprint 3.3 - Style System (P2)
├─ Style name normalization
└─ Round-trip accuracy
   → 21 failures → 17 failures

Day 5: Sprint 3.4 - Page Setup (P2)
└─ Page margins API
   → 17 failures → 14 failures

Day 6: Sprint 3.5 - API Polish (P3)
├─ Error type fixes
├─ API method implementations
└─ Minor fixes
   → 14 failures → ~10 failures
```

---

## Testing Strategy

### Unit Tests

For each feature:
1. **Add specific unit tests** for the new functionality
2. **Verify existing tests** pass with changes
3. **Run related integration tests** to ensure no regressions

### Integration Tests

After each sprint phase:
1. **Run full test suite** to verify no new regressions
2. **Monitor pass rate** - should improve with each phase
3. **Check performance** - ensure no degradation

### Validation Checkpoints

- ✅ After Sprint 3.1: P1 bugs cleared
- ✅ After Sprint 3.2: MHTML format working well
- ✅ After Sprint 3.3: Styles polished
- ✅ After Sprint 3.4: Page setup complete
- ✅ After Sprint 3.5: Ready for Sprint 4

---

## Risk Assessment

### High Risk Items

1. **Image Regression Fixes (Sprint 2.5)**
   - Risk: Could introduce new issues
   - Mitigation: Comprehensive testing before Sprint 3

2. **Empty Element Preservation**
   - Risk: May affect existing serialization
   - Mitigation: Careful testing of round-trip scenarios

3. **Style Name Changes**
   - Risk: Could break existing code
   - Mitigation: Backward compatibility with both formats

### Medium Risk Items

1. **Page Margins API**
   - Risk: Large API surface area
   - Mitigation: Start with basic implementation

2. **HTML Entity Decoding**
   - Risk: Character encoding issues
   - Mitigation: Use UTF-8 consistently

---

## Success Criteria

### Sprint 3.1 Complete When:
- ✅ All 4 P1 bugs fixed
- ✅ Test suite shows 27 or fewer failures
- ✅ No new regressions introduced
- ✅ Performance maintained

### Sprint 3.2 Complete When:
- ✅ MHTML format handles all edge cases
- ✅ Empty elements preserved correctly
- ✅ HTML entities decoded properly
- ✅ Test suite shows 21 or fewer failures

### Sprint 3.3 Complete When:
- ✅ Style names normalized consistently
- ✅ Round-trip preserves all formatting
- ✅ Test suite shows 17 or fewer failures

### Sprint 3.4 Complete When:
- ✅ Page margins API implemented
- ✅ Zero margins supported
- ✅ Test suite shows 14 or fewer failures

### Sprint 3.5 Complete When:
- ✅ API compatibility improved
- ✅ Error handling standardized
- ✅ Test suite shows <15 failures
- ✅ Ready for Sprint 4 (advanced features)

---

## Post-Sprint 3 Status

### Expected State

```
Total Examples:    2094
Passed:           ~1950
Failed:            ~10-14
Pending:           ~228
Pass Rate:        93%+
```

### Remaining Work (Sprint 4+)

**Major Features Still Pending:**
- Headers/footers advanced features (20 tests)
- Complex fields (15 tests)
- Advanced image features (25 tests)
- VML/DrawingML (10 tests)
- Section breaks (5 tests)
- Advanced formatting (30 tests)
- Other pending features (123 tests)

**Estimated Timeline:**
- Sprint 4: Headers/footers completion
- Sprint 5: Complex fields & images
- Sprint 6: VML/DrawingML support
- Sprint 7-8: Final polish & remaining features

---

## Dependencies and Prerequisites

### External Dependencies

None - all work can be done with existing gems.

### Internal Dependencies

1. **Sprint 2.5 MUST complete first**
   - Image regressions block Sprint 3
   - Cannot proceed until 13 image failures resolved

2. **Test infrastructure stable**
   - Test suite running reliably
   - No test framework issues

3. **Code review process**
   - Each feature should be reviewed
   - Regressions caught early

---

## Rollback Plan

If Sprint 3 introduces critical regressions:

1. **Revert to Sprint 2.5 baseline**
2. **Identify problematic changes**
3. **Fix issues in isolation**
4. **Re-integrate carefully**

---

## Next Steps

### Immediate (Sprint 2.5)

1. Create Sprint 2.5 emergency fix plan
2. Fix 13 image regressions
3. Validate test suite returns to 31 failures
4. Commit and document fixes

### Then (Sprint 3.1)

1. Review this plan
2. Start with P1 core API fixes
3. Validate each fix individually
4. Monitor for regressions

---

## Appendix: Complete Failure List

### P0 - Image Regressions (13) - Sprint 2.5

**Text Extraction (7):**
1. `real_world_documents_spec.rb:97` - Content preservation
2. `real_world_documents_spec.rb:36` - Text extraction
3. `real_world_documents_spec.rb:194` - Memory test
4. `real_world_documents_spec.rb:215` - Performance test
5. `real_world_documents_spec.rb:234` - Error resilience

**Serialization (3):**
6. `real_world_documents_spec.rb:120` - Structure round-trip
7. `real_world_documents_spec.rb:140` - Style round-trip
8. `real_world_documents_spec.rb:176` - Write performance

**Element Type (3):**
9. `comprehensive_validation_spec.rb:345` - HTML with images
10. `mhtml_compatibility_spec.rb:198` - Image encoding
11. `mhtml_compatibility_spec.rb:212` - Content-Location

**Plus 2 additional from MHTML:**
12. `mhtml_compatibility_spec.rb:147` - HTML structure tags
13. `mhtml_compatibility_spec.rb:69` - MIME termination

### P1 - Core Bugs (4) - Sprint 3.1

1. `comprehensive_validation_spec.rb:238` - Table border API
2. `run_spec.rb:349` - Run properties inheritance
3. `images_spec.rb:441` - Image inline property
4. `html_serializer_spec.rb:147` - CSS number formatting

### P2 - Enhancements (19) - Sprint 3.2-3.5

**MHTML Format (6):**
1. `mhtml_conversion_spec.rb:18` - HTML paragraph import
2. `mhtml_edge_cases_spec.rb:39` - Empty runs
3. `mhtml_edge_cases_spec.rb:61` - Empty cells
4. `mhtml_edge_cases_spec.rb:382` - Whitespace-only
5. `mhtml_edge_cases_spec.rb:131` - HTML entities
6. `mhtml_edge_cases_spec.rb:522` - CSS multi-property

**Style System (4):**
7. `style_spec.rb:119` - Style name normalization
8. `styles_integration_spec.rb:80` - Custom style names
9. `round_trip_spec.rb:78` - Round-trip formatting
10. `round_trip_spec.rb:152` - Table cell content

**Page Setup (3):**
11. `page_setup_spec.rb:8` - Zero margins
12. `page_setup_spec.rb:25` - Zero margin content
13. `page_setup_spec.rb:318` - Page setup integration

**Edge Cases (3):**
14. `edge_cases_spec.rb:313` - Error type
15. `mhtml_edge_cases_spec.rb:472` - Error type
16. `compatibility_spec.rb:386` - UTF-8 encoding

**API Compatibility (3):**
17. `docx_gem_api_spec.rb:257` - Row copy
18. `docx_gem_api_spec.rb:146` - Run substitution
19. `docx_gem_api_spec.rb:93` - Paragraph remove

**Plus 4 pending-fixed tests:**
20-23. `real_world_documents_spec.rb:252,259,265,271` - Update test status

**Performance/Other (2):**
24. `benchmark_suite_spec.rb:266` - XPath optimization
25. `table_validator_spec.rb:150` - Validator registration

---

## Conclusion

Sprint 3 is well-defined and ready to execute after Sprint 2.5 completes the emergency image regression fixes.

**Key Deliverables:**
- 17 fewer failures (48% reduction)
- 93%+ pass rate achievement
- Complete MHTML format support
- Polished style system
- Working page setup API

**Timeline:** 5-6 sessions total (assuming 1 session = ~2-3 hours)

**Next Action:** Execute Sprint 2.5 emergency fix plan
# Feature Gap Analysis - Metanorma ISO Samples

Based on testing 8 representative files from the mn-samples-iso collection.

## Successfully Supported Features

### ✅ Core Infrastructure
- [x] MHTML format detection
- [x] MIME multipart parsing
- [x] HTML/CSS parsing with Nokogiri
- [x] Document object creation
- [x] Error handling and stability
- [x] Large file handling (up to 12MB tested)

### ✅ Style System
- [x] CSS style extraction from `<head>`
- [x] MSO class name mapping (MsoNormal, MsoHeading, etc.)
- [x] Inline style parsing
- [x] StylesConfiguration population
- [x] Character and paragraph style differentiation

### ✅ Text Formatting
- [x] Bold text (`<b>`, `<strong>`)
- [x] Italic text (`<i>`, `<em>`)
- [x] Underline text (`<u>`)
- [x] Font properties (family, size, color)
- [x] Text runs with properties

### ✅ Basic Elements
- [x] Paragraph creation
- [x] Run creation with text
- [x] Paragraph properties (alignment, indentation, spacing)
- [x] Run properties (bold, italic, underline, color, font)

## Missing Features (Priority Order)

### 🔴 Critical - Blockers for v1.1

#### 1. **Recursive Div Processing**
**Found in**: 100% of samples
**Severity**: BLOCKER
**Current Status**: Broken

**Description**:
Metanorma MHTML files wrap content in `<div class="WordSection1">`, `<div class="WordSection2">`, etc. The current parser treats these divs as paragraphs and only extracts their immediate text, ignoring all nested content.

**OOXML Elements Involved**:
- HTML: `<div class="WordSection*">`
- Must be treated as containers, not content

**Impact**:
- Only ~8% of paragraphs extracted
- Zero tables extracted
- Document structure lost
- Cannot recreate documents

**Implementation Complexity**: **LOW** (0.5 day)
- Add section div detection in `parse_block_element`
- Recursively process children when div contains block elements
- Only treat div as paragraph when it contains inline content only

**Proposed Fix**:
```ruby
def parse_block_element(node)
  case node.name.downcase
  when 'div'
    # Check if this is a section container
    if node['class']&.match?(/WordSection|Section/)
      # Recursively process children
      elements = []
      node.children.each do |child|
        next unless child.element?
        elem = parse_block_element(child)
        elements << elem if elem
      end
      return elements
    else
      # Regular div - treat as paragraph
      parse_paragraph(node)
    end
  # ... rest of cases
end
```

---

#### 2. **Table Extraction from Sections**
**Found in**: 50%+ of samples (6 tables in rice-2016/document-en.doc)
**Severity**: BLOCKER
**Current Status**: Broken (0% success rate)

**Description**:
Tables exist in the HTML but are never found because they're nested inside section divs that aren't being recursively processed.

**OOXML Elements Involved**:
- HTML: `<table>`, `<tr>`, `<td>`, `<th>`
- Currently supported but unreachable

**Impact**:
- Cannot extract tabular data
- ISO standards heavily use tables
- Format conversion incomplete

**Implementation Complexity**: **LOW** (included in fix #1)
- Once recursive div processing works, existing table parser will work
- May need to enhance table property extraction

**Dependencies**: Requires fix #1 (recursive div processing)

---

### 🟡 High Priority - Important for v1.1/v1.2

#### 3. **Section Structure Preservation**
**Found in**: 100% of samples
**Severity**: HIGH
**Current Status**: Not implemented

**Description**:
WordSection divs represent document sections (often corresponding to pages or major breaks). These should map to Uniword `Section` objects to preserve document structure.

**OOXML Elements Involved**:
- HTML: `<div class="WordSection1">`, `<div class="WordSection2">`, etc.
- OOXML: `<w:sectPr>` (section properties)

**Impact**:
- Page layout lost
- Headers/footers can't be associated with sections
- Page breaks not preserved
- Multi-section documents flatten to single section

**Implementation Complexity**: **MEDIUM** (1 day)
- Detect WordSection divs
- Create Section objects for each
- Associate paragraphs/tables with correct section
- Extract section properties if present

**Implementation Approach**:
```ruby
def parse_html(html)
  # ... existing setup ...

  body.css('div[class^="WordSection"]').each do |section_div|
    section = Section.new
    # Parse section content
    section_div.children.each do |node|
      # ... parse and add to section
    end
    document.add_section(section)
  end
end
```

---

#### 4. **List/Numbering Support**
**Found in**: Unknown (need deeper analysis)
**Severity**: HIGH
**Current Status**: Partially implemented

**Description**:
Lists are converted to paragraphs with 'ListParagraph' style, but proper numbering definitions are not extracted. This means list hierarchy and numbering format are lost.

**OOXML Elements Involved**:
- HTML: `<ul>`, `<ol>`, `<li>`
- CSS: `mso-list` styles with numbering information
- OOXML: `<w:numPr>` (numbering properties)

**Impact**:
- List structure simplified
- Numbering format lost (1, 2, 3 vs. a, b, c vs. i, ii, iii)
- Nested list levels flattened
- Custom numbering definitions lost

**Implementation Complexity**: **HIGH** (2-3 days)
- Parse `mso-list` CSS properties
- Extract numbering definitions from styles
- Create NumberingConfiguration entries
- Link paragraphs to numbering instances

**Deferred to**: v1.2 (not blocking basic functionality)

---

#### 5. **Image Extraction and Embedding**
**Found in**: Unknown (likely in many samples)
**Severity**: MEDIUM
**Current Status**: Placeholder only

**Description**:
Images are detected and replaced with placeholder text like "[Image: filename.png]". Actual image data from `cid:` references is not extracted or embedded in the document model.

**OOXML Elements Involved**:
- HTML: `<img src="cid:filename.png">`
- MIME: Image parts in multipart message
- OOXML: `<w:drawing>`, `<w:pict>`, relationships

**Impact**:
- Visual content lost
- Documents with diagrams/charts incomplete
- Cannot round-trip documents with images

**Implementation Complexity**: **MEDIUM** (1.5 days)
- Extract image data from MIME parts
- Create Image objects in document model
- Associate images with paragraphs/runs
- Handle various image formats (PNG, JPG, SVG)

**Implementation Approach**:
1. Store image data from MIME parser
2. When `<img cid:>` found, look up in image data
3. Create `Uniword::Image` object
4. Add to paragraph as drawing run

**Deferred to**: v1.2

---

### 🟢 Medium Priority - Nice to Have

#### 6. **Header/Footer Extraction**
**Found in**: Likely in most samples
**Severity**: MEDIUM
**Current Status**: Not implemented

**Description**:
Headers and footers are likely embedded in the MHTML but not extracted. Metanorma documents typically have standard ISO headers/footers.

**OOXML Elements Involved**:
- HTML: Typically in separate divs or at section boundaries
- OOXML: `<w:hdr>`, `<w:ftr>`, header/footer parts

**Impact**:
- Page headers lost (page numbers, document titles)
- Footers lost (copyright notices, etc.)
- Professional formatting incomplete

**Implementation Complexity**: **MEDIUM** (1-2 days)
- Identify header/footer markers in HTML
- Extract to Header/Footer objects
- Associate with sections
- Handle different header types (first, odd, even)

**Deferred to**: v1.3

---

#### 7. **Footnote/Endnote Support**
**Found in**: Unknown
**Severity**: LOW
**Current Status**: Not implemented

**Description**:
Footnotes and endnotes may be present in academic/standards documents. Currently not extracted.

**OOXML Elements Involved**:
- HTML: Typically `<a>` tags with special attributes
- OOXML: `<w:footnote>`, `<w:endnote>`, footnotes.xml

**Impact**:
- Reference notes lost
- Citations incomplete
- Academic rigor diminished

**Implementation Complexity**: **MEDIUM** (1.5 days)
- Identify footnote/endnote markers
- Extract note content
- Create Footnote/Endnote objects
- Link to anchor points in text

**Deferred to**: v1.3

---

#### 8. **Bookmark/Anchor Handling**
**Found in**: Confirmed present (e.g., `<a name="boilerplate-copyright-destination">`)
**Severity**: LOW
**Current Status**: Not implemented

**Description**:
HTML anchors and bookmarks are present but ignored. These mark important points for cross-references and navigation.

**OOXML Elements Involved**:
- HTML: `<a name="...">`
- OOXML: `<w:bookmarkStart>`, `<w:bookmarkEnd>`

**Impact**:
- Internal links may break
- Cross-references lost
- Document navigation impaired

**Implementation Complexity**: **LOW** (0.5 day)
- Extract `<a name>` elements
- Create Bookmark objects
- Associate with paragraph positions

**Deferred to**: v1.3

---

#### 9. **Field/Dynamic Content**
**Found in**: Unknown
**Severity**: LOW
**Current Status**: Not implemented

**Description**:
Word fields (page numbers, dates, TOC) may be present. Currently would be rendered as static text.

**OOXML Elements Involved**:
- HTML: May be in special spans or JavaScript
- OOXML: `<w:fldChar>`, `<w:instrText>`

**Impact**:
- Dynamic content becomes static
- Page numbers don't update
- TOC doesn't regenerate

**Implementation Complexity**: **HIGH** (2-3 days)
- Identify field markers in HTML
- Parse field instructions
- Create Field objects
- Handle field types (page, date, TOC, etc.)

**Deferred to**: v2.0

---

#### 10. **Comment/Track Changes**
**Found in**: Unknown
**Severity**: LOW
**Current Status**: Not implemented

**Description**:
Collaborative features like comments and tracked changes may be present in review-stage documents.

**OOXML Elements Involved**:
- HTML: May be in special divs/spans
- OOXML: `<w:comment>`, `<w:ins>`, `<w:del>`

**Impact**:
- Editorial comments lost
- Revision history lost
- Collaboration features unavailable

**Implementation Complexity**: **HIGH** (3+ days)
- Complex feature requiring special handling
- Low priority for standards documents

**Deferred to**: v2.0+

---

## Feature Priority Matrix

### Must-Have for v1.1 (BLOCKERS)
1. ✅ Recursive div processing ← **FIX THIS FIRST**
2. ✅ Table extraction ← **Automatically fixed by #1**

### Should-Have for v1.1 or v1.2
3. Section structure preservation
4. List/numbering support
5. Image extraction

### Nice-to-Have for v1.2+
6. Header/footer extraction
7. Footnote/endnote support
8. Bookmark handling

### Future (v1.3+)
9. Field/dynamic content
10. Comment/track changes

## Recommendations for v1.1

### Immediate Actions (Week 1)
1. **Fix recursive div processing** (0.5 day)
   - Highest impact
   - Lowest complexity
   - Unlocks 92% more content

2. **Verify table extraction works** (0.5 day)
   - Should work automatically after fix #1
   - Add comprehensive tests
   - Test complex table structures

3. **Add section structure support** (1 day)
   - Preserve document organization
   - Enable future header/footer work
   - Important for multi-page documents

### Testing Strategy
1. Create fixtures from mn-samples-iso
2. Test actual paragraph counts match expected
3. Test table extraction completeness
4. Test section structure preservation
5. Add performance benchmarks (large files)

### Success Criteria for v1.1
- ✅ Extract ≥95% of paragraphs from sample files
- ✅ Extract 100% of tables from sample files
- ✅ Preserve section structure
- ✅ No regressions in existing features
- ✅ All 44 sample files parse without errors

## Long-Term Roadmap

### v1.1 (Current - Critical Fixes)
- Fix recursive div processing
- Table extraction
- Section structure

### v1.2 (Enhanced Reading)
- List/numbering support
- Image extraction and embedding
- Improved style fidelity

### v1.3 (Professional Features)
- Header/footer support
- Footnote/endnote support
- Bookmark handling
- Enhanced table features

### v2.0 (Advanced Features)
- Field/dynamic content
- Comment support
- Track changes
- Form controls
- Content controls

## Conclusion

The critical finding is that **one architectural bug** is responsible for 92% of missing content:
- Fix recursive div processing → Unlocks paragraphs
- Fix recursive div processing → Unlocks tables
- Fix recursive div processing → Enables section structure

**Estimated total effort for v1.1 critical path**: 2-3 days
- Fix div processing: 0.5 day
- Testing and verification: 0.5 day
- Section structure: 1 day
- Documentation and polish: 0.5 day

This is a **high-impact, achievable goal** for the v1.1 release.
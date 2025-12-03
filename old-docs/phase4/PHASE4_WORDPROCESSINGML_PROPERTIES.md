# Phase 4: Wordprocessingml Property Completeness

## Overview

**Goal**: Implement complete Wordprocessingml properties for tables, cells, paragraphs, runs, and structured document tags (SDTs).

**Scope**: ALL documents (StyleSets, Themes, Glossary, regular documents)

**Status**: Epic created December 1, 2024

**Estimated Time**: 4-6 hours

**Priority**: Medium (Glossary infrastructure is complete; this enhances all document types)

## Background

During Phase 3 Week 3 (Glossary implementation), we discovered that many Wordprocessingml properties are incomplete or missing. While the Glossary infrastructure is structurally complete and working correctly, several document element tests fail due to these property gaps.

**Key Finding**: These are NOT Glossary issues - they are Wordprocessingml enhancement opportunities that affect ALL document types.

## Missing Properties

### 1. Table Properties (tblPr content)

**Current State**: `<tblPr>` serializes as empty element

**Missing Elements**:
- `<tblW>` - Table width (w, type attributes)
- `<shd>` - Table shading with `themeFill` attribute
- `<tblCellMar>` - Table cell margins (top, bottom, left, right)
- `<tblLook>` - Table conditional formatting (firstRow, lastRow, firstColumn, etc.)

**Example**:
```xml
<!-- Expected -->
<tblPr>
  <tblW w="5000" type="pct"/>
  <shd val="clear" color="auto" fill="5B9BD5" themeFill="accent1"/>
  <tblCellMar>
    <top w="0" type="dxa"/>
    <left w="108" type="dxa"/>
    <bottom w="0" type="dxa"/>
    <right w="108" type="dxa"/>
  </tblCellMar>
  <tblLook val="04A0" firstRow="1" lastRow="0" firstColumn="1" lastColumn="0" noHBand="0" noVBand="1"/>
</tblPr>

<!-- Current (incomplete) -->
<tblPr/>
```

**Files to Modify**:
- `lib/uniword/properties/table_properties.rb` - Add table width, shading, cell margins, look
- `lib/uniword/properties/table_width.rb` - New file
- `lib/uniword/properties/table_cell_margin.rb` - New file
- `lib/uniword/properties/table_look.rb` - New file

**Estimated Time**: 2 hours

### 2. Cell Properties (tcPr content)

**Current State**: Incomplete cell properties

**Missing Elements**:
- `<tcW>` - Cell width (w, type attributes)
- `<vAlign>` - Vertical alignment (val attribute: top, center, bottom)
- Enhanced `<shd>` with `themeFill` attribute

**Example**:
```xml
<!-- Expected -->
<tcPr>
  <tcW w="2500" type="pct"/>
  <shd val="clear" color="auto" fill="5B9BD5" themeFill="accent1"/>
  <vAlign val="center"/>
</tcPr>

<!-- Current (incomplete) -->
<tcPr>
  <shd val="clear" color="auto" fill="5B9BD5"/>
</tcPr>
```

**Files to Modify**:
- `lib/uniword/properties/table_cell_properties.rb` - Add cell width, vertical align
- `lib/uniword/properties/cell_width.rb` - New file
- `lib/uniword/properties/cell_vertical_align.rb` - New file
- `lib/uniword/shading.rb` - Enhance with themeFill attribute

**Estimated Time**: 1 hour

### 3. Paragraph Properties (rsid attributes)

**Current State**: Paragraph elements lack revision identifiers

**Missing Attributes**:
- `rsidR` - Revision ID for run
- `rsidRDefault` - Default revision ID
- `rsidP` - Revision ID for paragraph properties

**Example**:
```xml
<!-- Expected -->
<p rsidR="00B10ACF" rsidRDefault="00B10ACF" rsidP="00FE3863">

<!-- Current -->
<p>
```

**Files to Modify**:
- `lib/uniword/paragraph.rb` - Add rsid attributes to xml mapping

**Estimated Time**: 30 minutes

### 4. Run Properties (rPr content)

**Current State**: Many run properties missing

**Missing Elements**:
- `<caps>` - All capitals
- `<noProof>` - No spell/grammar check
- Complete `<color>` with `themeColor` attribute
- Complete `<sz>` and `<szCs>` for both regular and complex script sizes
- `<bCs>`, `<iCs>` - Bold/italic for complex scripts

**Example**:
```xml
<!-- Expected -->
<rPr>
  <caps/>
  <color val="FFFFFF" themeColor="background1"/>
  <sz val="18"/>
  <szCs val="18"/>
  <noProof/>
</rPr>

<!-- Current (incomplete) -->
<rPr/>
```

**Files to Modify**:
- `lib/uniword/properties/run_properties.rb` - Add caps, noProof, complex script flags
- `lib/uniword/properties/color_value.rb` - Enhance with themeColor
- `lib/uniword/properties/font_size.rb` - Ensure both sz and szCs

**Estimated Time**: 1 hour

### 5. Structured Document Tag Properties (sdtPr content)

**Current State**: SDT properties almost entirely missing

**Missing Elements**:
- `<id>` - Unique tag identifier
- `<alias>` - Display name
- `<tag>` - Developer tag value
- `<showingPlcHdr>` - Showing placeholder header flag
- `<dataBinding>` - Data binding configuration
- `<appearance>` - Visual appearance (hidden, tags, boundingBox)
- `<text>` - Text box control
- `<docPartObj>` - Building block object reference
- `<placeholder>` - Placeholder configuration
- `<temporary>` - Temporary SDT flag

**Example**:
```xml
<!-- Expected -->
<sdtPr>
  <rPr>...</rPr>
  <alias val="Title"/>
  <tag val=""/>
  <id val="1666976605"/>
  <showingPlcHdr/>
  <dataBinding xpath="..." storeItemID="..."/>
  <appearance val="hidden"/>
  <text/>
</sdtPr>

<!-- Current -->
<sdtPr/>
```

**Files to Create**:
- `lib/uniword/structured_document_tag_properties.rb` - Complete SDT properties
- `lib/uniword/sdt/` (new directory for SDT-specific classes)
  - `alias.rb`, `tag.rb`, `id.rb`, `appearance.rb`, `text.rb`
  - `doc_part_object.rb`, `placeholder.rb`, `data_binding.rb`

**Estimated Time**: 2 hours

## Implementation Strategy

### Phase 1: Property Analysis (30 minutes)
1. Review all 8 failing Glossary tests
2. Extract exact XML differences
3. Prioritize by impact (number of tests affected)
4. Document property relationships

### Phase 2: Table Properties (2 hours)
1. Implement TableWidth class
2. Enhance Shading with themeFill
3. Implement TableCellMargin class
4. Implement TableLook class
5. Update TableProperties to include all
6. Test with Footers.dotx, Tables.dotx, Watermarks.dotx

### Phase 3: Cell Properties (1 hour)
1. Implement CellWidth class
2. Implement CellVerticalAlign class
3. Update TableCellProperties
4. Test cell serialization

### Phase 4: Paragraph rsid attributes (30 minutes)
1. Add rsid attributes to Paragraph xml mapping
2. Ensure attributes persist through serialization
3. Test with all documents

### Phase 5: Run Properties (1 hour)
1. Add Caps boolean flag
2. Add NoProof boolean flag
3. Enhance Color with themeColor
4. Add complex script size handling
5. Test run serialization

### Phase 6: SDT Properties (2 hours)
1. Create SDT properties directory structure
2. Implement all SDT property classes
3. Update StructuredDocumentTag class
4. Test with Bibliographies.dotx, Cover Pages.dotx, Table of Contents.dotx

### Phase 7: Integration Testing (1 hour)
1. Run all document element tests (target: 16/16)
2. Run baseline tests (must maintain: 342/342)
3. Verify zero regressions
4. Update documentation

## Success Criteria

### Primary Goal: 16/16 Document Element Tests Passing
- Content Types: 8/8 ✅ (already passing)
- Glossary Round-Trip: 8/8 ⏳ (target)

### Secondary Goal: Zero Regressions
- StyleSet tests: 168/168 ✅ (must maintain)
- Theme tests: 174/174 ✅ (must maintain)
- Total baseline: 342/342 ✅ (must maintain)

### Tertiary Goal: Architecture Quality
- ✅ Pattern 0 compliance (attributes before xml)
- ✅ MECE (clear separation of concerns)
- ✅ Model-driven (no raw XML)
- ✅ Proper namespace usage
- ✅ Type safety throughout

## Testing Plan

### Unit Tests
Create focused tests for each new property:
```ruby
RSpec.describe Uniword::Properties::TableWidth do
  it 'serializes with w and type attributes' do
    tw = Uniword::Properties::TableWidth.new(w: 5000, type: 'pct')
    xml = tw.to_xml
    expect(xml).to include('w="5000"')
    expect(xml).to include('type="pct"')
  end
end
```

### Integration Tests
Ensure properties work in complete documents:
```ruby
RSpec.describe 'Table properties integration' do
  it 'preserves table width in round-trip' do
    doc = Uniword::Document.open('references/word-package/document-elements/Tables.dotx')
    original_xml = doc.to_xml
    roundtrip = Uniword::Document.from_xml(original_xml)
    roundtrip_xml = roundtrip.to_xml
    expect(roundtrip_xml).to be_xml_equivalent_to(original_xml)
  end
end
```

### Regression Tests
Ensure no impact on existing functionality:
```bash
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb
# Must pass: 168/168

bundle exec rspec spec/uniword/theme_roundtrip_spec.rb
# Must pass: 174/174
```

## Impact Analysis

### Documents Affected
**ALL** documents benefit from complete property support:

1. **StyleSets** (24 files)
   - Better table style support
   - Enhanced cell formatting
   - Improved text effects

2. **Themes** (29 files)
   - Better integration with table colors
   - Theme color preservation in shading

3. **Glossary/Building Blocks** (8 files)
   - Complete TOC support
   - Full bibliography formatting
   - Cover page SDT support

4. **Regular Documents**
   - Professional table formatting
   - Complete SDT field support
   - Better revision tracking (rsid)

### User Benefits
- ✅ Professional table layouts with consistent formatting
- ✅ Structured document tags work correctly (forms, fields)
- ✅ Complete round-trip for complex documents
- ✅ Better theme integration in table styles
- ✅ Revision tracking preserved

## Risks and Mitigation

### Risk 1: Regression in Existing Tests
**Probability**: Medium
**Impact**: High (breaks 342 passing tests)
**Mitigation**:
- Test after each property implementation
- Keep git commits granular
- Run baseline tests frequently
- Use feature branches

### Risk 2: Property Interdependencies
**Probability**: Medium
**Impact**: Medium (complex debugging)
**Mitigation**:
- Document property relationships
- Implement in logical groups
- Test integration points
- Use MECE separation

### Risk 3: Time Overrun
**Probability**: Low
**Impact**: Low (non-blocking)
**Mitigation**:
- Properties are independent
- Can implement incrementally
- Each property delivers value
- No hard deadline

### Risk 4: Incomplete OOXML Spec Understanding
**Probability**: Low
**Impact**: Medium (incorrect implementation)
**Mitigation**:
- Use actual .dotx files as reference
- Compare with Microsoft-generated XML
- Review ISO 29500 specification
- Test with Word application

## Dependencies

### Technical Dependencies
- lutaml-model ~> 0.7 (already in use)
- canon gem (for XML comparison testing)
- Reference .dotx files (already available)

### Knowledge Dependencies
- OOXML property specifications
- WordProcessingML namespace conventions
- Table formatting model
- SDT control types

### Timeline Dependencies
- No blocking dependencies
- Can start immediately after Phase 3 Week 3
- Independent of other roadmap items

## Future Enhancements (Post-Phase 4)

After complete property support, consider:

1. **Style Inheritance System**
   - Proper style cascading
   - Default style handling
   - Style override logic

2. **Theme Integration**
   - Theme color mapping in properties
   - Font theme application
   - Effect preservation

3. **Property Validation**
   - Value range checking
   - Enumeration validation
   - Cross-property consistency

4. **Property Builders**
   - Fluent API for complex properties
   - Default property sets
   - Property presets

## Documentation Updates

After Phase 4 completion, update:

1. **README.adoc**
   - Add complete property examples
   - Document table formatting
   - Explain SDT usage

2. **Architecture Documentation**
   - Document property hierarchy
   - Explain property inheritance
   - Show property relationships

3. **API Documentation**
   - YARD docs for all property classes
   - Usage examples for each property
   - Property value constraints

## Timeline

**Optimistic** (4 hours):
- Property analysis: 30 min
- Table properties: 1.5 hours
- Cell properties: 45 min
- Paragraph rsid: 20 min
- Run properties: 45 min
- SDT properties: 1.5 hours
- Integration testing: 30 min

**Realistic** (5 hours):
- Property analysis: 45 min
- Table properties: 2 hours
- Cell properties: 1 hour
- Paragraph rsid: 30 min
- Run properties: 1 hour
- SDT properties: 2 hours
- Integration testing: 45 min

**Pessimistic** (6 hours):
- Property analysis: 1 hour
- Table properties: 2.5 hours
- Cell properties: 1.5 hours
- Paragraph rsid: 45 min
- Run properties: 1.5 hours
- SDT properties: 2.5 hours
- Integration testing: 1 hour

## Conclusion

Phase 4 represents a natural evolution of Uniword's Wordprocessingml support. While the Glossary infrastructure is complete and functional, these property enhancements will benefit ALL document types and bring Uniword closer to 100% OOXML specification coverage.

**Recommendation**: Proceed with Phase 4 after celebrating the Glossary success. The Glossary phase demonstrated our architectural approach works perfectly - Phase 4 will apply the same proven patterns to complete the property layer.

**Priority**: Medium - Not blocking Glossary usage, but valuable for comprehensive document support.

**Status**: Ready to start - all groundwork laid during Glossary implementation.
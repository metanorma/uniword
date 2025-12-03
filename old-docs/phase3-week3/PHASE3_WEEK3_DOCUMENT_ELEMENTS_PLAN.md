# Phase 3 Week 3: Document Elements Round-Trip Plan

## Overview

**Current State**: 53/61 files (87%)
- StyleSets: 24/24 (100%) ✅
- Themes: 29/29 (100%) ✅  
- Document Elements: 0/8 (0%)

**Target**: 61/61 files (100%)

**Timeline**: 5 days (December 2-6, 2024)

## Objective

Achieve 100% round-trip fidelity for all 8 document element reference files in `references/word-package/document-elements/`.

## Document Element Types

### 1. Headers and Footers (2 files)
- `header-footer.dotx` - Simple header/footer
- `complex-header-footer.dotx` - Multi-section headers

**Complexity**: Medium
**Estimated Time**: 1 day

**Required Classes**:
- `HeaderPart` - Header document part
- `FooterPart` - Footer document part
- `SectionProperties` - Section formatting
- `HeaderReference` - Section → Header link
- `FooterReference` - Section → Footer link

### 2. Tables (1 file)
- `table-styles.dotx` - Complex table formatting

**Complexity**: Medium
**Estimated Time**: 1 day

**Required Classes**:
- `TableStyle` - Table style definition
- `TableRowProperties` - Row formatting
- `TableCellProperties` - Cell formatting
- `TableBorders` - Border definitions

### 3. Bibliography (1 file)
- `bibliography.dotx` - Citation sources

**Complexity**: Low
**Estimated Time**: 0.5 days

**Required Classes**:
- `Bibliography` - Bibliography part
- `Source` - Citation source
- `SourceType` - Source type enum

### 4. Table of Contents (1 file)
- `toc.dotx` - Auto-generated TOC

**Complexity**: Low
**Estimated Time**: 0.5 days

**Required Classes**:
- `TableOfContents` - TOC field
- `TocEntry` - TOC entry

### 5. Watermark (1 file)
- `watermark.dotx` - Document watermark

**Complexity**: Low
**Estimated Time**: 0.5 days

**Required Classes**:
- `Watermark` - Watermark definition (VML-based)

### 6. Equations (1 file)  
- `equations.dotx` - Math equations (OMML)

**Complexity**: High
**Estimated Time**: 1 day

**Required Classes**:
Already exists via Plurimath integration:
- `Math::OMML` classes (36+ classes)
- Integration with `oMath` element

### 7. Cover Page (1 file)
- `cover-page.dotx` - Formatted cover page

**Complexity**: Low
**Estimated Time**: 0.5 days

**Required Classes**:
- Uses existing ContentControl classes
- May need `BuildingBlock` part

## Implementation Strategy

### Day 1: Headers & Footers
**Morning** (3 hours):
- Create `HeaderPart` and `FooterPart` classes
- Create `SectionProperties` with references
- Add to `DocxPackage` structure

**Afternoon** (3 hours):
- Implement serialization/deserialization
- Write round-trip tests
- Verify `header-footer.dotx` passes

### Day 2: Complex Headers & Tables
**Morning** (3 hours):
- Handle multi-section headers
- Verify `complex-header-footer.dotx` passes

**Afternoon** (3 hours):
- Implement table style classes
- Add table formatting properties
- Verify `table-styles.dotx` passes

### Day 3: Bibliography, TOC, Watermark
**Morning** (2 hours):
- Implement Bibliography classes
- Verify `bibliography.dotx` passes

**Afternoon** (4 hours):
- Implement TOC classes
- Implement Watermark (VML)
- Verify `toc.dotx` and `watermark.dotx` pass

### Day 4: Equations & Cover Page
**Morning** (3 hours):
- Verify Plurimath integration
- Ensure OMML round-trip works
- Verify `equations.dotx` passes

**Afternoon** (3 hours):
- Implement Cover Page support
- Add BuildingBlock part if needed
- Verify `cover-page.dotx` passes

### Day 5: Verification & Documentation
**Morning** (2 hours):
- Run complete test suite (61 examples)
- Fix any remaining issues

**Afternoon** (4 hours):
- Update README.adoc
- Update architecture documentation
- Update memory bank
- Create release notes

## Architecture Principles

### MECE Structure
```
DocumentPackage (DOCX)
├── DocumentPart (document.xml)
├── StylesPart (styles.xml)
├── NumberingPart (numbering.xml)
├── HeaderParts[] (header1.xml, header2.xml, ...)
├── FooterParts[] (footer1.xml, footer2.xml, ...)
├── BibliographyPart (bibliography.xml)
└── BuildingBlocksPart (buildingBlocks.xml)
```

### Separation of Concerns
- **Part classes**: Handle packaging (ZIP structure, relationships)
- **Model classes**: Pure domain objects (lutaml-model)
- **Serializers**: Convert models ↔ XML
- **Package class**: Orchestrate all parts

### Pattern 0 Compliance
**CRITICAL**: All new classes MUST declare attributes BEFORE xml mappings!

```ruby
class Header < Lutaml::Model::Serializable
  attribute :paragraphs, Paragraph, collection: true  # ✅ FIRST
  
  xml do
    element 'hdr'
    namespace Ooxml::Namespaces::WordProcessingML
    map_element 'p', to: :paragraphs
  end
end
```

## Testing Strategy

### Unit Tests
Each model class gets a spec file:
- `spec/uniword/header_spec.rb`
- `spec/uniword/footer_spec.rb`
- etc.

### Integration Tests
- `spec/uniword/document_elements_integration_spec.rb`
- Test header/footer in multi-section document
- Test bibliography with citations
- Test TOC generation

### Round-Trip Tests
- `spec/uniword/document_elements_roundtrip_spec.rb`
- Load each .dotx file
- Serialize to XML
- Compare with original (Canon equivalence)

## Success Criteria

1. ✅ All 8 document element files round-trip
2. ✅ Test suite: 61/61 examples passing (100%)
3. ✅ Zero regressions (StyleSets, Themes still 100%)
4. ✅ All architecture principles maintained
5. ✅ Documentation updated
6. ✅ Ready for v1.1.0 release

## Risk Mitigation

### Risk 1: Complex Table Formatting
**Mitigation**: Use existing `Table` classes, focus on style definitions only

### Risk 2: OMML Equation Support
**Mitigation**: Leverage existing Plurimath integration, just ensure round-trip

### Risk 3: VML Watermarks (Legacy)
**Mitigation**: Basic VML support sufficient, don't over-engineer

### Risk 4: Multi-Section Headers
**Mitigation**: Test incrementally, one section at a time

## File Organization

```
lib/uniword/
├── header.rb                 # NEW
├── footer.rb                 # NEW (move from stub)
├── section_properties.rb     # NEW (move from stub)
├── table_style.rb            # NEW
├── bibliography.rb           # NEW (move from stub)
├── table_of_contents.rb      # NEW
├── watermark.rb              # NEW
└── ooxml/
    ├── header_part.rb        # NEW
    ├── footer_part.rb        # NEW
    ├── bibliography_part.rb  # NEW
    └── building_blocks_part.rb # NEW
```

## Dependencies

**No new gems needed!**
- lutaml-model: Serialization ✅
- plurimath: OMML support ✅
- nokogiri: XML parsing ✅
- rubyzip: DOCX packaging ✅

## Deliverables

1. **Code**: 15-20 new classes
2. **Tests**: 8 round-trip examples + unit tests
3. **Documentation**: 
   - Updated README.adoc
   - Architecture docs
   - Memory bank
4. **Release**: v1.1.0 changelog

## Timeline Summary

| Day | Focus | Files Passing | Cumulative |
|-----|-------|--------------|------------|
| 1   | Headers & Footers | +2 | 55/61 (90%) |
| 2   | Complex Headers & Tables | +2 | 57/61 (93%) |
| 3   | Bibliography, TOC, Watermark | +3 | 60/61 (98%) |
| 4   | Equations & Cover Page | +2 | 61/61 (100%) ✅ |
| 5   | Verification & Docs | - | 61/61 (100%) ✅ |

**Total**: 5 days to 100% round-trip fidelity!
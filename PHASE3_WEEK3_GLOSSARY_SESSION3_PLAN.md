# Phase 3 Week 3: Glossary Session 3 - Completion Plan

## Executive Summary

**Status**: Session 2 COMPLETE ✅ | Session 3 READY TO START
**Progress**: 12/19 Glossary classes fixed (63%)
**Test Results**: 8/16 Content Types passing, Structural fixes complete
**Baseline**: 342/342 (StyleSets + Themes) still passing ✅

## Session 2 Achievements

### Core Infrastructure Complete ✅

**12 Classes Fixed** (Batch 1 + Batch 2):
1. GlossaryDocument - Root element
2. DocParts - Container for building blocks
3. DocPart - Individual building block entry
4. **DocPartBody - CRITICAL: Now contains WordprocessingML content** ⭐
5. DocPartProperties - Metadata container
6. DocPartName - Name property
7. DocPartDescription - Description property
8. DocPartGallery - Gallery classification
9. DocPartCategory - Category container
10. CategoryName - Category name
11. DocPartBehaviors - Behavior collection
12. DocPartBehavior - Individual behavior

### Key Architectural Fixes

**DocPartBody Transformation** (The Critical Win):
```ruby
# Before (WRONG):
attribute :content, :string

# After (CORRECT):
attribute :paragraphs, Uniword::Wordprocessingml::Paragraph, collection: true
attribute :tables, Uniword::Wordprocessingml::Table, collection: true
attribute :sdts, Uniword::Wordprocessingml2010::StructuredDocumentTag, collection: true
```

**Pattern Applied to All 12 Classes**:
- ✅ Namespace: `Glossary` → `WordProcessingML`
- ✅ Directive: `element` → `root`
- ✅ Names: snake_case → camelCase
- ✅ Pattern 0: Attributes BEFORE xml blocks

## Session 3: Complete Remaining Classes

### Objective
Fix final 9 supporting classes and achieve 16/16 tests passing (100%)

### Timeline: 1.5 hours

**Batch 1: Type System** (30 min)
- DocPartTypes container
- DocPartType individual type
- Related type properties

**Batch 2: ID & Metadata** (30 min)
- DocPartId - Document part identifier
- StyleId - Style reference
- Guid handling (in DocPartProperties)

**Batch 3: Content Type Markers** (30 min)
- AutoText - Auto text building block marker
- Equation - Equation building block marker  
- TextBox - Text box building block marker

### Remaining Classes to Fix (9 total)

```
lib/uniword/glossary/
├── doc_part_types.rb ❌ (container)
├── doc_part_type.rb ❌ (individual type)
├── doc_part_id.rb ❌ (identifier)
├── style_id.rb ❌ (style reference)
├── auto_text.rb ❌ (content marker)
├── equation.rb ❌ (content marker)
└── text_box.rb ❌ (content marker)
```

Plus 2 attributes in DocPartProperties:
- guid (already exists, but might need fixes)
- style (added in Session 2, might need element mapping)

## Implementation Strategy

### Pattern to Apply (Proven in Session 2)

For each class:

**Step 1**: Check current structure
```ruby
# Read the file
read_file('lib/uniword/glossary/[class_name].rb')
```

**Step 2**: Apply fixes
```ruby
# Fix namespace
namespace Uniword::Ooxml::Namespaces::Glossary  # WRONG
↓
namespace Uniword::Ooxml::Namespaces::WordProcessingML  # CORRECT

# Fix directive
element 'element_name'  # WRONG for top-level
↓
root 'elementName'  # CORRECT (camelCase)

# Attributes FIRST (Pattern 0)
attribute :attr, Type  # Always before xml block
xml do
  map_element 'elem', to: :attr
end
```

**Step 3**: Test after each batch
```bash
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb --format progress
```

### Expected Progress

**After Batch 1** (30 min):
- DocPartTypes, DocPartType fixed
- Tests: ~10/16 passing (62%)

**After Batch 2** (60 min total):
- DocPartId, StyleId fixed
- Tests: ~13/16 passing (81%)

**After Batch 3** (90 min total):
- AutoText, Equation, TextBox fixed
- Tests: 16/16 passing (100%) ✅

## Current Test Analysis

### What's Working ✅

From Session 2 test output, we can see proper structure:
```xml
<glossaryDocument>
  <docParts>
    <docPart>
      <docPartPr>
        <name val="Works Cited"/>
        <category>
          <name val="Built-In"/>
          <gallery val="bib"/>
        </category>
        <behaviors>
          <behavior val="p"/>
        </behaviors>
        <description val="..."/>
      </docPartPr>
      <docPartBody>
        <p>
          <pPr><pStyle val="Heading1"/></pPr>
          <r><t>Works Cited</t></r>
        </p>
      </docPartBody>
    </docPart>
  </docParts>
</glossaryDocument>
```

### What's Missing ❌

Minor attributes (will be handled by fixing remaining classes):
1. `Ignorable="w14 wp14"` on `<glossaryDocument>`
2. `<style val="Heading 1"/>` in `<docPartPr>`
3. `<guid val="{...}"/>` in `<docPartPr>`
4. `rsidR` attributes on `<p>` elements
5. Some `<r>` runs with `<instrText>` and `<rPr>`

These will be addressed when we fix the supporting classes in Session 3.

## Success Criteria

### Session 3 Complete
- [ ] All 9 remaining classes fixed
- [ ] All use WordProcessingML namespace
- [ ] All use proper root/element directives
- [ ] All use camelCase element names
- [ ] Pattern 0 compliance (100%)
- [ ] Zero regressions (342/342 baseline)
- [ ] 16/16 document element tests passing

## Risk Mitigation

### Risk 1: Attribute Handling
**Issue**: Missing attributes (Ignorable, guid, style, rsid)
**Solution**: Check if these need separate classes or if they're already defined

### Risk 2: Complex Type Classes
**Issue**: DocPartTypes might contain nested structures
**Solution**: Follow Body/Paragraph pattern - container with collection

### Risk 3: Time Pressure
**Issue**: Need to finish all 9 classes
**Solution**: Batch processing (3 batches of 3 classes each), test after each

## Files to Modify (Session 3)

**Glossary Classes** (9 files):
```
lib/uniword/glossary/
├── doc_part_types.rb
├── doc_part_type.rb
├── doc_part_id.rb
├── style_id.rb
├── auto_text.rb
├── equation.rb
├── text_box.rb
```

**Possible Updates** (if needed):
```
lib/uniword/glossary/
├── doc_part_properties.rb (guid/style mapping)
├── glossary_document.rb (Ignorable attribute)
```

## Next Steps

1. **Start Session 3** with Batch 1 (DocPartTypes, DocPartType)
2. **Follow proven pattern** from Session 2
3. **Test after each batch** to ensure progress
4. **Achieve 16/16** document element tests passing
5. **Verify baseline** (342/342 still passing)
6. **Update documentation** in README.adoc

## Reference

**Session 2 Files Modified**: 12 classes
**Session 2 Time**: ~2 hours (as planned)
**Session 2 Result**: Structural foundation complete ✅

**Session 3 Target**: 9 classes in 1.5 hours
**Session 3 Strategy**: 3 batches of 3 classes each
**Session 3 Goal**: 100% Glossary round-trip (16/16 tests)
# Phase 3: Additional Properties - Continuation Plan

**Status**: Ready to Start  
**Prerequisites**: Phase 2 Complete (100%)  
**Estimated Duration**: 2-4 weeks  

## Executive Summary

Phase 2 StyleSet Round-Trip is **COMPLETE** with 168/168 tests passing. The correct lutaml-model v0.7+ pattern for property serialization is proven and documented. Phase 3 focuses on expanding property coverage to achieve >95% OOXML compliance.

## Phase 2 Achievements (Baseline)

### Completed Properties (10 categories)

1. **Alignment** - `<w:jc w:val="center"/>` ✅
2. **Font Size** - `<w:sz w:val="32"/>` ✅  
3. **Font Size CS** - `<w:szCs w:val="32"/>` ✅
4. **Color** - `<w:color w:val="FF0000"/>` ✅
5. **Style References** - `<w:pStyle w:val="Heading1"/>`, `<w:rStyle/>` ✅
6. **Outline Level** - `<w:outlineLvl w:val="0"/>` ✅
7. **Spacing** - Complex object with before/after/lineSpacing ✅
8. **Indentation** - Complex object with left/right/hanging ✅
9. **RunFonts** - Complex object with ASCII/EastAsia/CS fonts ✅
10. **Boolean Flags** - bold, italic, smallCaps, caps, hidden ✅

### Proven Pattern

```ruby
# Step 1: Namespaced custom type
class PropertyValue < Lutaml::Model::Type::String
  xml_namespace Ooxml::Namespaces::WordProcessingML
end

# Step 2: Wrapper class
class Property < Lutaml::Model::Serializable
  attribute :value, PropertyValue
  xml do
    element 'tag'
    namespace Ooxml::Namespaces::WordProcessingML
    map_attribute 'val', to: :value
  end
end

# Step 3: Single attribute in parent
attribute :property, Property
xml { map_element 'tag', to: :property, render_nil: false }
```

## Phase 3: Objectives

### Goal 1: Additional Simple Element Properties (Priority 1)

**Target**: 15 new simple element properties across paragraph and run properties.

#### Paragraph Properties (2 new)

1. **Numbering ID** - `<w:numId w:val="1"/>`
   - Custom type: `NumberingIdValue < Lutaml::Model::Type::Integer`
   - Usage: Links paragraph to numbering definition

2. **Numbering Level** - `<w:ilvl w:val="0"/>`
   - Custom type: `NumberingLevelValue < Lutaml::Model::Type::Integer`
   - Usage: Indentation level in numbered/bulleted lists

#### Run Properties (13 new)

1. **Underline** - `<w:u w:val="single"/>`
   - Custom type: `UnderlineValue < Lutaml::Model::Type::String`
   - Values: single, double, thick, dotted, dashed, wave

2. **Highlight** - `<w:highlight w:val="yellow"/>`
   - Custom type: `HighlightValue < Lutaml::Model::Type::String`
   - Values: yellow, green, cyan, magenta, blue, red, etc.

3. **Vertical Align** - `<w:vertAlign w:val="superscript"/>`
   - Custom type: `VerticalAlignValue < Lutaml::Model::Type::String`
   - Values: superscript, subscript, baseline

4. **Position** - `<w:position w:val="5"/>`
   - Custom type: `PositionValue < Lutaml::Model::Type::Integer`
   - Usage: Raised/lowered text offset in half-points

5. **Character Spacing** - `<w:spacing w:val="20"/>`
   - Custom type: `CharSpacingValue < Lutaml::Model::Type::Integer`
   - Usage: Expand/condense character spacing in twips

6. **Kerning** - `<w:kern w:val="24"/>`
   - Custom type: `KerningValue < Lutaml::Model::Type::Integer`
   - Usage: Font kerning threshold in half-points

7. **Width Scale** - `<w:w w:val="120"/>`
   - Custom type: `WidthScaleValue < Lutaml::Model::Type::Integer`
   - Usage: Text width percentage (80-200%)

8. **Emphasis Mark** - `<w:em w:val="dot"/>`
   - Custom type: `EmphasisMarkValue < Lutaml::Model::Type::String`
   - Values: dot, comma, circle, underDot

9. **Text Effects** - `<w:effect w:val="shimmer"/>`
   - Custom type: `TextEffectValue < Lutaml::Model::Type::String`
   - Values: blinkBackground, lights, antsBlack, shimmer, sparkle

10. **Character Scale** - `<w:fitText w:val="1440"/>`
    - Custom type: `FitTextValue < Lutaml::Model::Type::Integer`
    - Usage: Fit text to width in twips

11. **Language** - `<w:lang w:val="en-US"/>`
    - Custom type: `LanguageValue < Lutaml::Model::Type::String`
    - Usage: Language code for spell-checking

12. **Vanish** - `<w:vanish/>`
    - Already boolean, verify serialization

13. **Web Hidden** - `<w:webHidden/>`
    - Already boolean, verify serialization

### Goal 2: Complex Properties (Priority 2)

**Target**: 5 complex properties requiring multi-attribute objects.

#### Paragraph Properties (3 complex)

1. **Borders** - `<w:pBdr>`
   ```ruby
   class ParagraphBorder < Lutaml::Model::Serializable
     attribute :style, BorderStyleValue
     attribute :size, BorderSizeValue
     attribute :color, ColorValue
     attribute :space, BorderSpaceValue
     # Positions: top, bottom, left, right, between, bar
   end
   ```

2. **Tabs** - `<w:tabs>`
   ```ruby
   class TabStop < Lutaml::Model::Serializable
     attribute :position, TabPositionValue
     attribute :alignment, TabAlignmentValue  # left, center, right, decimal
     attribute :leader, TabLeaderValue        # none, dot, hyphen, underscore
   end
   ```

3. **Shading** - `<w:shd>`
   ```ruby
   class Shading < Lutaml::Model::Serializable
     attribute :fill, ColorValue
     attribute :color, ColorValue
     attribute :pattern, ShadingPatternValue  # clear, solid, pct10, pct25, etc.
   end
   ```

#### Run Properties (2 complex)

1. **Border** - `<w:bdr>`
   ```ruby
   class RunBorder < Lutaml::Model::Serializable
     attribute :style, BorderStyleValue
     attribute :size, BorderSizeValue
     attribute :color, ColorValue
     attribute :space, BorderSpaceValue
   end
   ```

2. **Shading** - `<w:shd>` (same structure as paragraph shading)

### Goal 3: Table Properties Enhancement (Priority 3)

**Target**: Complete table property serialization (currently minimal).

1. **Table Width** - `<w:tblW w:type="dxa" w:w="5000"/>`
2. **Table Borders** - `<w:tblBorders>` (all positions)
3. **Table Shading** - `<w:tblShd>`
4. **Table Cell Margins** - `<w:tblCellMar>`
5. **Table Layout** - `<w:tblLayout w:type="fixed"/>`

## Implementation Strategy

### Week 1-2: Simple Element Properties

**Focus**: Implement all 15 simple element properties using proven pattern.

**Process per property**:
1. Create namespaced custom type (1 file, ~10 lines)
2. Create wrapper class (1 file, ~28 lines)
3. Add single attribute to property class
4. Update parser to create wrapper
5. Add test case to round-trip spec
6. Verify serialization

**Deliverables**:
- 15 new property files in `lib/uniword/properties/`
- Updated `paragraph_properties.rb` and `run_properties.rb`
- Updated parser in `styleset_xml_parser.rb`
- Expanded test coverage in `styleset_roundtrip_spec.rb`

### Week 3: Complex Properties

**Focus**: Implement 5 complex properties with multi-attribute objects.

**Process per property**:
1. Design object structure (attributes, types)
2. Create lutaml-model class following Pattern 0
3. Integrate into property classes
4. Update parser for complex objects
5. Test serialization and round-trip

**Deliverables**:
- 5 new complex property classes
- Parser updates for complex XML structures
- Round-trip tests for complex properties

### Week 4: Table Properties & Final Testing

**Focus**: Complete table property coverage and comprehensive testing.

**Process**:
1. Implement table-specific properties
2. Update `table_properties.rb` with new attributes
3. Update parser for table properties
4. Run comprehensive round-trip tests on all 24 StyleSets
5. Verify >95% property coverage

**Deliverables**:
- Complete table property implementation
- Updated documentation
- Test coverage report

## Success Criteria

### Property Coverage

- [ ] **20+ new properties implemented** (15 simple + 5 complex)
- [ ] **All properties serialize correctly** in round-trip tests
- [ ] **>95% OOXML property coverage** (from current ~40%)
- [ ] **Zero regression** in existing 168 tests

### Code Quality

- [ ] **All code follows proven pattern** from Phase 2
- [ ] **No backward compatibility cruft** (single attributes only)
- [ ] **Proper namespaced custom types** for all properties
- [ ] **Comprehensive documentation** for each property

### Testing

- [ ] **168 existing tests continue passing** (no regression)
- [ ] **+50 new test examples** for new properties
- [ ] **All 24 StyleSets test successfully** with new properties
- [ ] **Round-trip preservation** for all implemented properties

## Risk Mitigation

### Risk 1: Pattern Deviation

**Risk**: New properties might tempt deviation from proven pattern.

**Mitigation**: 
- Start each property by copying a working example
- Use checklist from CORRECTED_PROPERTY_SERIALIZATION_PATTERN.md
- Code review focuses on pattern adherence

### Risk 2: Complex Property Complexity

**Risk**: Complex properties may be harder than expected.

**Mitigation**:
- Start with simple properties to build momentum
- Study existing complex objects (Spacing, Indentation, RunFonts)
- Break down complex properties into smaller steps

### Risk 3: Test Regression

**Risk**: New properties might break existing tests.

**Mitigation**:
- Run full test suite after each property
- Use `render_nil: false` to avoid empty elements
- Keep changes isolated (one property at a time)

## Documentation Updates

### Files to Update

1. **README.adoc** - Update StyleSet section with Phase 3 status
2. **docs/CORRECTED_PROPERTY_SERIALIZATION_PATTERN.md** - Add new property examples
3. **docs/STYLESET_ARCHITECTURE.md** - Update implementation status
4. **Memory Bank** - Update context.md with Phase 3 progress

### New Documentation

1. **COMPLEX_PROPERTIES_GUIDE.md** - Guide for implementing complex properties
2. **PROPERTY_COVERAGE_REPORT.md** - Track property implementation status

## Timeline

```
Week 1: Simple Properties (Paragraph + Run basics)
  - Days 1-2: Numbering properties + underline/highlight
  - Days 3-4: Vertical align + position + spacing
  - Day 5: Kerning + width scale + emphasis mark

Week 2: Simple Properties (Run advanced + cleanup)
  - Days 1-2: Text effects + character scale + language
  - Days 3-4: Test all simple properties, fix issues
  - Day 5: Documentation updates

Week 3: Complex Properties
  - Days 1-2: Paragraph borders + tabs
  - Days 3-4: Shading (paragraph + run) + run border
  - Day 5: Test complex properties, fix issues

Week 4: Table Properties + Final
  - Days 1-2: Table width + borders + layout
  - Days 3-4: Table cell margins + shading
  - Day 5: Final testing, documentation, release prep
```

## Phase 3 Completion Checklist

- [ ] All 15 simple properties implemented
- [ ] All 5 complex properties implemented
- [ ] Table properties complete
- [ ] 168 existing tests still passing
- [ ] 50+ new tests added
- [ ] Documentation updated
- [ ] Memory bank updated
- [ ] README.adoc updated with Phase 3 status
- [ ] CHANGELOG.md updated
- [ ] Ready for v1.2.0 release

## Next Steps

1. **Review Phase 2 pattern** - Re-read CORRECTED_PROPERTY_SERIALIZATION_PATTERN.md
2. **Start with easiest property** - Implement `<w:u>` (underline) first
3. **Build momentum** - One property at a time, test after each
4. **Keep tests green** - Never commit broken tests
5. **Document as you go** - Update docs immediately after each property

## Reference Files

- **Pattern Guide**: docs/CORRECTED_PROPERTY_SERIALIZATION_PATTERN.md
- **Phase 2 Summary**: PHASE2_CONTINUATION_PLAN.md
- **Memory Bank**: .kilocode/rules/memory-bank/context.md
- **Test Spec**: spec/uniword/styleset_roundtrip_spec.rb

## Contact & Support

For questions about Phase 3 implementation:
- Review Phase 2 completion in memory bank
- Check proven pattern in CORRECTED_PROPERTY_SERIALIZATION_PATTERN.md
- Run tests frequently: `bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb`
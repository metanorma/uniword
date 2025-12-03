# Round-Trip Perfect Fidelity: CORRECT Implementation Plan

**Date**: November 27, 2024  
**Critical Principle**: NO RAW XML STORAGE - EVER. Complete lutaml-model coverage.

---

## 🚨 CORE PRINCIPLE

**ZERO TOLERANCE FOR RAW XML**

If we accept raw XML for "unknown" elements, we might as well accept raw XML for EVERYTHING. The entire point of this work is COMPLETE OOXML MODELING using lutaml-model classes.

**UnknownElement = ANTI-PATTERN = DELETE IT**

---

## Current Problems

### ❌ What's Wrong with Current Approach

1. **UnknownElement with raw XML** - Defeats the entire purpose
2. **DocxPackage storing raw_* attributes** - raw_font_table_xml, raw_settings_xml, etc.
3. **Partial modeling** - "Let's just preserve what we don't understand"
4. **Incremental forever** - "Add 5-10 elements per release"

**Result**: We'll NEVER achieve 100% coverage. We'll always have raw XML somewhere.

### ✅ What We Must Do

**100% lutaml-model coverage of OOXML spec**

Every single OOXML element must be:
1. Defined in YAML schema
2. Generated as lutaml-model class
3. Properly serialized/deserialized
4. NO raw XML storage anywhere

---

## CORRECT Implementation Plan

### Phase 1: Schema-Driven Infrastructure (Week 1 - 4-5 days)

**Delete These Files IMMEDIATELY**:
- `lib/uniword/unknown_element.rb` - ANTI-PATTERN
- All `raw_*` attributes in DocxPackage - ANTI-PATTERN

**Create Schema System**:

```
config/ooxml/schemas/
├── wordprocessingml.yml        # w: namespace (200+ elements)
├── math.yml                    # m: namespace (80+ elements)
├── drawing_main.yml            # a: namespace (150+ elements)
├── drawing_wordprocessing.yml  # wp: namespace (40+ elements)
├── relationships.yml           # r: namespace
├── vml.yml                     # v: namespace (100+ elements)
├── office_legacy.yml           # o: namespace
└── ... (ALL 30+ namespaces)
```

**YAML Schema Format**:

```yaml
namespace:
  uri: 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
  prefix: 'w'

elements:
  document:
    class_name: Document
    attributes:
      - name: body
        type: Body
        xml_name: body
        required: true
    
  body:
    class_name: Body
    attributes:
      - name: paragraphs
        type: Paragraph
        collection: true
        xml_name: p
      - name: tables
        type: Table
        collection: true
        xml_name: tbl
      - name: sections
        type: SectionProperties
        collection: true
        xml_name: sectPr
  
  p:
    class_name: Paragraph
    attributes:
      - name: properties
        type: ParagraphProperties
        xml_name: pPr
      - name: runs
        type: Run
        collection: true
        xml_name: r
      - name: hyperlinks
        type: Hyperlink
        collection: true
        xml_name: hyperlink
      - name: bookmark_starts
        type: BookmarkStart
        collection: true
        xml_name: bookmarkStart
      - name: bookmark_ends
        type: BookmarkEnd
        collection: true
        xml_name: bookmarkEnd
      - name: field_chars
        type: FieldChar
        collection: true
        xml_name: fldChar
      - name: instr_text
        type: InstrText
        collection: true
        xml_name: instrText

  # ... ALL 200+ elements in w: namespace
```

**Model Generator**:

```ruby
# lib/uniword/schema/model_generator.rb
class ModelGenerator
  def generate_from_schema(schema_file)
    schema = YAML.load_file(schema_file)
    
    schema['elements'].each do |tag_name, definition|
      class_code = generate_class_code(
        class_name: definition['class_name'],
        namespace: schema['namespace'],
        attributes: definition['attributes']
      )
      
      output_path = "lib/uniword/generated/#{class_name.underscore}.rb"
      File.write(output_path, class_code)
    end
  end
  
  def generate_class_code(class_name:, namespace:, attributes:)
    # Generate complete lutaml-model class
    # NO shortcuts, NO raw XML, COMPLETE modeling
  end
end
```

**Success Criteria Phase 1**:
- ✅ Schema system working
- ✅ Generator producing valid lutaml-model classes
- ✅ 100% w: namespace defined in YAML
- ✅ All classes generated and loadable
- ✅ UnknownElement DELETED
- ✅ DocxPackage has ZERO raw_* attributes

---

### Phase 2: Complete All Namespaces (Week 2 - 3-4 days)

**ALL 30+ Namespaces Must Be Fully Defined**:

1. **w:** (WordProcessingML) - 200+ elements
2. **m:** (MathML) - 80+ elements
3. **wp:** (WordProcessing Drawing) - 40+ elements
4. **a:** (DrawingML Main) - 150+ elements
5. **pic:** (Picture) - 20+ elements
6. **v:** (VML) - 100+ elements
7. **o:** (Office Legacy) - 50+ elements
8. **r:** (Relationships) - 10+ elements
9. **w14:** (Word 2010) - 50+ elements
10. **w15:** (Word 2013) - 30+ elements
11. **w16:** (Word 2016) - 20+ elements
12. **cp:** (Core Properties) - 15 elements
13. **app:** (App Properties) - 20 elements
14. **dc:** (Dublin Core) - 10 elements
15. **dcterms:** (Dublin Core Terms) - 8 elements
16. **... (ALL remaining namespaces)**

**NO ELEMENT LEFT BEHIND**

Every single element in ISO 29500 spec must have:
- YAML definition
- Generated lutaml-model class
- Full attribute mapping
- Proper namespace handling

**Success Criteria Phase 2**:
- ✅ 100% namespace coverage
- ✅ 600+ element classes generated
- ✅ Every OOXML element has a class
- ✅ ZERO gaps in coverage

---

### Phase 3: Serialization Integration (Week 3 - 3-4 days)

**Replace ALL Hardcoded Serialization**:

Current (WRONG):
```ruby
def build_paragraph(xml, paragraph)
  xml['w'].p do
    build_paragraph_properties(xml, paragraph.properties)
    paragraph.runs.each { |run| build_run(xml, run) }
  end
end
```

Correct (Schema-Driven):
```ruby
def serialize_element(element)
  schema_def = OoxmlSchema.definition_for(element.class)
  build_from_schema(element, schema_def)
end
```

**Delete These Files**:
- Most of `lib/uniword/serialization/ooxml_serializer.rb` - Replace with schema-driven
- Most of `lib/uniword/serialization/ooxml_deserializer.rb` - Replace with schema-driven

**Success Criteria Phase 3**:
- ✅ Generic serializer using schemas
- ✅ Generic deserializer using schemas
- ✅ NO hardcoded XML building
- ✅ All serialization schema-driven

---

### Phase 4: Complete Testing (Week 4 - 2-3 days)

**Test EVERY Element**:

```ruby
# spec/ooxml/wordprocessingml_spec.rb
RSpec.describe 'WordProcessingML Namespace' do
  # Test ALL 200+ elements
  describe 'w:document' do
    it 'serializes correctly'
    it 'deserializes correctly'
    it 'round-trips perfectly'
  end
  
  describe 'w:body' do
    it 'serializes correctly'
    it 'deserializes correctly'
    it 'round-trips perfectly'
  end
  
  # ... 200+ element tests
end
```

**Real-World Document Tests**:
- ISO 8601-2 document (2,399 paragraphs, math equations)
- Complex business document (images, charts, SmartArt)
- Legal document (track changes, comments)
- Academic paper (footnotes, bibliography)

**Success Criteria Phase 4**:
- ✅ 600+ element tests passing
- ✅ Real-world documents round-trip perfectly
- ✅ ZERO data loss
- ✅ Byte-level comparison within 5%

---

### Phase 5: Documentation (Week 4 - 1 day)

**Complete Documentation**:
- Schema format specification
- Generator usage guide
- Adding new elements guide
- Architecture documentation

---

## Timeline

```
Week 1: Schema Infrastructure
  Day 1-2: Create schema system and generator
  Day 3-4: Define w: namespace (200+ elements)
  Day 5: Generate and test w: namespace classes

Week 2: Complete All Namespaces
  Day 1-2: Math, Drawing namespaces (280+ elements)
  Day 3-4: VML, Legacy namespaces (200+ elements)
  Day 5: Remaining namespaces (120+ elements)

Week 3: Serialization Integration
  Day 1-2: Build schema-driven serializer
  Day 3-4: Build schema-driven deserializer
  Day 5: Integration testing

Week 4: Testing & Documentation
  Day 1-2: Comprehensive testing
  Day 3: Real-world document testing
  Day 4: Documentation
  Day 5: Release preparation

TOTAL: 20 working days (4 weeks)
```

---

## Success Metrics

### Absolute Requirements

1. **ZERO raw XML storage** - Not in UnknownElement, not in DocxPackage, nowhere
2. **600+ lutaml-model classes** - Every OOXML element covered
3. **100% schema-driven** - No hardcoded serialization
4. **Perfect round-trip** - Real-world documents byte-identical
5. **ISO 29500 compliant** - Full specification coverage

### Quality Standards

- Every element has YAML schema definition
- Every class generated from schema
- Every class fully tested
- Every namespace completely covered
- NO exceptions, NO shortcuts, NO "we'll do it later"

---

## What Gets Deleted

### Files to DELETE:
- `lib/uniword/unknown_element.rb` - ANTI-PATTERN
- `lib/uniword/unknown_element_spec.rb` - Test for anti-pattern

### Code to DELETE:
- All `raw_*` attributes in DocxPackage
- All `raw_xml` preservation logic
- All references to UnknownElement
- All hardcoded XML building in serializers
- All manual element parsing in deserializers

---

## What Gets Created

### New Infrastructure:
```
config/ooxml/schemas/          # YAML schemas for ALL namespaces
lib/uniword/schema/            # Schema loading and validation
lib/uniword/generators/        # Model and serializer generators
lib/uniword/generated/         # Generated lutaml-model classes
spec/ooxml/                    # Per-namespace test suites
```

### Generated Classes:
```
lib/uniword/generated/
├── wordprocessingml/          # 200+ classes
├── math/                      # 80+ classes
├── drawing/                   # 190+ classes
├── vml/                       # 100+ classes
└── ... (30+ namespace directories)
```

---

## Risk Mitigation

**Risk**: "This is too much work"
**Mitigation**: It's the RIGHT work. Anything less is a hack.

**Risk**: "Can't we do it incrementally?"
**Mitigation**: We tried that. Result: raw XML everywhere, never complete.

**Risk**: "What if schema generation fails?"
**Mitigation**: Test and validate every step. Generator is ONE TIME WORK.

---

## Conclusion

**Original Assessment**: WRONG. Suggested keeping UnknownElement and raw XML.

**Correct Approach**: Complete OOXML modeling, schema-driven generation, ZERO raw XML.

**Timeline**: 4 weeks to complete, properly architected system.

**Alternative**: Continue with incremental hacks, never achieve 100%, always have raw XML.

**Decision**: Do it RIGHT or don't do it at all.

---

## Next Steps

1. **Delete UnknownElement** - Remove the anti-pattern
2. **Create schema system** - YAML definitions
3. **Build generator** - Model class generation
4. **Define ALL namespaces** - 600+ elements
5. **Generate ALL classes** - Complete coverage
6. **Schema-driven serialization** - No hardcoding
7. **Complete testing** - Every element
8. **Ship v2.0.0** - Proper architecture

**Start Date**: Immediately after approval
**Completion**: 4 weeks
**Result**: Industry-leading OOXML library with 100% coverage and ZERO raw XML
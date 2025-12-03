# Round-Trip Perfect Fidelity Implementation Plan

**Created**: November 27, 2024
**Goal**: Achieve 100% round-trip fidelity for Word documents (DOCX format)
**Current Status**: v1.1.0 - Enhanced properties complete, round-trip partially working

---

## Executive Summary

Round-tripping is the ability to:
1. Load a Word document (DOCX)
2. Optionally modify specific elements
3. Save the document back to disk
4. Result: **ALL** original content, formatting, structure, and metadata preserved

**Approach**: Complete OOXML modeling using lutaml-model classes - NO raw XML preservation.
Every element is a proper Ruby object with full type safety and validation.

This is critical for:
- Document editing workflows
- Template filling
- Batch processing
- Enterprise document management systems

---

## Current Round-Trip Status (v1.1.0)

### ✅ Working Components

**Document Structure**:
- Document body with paragraphs ✅
- Text runs with basic formatting ✅
- Tables with cells and rows ✅
- Sections ✅

**Properties**:
- Core properties (title, author, etc.) ✅
- App properties (application metadata) ✅
- Paragraph properties (basic + enhanced) ✅
- Run properties (basic + enhanced) ✅

**Theming**:
- Theme objects (colors, fonts) ✅
- StyleSets ✅
- Namespace handling ✅

**Infrastructure**:
- ZIP packaging/extraction ✅
- XML serialization (lutaml-model) ✅
- Relationship management ✅
- Content types ✅

### ⚠️ Missing Complete Modeling

**Document Elements Needing Full Modeling**:
- Headers/footers - Need all types and content modeling
- Footnotes/endnotes - Need complete properties
- Bookmarks - Need full bookmark model
- Comments - Need complete comment threading
- Track changes - Need all revision types

**Advanced Features Needing Complete Modeling**:
- Math equations (OMML) - Need all m: namespace elements
- Images - Need complete DrawingML (wp:, a:, pic: namespaces)
- Drawing objects - Need all shape types
- Text boxes - Need complete text box properties
- SmartArt - Need complete SmartArt model
- Charts - Need complete chart model with data

**Namespaces Needing Complete Modeling**:
- w14:, w15:, w16: (Word 2010-2016 features)
- All drawing namespaces (wp:, a:, pic:, wpg:, wps:)
- All compatibility namespaces (mc:, o:, v:)

---

## Phase 1: Complete OOXML Element Modeling (4-5 days)

### 1.1 Schema-Driven Model Generation

**Problem**: We need to model ALL OOXML elements, not just common ones

**Implementation**: Schema-driven approach using YAML definitions

**Files to Create**:
- `config/ooxml/schemas/` - YAML schema definitions for all namespaces
- `lib/uniword/schema/` - Schema loading and validation
- `lib/uniword/generators/model_generator.rb` - Generate lutaml-model classes from schemas

**Schema Pattern** (`config/ooxml/schemas/wordprocessingml.yml`):
```yaml
# WordProcessingML (w:) namespace elements
namespace:
  uri: 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
  prefix: 'w'

elements:
  document:
    root: true
    class_name: Document
    attributes:
      - name: body
        type: Body
        required: true
    
  body:
    class_name: Body
    attributes:
      - name: elements
        type: BodyElement
        collection: true
        polymorphic: true  # Can be Paragraph, Table, SectPr, etc.
  
  p:
    class_name: Paragraph
    attributes:
      - name: properties
        type: ParagraphProperties
        xml_name: pPr
      - name: elements
        type: ParagraphElement
        collection: true
        polymorphic: true  # Can be Run, Hyperlink, BookmarkStart, etc.
  
  # ... all 200+ elements in w: namespace
```

**Model Generator**:
```ruby
class ModelGenerator
  def generate_from_schema(schema_file)
    schema = YAML.load_file(schema_file)
    
    schema['elements'].each do |tag_name, definition|
      generate_model_class(
        class_name: definition['class_name'],
        namespace: schema['namespace'],
        tag_name: tag_name,
        attributes: definition['attributes']
      )
    end
  end
  
  def generate_model_class(class_name:, namespace:, tag_name:, attributes:)
    # Generate lutaml-model class
    # Write to lib/uniword/generated/
  end
end
```

**Success Criteria**:
- YAML schemas define all OOXML elements
- Generator creates valid lutaml-model classes
- 100% ISO 29500 coverage
- All elements properly modeled as Ruby classes

### 1.2 Complete All Namespace Definitions

**Current**: 8 namespaces
**Target**: All 30+ OOXML namespaces with COMPLETE element modeling

**All Namespaces** (MUST be fully modeled):
```yaml
Core Document:
  - w: WordProcessingML (200+ elements)
  - w14: Word 2010 extensions (50+ elements)
  - w15: Word 2013 extensions (30+ elements)
  - w16: Word 2016 extensions (20+ elements)

Drawing and Graphics:
  - wp: DrawingML WordProcessing (40+ elements)
  - a: DrawingML Main (150+ elements)
  - pic: Picture (20+ elements)
  - wpg: Group shapes (15+ elements)
  - wps: Shape definitions (30+ elements)
  - wpc: Drawing canvas (10+ elements)

Math:
  - m: Office Math Markup Language (80+ elements)

Legacy:
  - v: VML (Vector Markup Language) (100+ elements)
  - o: Office legacy (50+ elements)
  - w10: Word 2000 legacy (20+ elements)

Metadata:
  - cp: Core properties (15 elements)
  - dc: Dublin Core (10 elements)
  - dcterms: Dublin Core terms (8 elements)
  - xsi: XML Schema Instance (3 elements)

Relationships:
  - r: Relationships (5 elements)

Markup Compatibility:
  - mc: Fallback/choice (8 elements)

All Others: (each fully modeled)
  - ds, dsp, vt, wne, etc.
```

**Implementation Approach**:
```ruby
# Each namespace gets:
# 1. Namespace class (lutaml-model)
# 2. YAML schema with ALL elements
# 3. Generated model classes for ALL elements
# 4. Tests for ALL elements
```

**Success Criteria**:
- 100% namespace coverage
- Every element in every namespace is a lutaml-model class
- Zero unmapped elements
- Complete ISO 29500 compliance

### 1.3 Complete Relationship Modeling

**Files to Create/Fix**:
- `lib/uniword/ooxml/relationships.rb`
- `lib/uniword/ooxml/relationship.rb`
- `lib/uniword/ooxml/relationship_types.rb` - All relationship types as constants

**YAML Schema** (`config/ooxml/schemas/relationships.yml`):
```yaml
namespace:
  uri: 'http://schemas.openxmlformats.org/package/2006/relationships'
  prefix: 'r'

relationship_types:
  # Document relationships
  office_document: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument'
  styles: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles'
  theme: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme'
  font_table: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/fontTable'
  numbering: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/numbering'
  settings: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/settings'
  
  # Content relationships
  header: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/header'
  footer: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer'
  footnotes: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/footnotes'
  endnotes: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/endnotes'
  comments: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/comments'
  
  # Media relationships
  image: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/image'
  hyperlink: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink'
  
  # ... ALL 50+ relationship types fully enumerated
```

**Complete Model**:
```ruby
class Relationship < Lutaml::Model::Serializable
  attribute :id, :string
  attribute :type, :string  # Must be from RelationshipTypes
  attribute :target, :string
  attribute :target_mode, :string  # Internal or External
  
  xml do
    root 'Relationship'
    namespace Ooxml::Namespaces::Relationships
    map_attribute 'Id', to: :id
    map_attribute 'Type', to: :type
    map_attribute 'Target', to: :target
    map_attribute 'TargetMode', to: :target_mode
  end
  
  # Type-safe validation
  def validate_type!
    unless RelationshipTypes.valid?(type)
      raise InvalidRelationshipTypeError, "Unknown relationship type: #{type}"
    end
  end
end

class Relationships < Lutaml::Model::Serializable
  attribute :relationships, Relationship, collection: true
  
  xml do
    root 'Relationships'
    namespace Ooxml::Namespaces::Relationships
    map_element 'Relationship', to: :relationships
  end
  
  # Type-safe relationship management
  def add_relationship(type:, target:, target_mode: 'Internal')
    raise ArgumentError unless RelationshipTypes.valid?(type)
    
    id = generate_next_id
    relationships << Relationship.new(
      id: id,
      type: type,
      target: target,
      target_mode: target_mode
    )
  end
end
```

**Success Criteria**:
- ALL relationship types enumerated and validated
- Type-safe relationship creation
- Relationship IDs auto-generated correctly
- 100% round-trip fidelity for all .rels files

---

## Phase 2: Complete Document Elements (3-4 days)

### 2.1 Headers and Footers

**Current**: Basic structure exists
**Target**: Full support including:
- Multiple header types (default, first, even)
- Multiple footer types
- Content (paragraphs, tables, images)
- Page numbering fields
- Section-specific headers/footers

**Files to Fix**:
- `lib/uniword/header.rb`
- `lib/uniword/footer.rb`
- `lib/uniword/section.rb`

**Implementation Checklist**:
- [ ] Header types (default, first, even, odd)
- [ ] Footer types (default, first, even, odd)
- [ ] Different headers per section
- [ ] Field codes (PAGE, NUMPAGES, DATE, etc.)
- [ ] Images in headers/footers
- [ ] Tables in headers/footers
- [ ] Relationship handling (rId references)

**Test Strategy**:
```ruby
RSpec.describe 'Header/Footer Round-Trip' do
  it 'preserves different headers per section' do
    doc = load_file('multi_section.docx')
    doc.save('output.docx')
    
    reloaded = load_file('output.docx')
    expect(reloaded.sections[0].default_header.paragraphs.count)
      .to eq(doc.sections[0].default_header.paragraphs.count)
  end
end
```

### 2.2 Footnotes and Endnotes

**Files to Fix**:
- `lib/uniword/footnote.rb`
- `lib/uniword/endnote.rb`
- `lib/uniword/footnotes_configuration.rb`
- `lib/uniword/endnotes_configuration.rb`

**Requirements**:
- Preserve footnote/endnote numbering
- Preserve content (paragraphs, formatting)
- Preserve reference markers in text
- Handle custom separators
- Handle continuation notices

**Pattern**:
```ruby
class Footnote < Element
  attribute :id, :integer
  attribute :type, :string  # normal, separator, continuationSeparator
  attribute :paragraphs, Paragraph, collection: true
  
  xml do
    root 'footnote'
    namespace Namespaces::WordProcessingML
    map_attribute 'id', to: :id
    map_attribute 'type', to: :type
    map_element 'p', to: :paragraphs
  end
end
```

### 2.3 Comments and Track Changes

**Files to Create/Fix**:
- `lib/uniword/comment.rb`
- `lib/uniword/comments_configuration.rb`
- `lib/uniword/revision.rb`
- `lib/uniword/revisions_configuration.rb`

**Comments Requirements**:
- Comment text and author
- Comment anchors (start/end ranges)
- Reply threading
- Date/time stamps
- Resolved status

**Track Changes Requirements**:
- Insertions (w:ins)
- Deletions (w:del)
- Formatting changes (w:rPrChange, w:pPrChange)
- Move operations (w:moveTo, w:moveFrom)
- Author and date tracking
- Revision IDs

**Critical Pattern**:
```ruby
class Revision < Element
  attribute :id, :integer
  attribute :author, :string
  attribute :date, :string
  attribute :type, :string  # insert, delete, formatChange
  attribute :content, :string, default: -> { '' }  # Raw XML of revised content
  
  # Preserve revision exactly as-is
  def to_xml
    # Return preserved content
  end
end
```

### 2.4 Field Codes

**Files to Create**:
- `lib/uniword/field.rb`
- `lib/uniword/field_code.rb`

**Common Fields**:
- PAGE - Page number
- NUMPAGES - Total pages
- DATE - Current date
- TIME - Current time
- HYPERLINK - Links
- REF - Cross-references
- TOC - Table of contents
- INDEX - Index
- SEQ - Sequence numbers

**Pattern**:
```ruby
class Field < Element
  attribute :code, :string
  attribute :result, :string
  attribute :locked, :boolean
  
  xml do
    root 'fldSimple'
    map_attribute 'instr', to: :code
    # Complex fields use w:instrText
  end
end
```

---

## Phase 3: Advanced Elements (3-4 days)

### 3.1 Images and Drawing Objects

**Current**: Basic image support
**Target**: Complete DrawingML support

**Files to Fix/Create**:
- `lib/uniword/image.rb`
- `lib/uniword/drawing.rb`
- `lib/uniword/drawing/inline.rb`
- `lib/uniword/drawing/anchor.rb`
- `lib/uniword/drawing/extent.rb`
- `lib/uniword/drawing/effect_extent.rb`

**Requirements**:
- Inline images
- Floating images (anchored)
- Text wrapping (square, tight, through, etc.)
- Positioning (absolute, relative)
- Effects (shadows, reflections, 3D)
- Image relationships (rId references)
- Alternative text
- Hyperlinks on images

**Critical DrawingML Namespaces**:
- wp: - WordProcessing Drawing
- a: - DrawingML Main
- pic: - Picture
- wp14: - Word 2010 Drawing
- wps: - Shape definitions
- wpg: - Group shapes

### 3.2 Math Equations (OMML)

**Files to Fix**:
- `lib/uniword/math/` directory structure
- Integration with Plurimath gem

**Requirements**:
- All OMML elements (m: namespace)
- Equation editor objects
- Inline vs display equations
- Complex fractions, matrices, integrals
- Preserve exact formatting

**Dependency**:
- Plurimath gem (already integrated)
- OMML → MathML conversion
- Round-trip: OMML → Parse → OMML

### 3.3 SmartArt and Charts

**Priority**: Lower (can preserve as unknown elements)

**Approach**:
- Model basic structure
- Preserve detailed XML as unknown
- Focus on:
  - Chart relationships
  - Embedded Excel workbooks
  - SmartArt XML structure

---

## Phase 4: Properties and Metadata (1-2 days)

### 4.1 Document Properties

**Files to Fix/Create**:
- `lib/uniword/ooxml/core_properties.rb` ✅ (Already exists)
- `lib/uniword/ooxml/app_properties.rb` ✅ (Already exists)
- `lib/uniword/ooxml/custom_properties.rb` (Create)

**Custom Properties**:
```ruby
class CustomProperty < Lutaml::Model::Serializable
  attribute :name, :string
  attribute :value, :string  # or other types
  attribute :type, :string   # string, integer, boolean, date
  
  xml do
    root 'property'
    namespace Namespaces::CustomProperties
    map_attribute 'name', to: :name
    map_attribute 'fmtid', to: :format_id
    map_element 'lpwstr', to: :value  # or other type elements
  end
end
```

### 4.2 Settings

**Files to Create**:
- `lib/uniword/settings.rb`
- `lib/uniword/settings/` (subdirectory for settings classes)

**Settings to Support**:
- View settings (print, web, outline)
- Zoom level
- Default tab stop
- Track changes settings
- Compatibility settings
- Protection settings
- Proof settings (spell/grammar)

---

## Phase 5: Validation and Testing (2-3 days)

### 5.1 Round-Trip Test Suite

**Structure**:
```
spec/round_trip/
├── simple_document_spec.rb
├── formatted_document_spec.rb
├── complex_document_spec.rb
├── headers_footers_spec.rb
├── images_spec.rb
├── tables_spec.rb
├── comments_spec.rb
├── track_changes_spec.rb
├── math_equations_spec.rb
├── fields_spec.rb
└── real_world_documents_spec.rb
```

**Test Pattern**:
```ruby
RSpec.describe 'Round-Trip: Complex Document' do
  let(:input_file) { 'spec/fixtures/complex_document.docx' }
  let(:output_file) { 'tmp/round_trip_output.docx' }
  
  it 'preserves all content and formatting' do
    # Load
    doc = Uniword::Document.open(input_file)
    
    # Save
    doc.save(output_file)
    
    # Reload
    reloaded = Uniword::Document.open(output_file)
    
    # Assertions
    expect(reloaded.paragraphs.count).to eq(doc.paragraphs.count)
    expect(reloaded.text).to eq(doc.text)
    expect(reloaded.styles_configuration.styles.count)
      .to eq(doc.styles_configuration.styles.count)
    
    # Byte comparison (if feasible)
    # or semantic XML comparison with Canon
    expect(output_file).to be_xml_equivalent_to(input_file)
  end
  
  it 'preserves unknown elements' do
    doc = Uniword::Document.open(input_file)
    unknown_count_before = count_unknown_elements(doc)
    
    doc.save(output_file)
    reloaded = Uniword::Document.open(output_file)
    unknown_count_after = count_unknown_elements(reloaded)
    
    expect(unknown_count_after).to eq(unknown_count_before)
  end
end
```

### 5.2 Real-World Documents

**Test Corpus**:
1. Simple documents (< 5 pages)
2. Business reports (10-50 pages)
3. Scientific papers (with equations)
4. Theses/dissertations (100+ pages)
5. Legal documents (track changes, comments)
6. Marketing materials (images, SmartArt)
7. Templates (content controls, fields)

**Acquisition**:
- Create test documents in Word
- Download from public repos
- Generate programmatically

**Success Metrics**:
- 95%+ round-trip success rate
- Zero data loss
- Formatting preserved
- Structure maintained

### 5.3 Performance Testing

**Benchmarks**:
```ruby
require 'benchmark/ips'

Benchmark.ips do |x|
  x.report('simple doc (5 pages)') do
    doc = Uniword::Document.open('simple.docx')
    doc.save('output.docx')
  end
  
  x.report('complex doc (50 pages)') do
    doc = Uniword::Document.open('complex.docx')
    doc.save('output.docx')
  end
  
  x.report('large doc (200 pages)') do
    doc = Uniword::Document.open('large.docx')
    doc.save('output.docx')
  end
end
```

**Targets**:
- Simple doc: < 50ms
- Complex doc: < 500ms
- Large doc: < 2000ms
- Memory: < 100MB for 200-page doc

---

## Phase 6: Documentation and Examples (1 day)

### 6.1 Round-Trip Guide

**File**: `docs/ROUND_TRIP_GUIDE.md`

**Contents**:
1. What is round-tripping
2. Supported features
3. Known limitations
4. Best practices
5. Troubleshooting
6. Performance tips

### 6.2 Examples

**Files**:
- `examples/round_trip_simple.rb`
- `examples/round_trip_with_modifications.rb`
- `examples/round_trip_batch_processing.rb`

### 6.3 API Documentation

**Update**:
- `README.adoc` - Add round-trip section
- RDoc comments - All classes
- YARD documentation - Generate

---

## Implementation Status Tracker

### Phase 1: Core Infrastructure
- [ ] 1.1 Unknown Element Preservation System
  - [ ] UnknownElement class
  - [ ] ElementRegistry
  - [ ] Integration in all containers
  - [ ] Preservation logger
- [ ] 1.2 Complete Namespace Support
  - [ ] Priority 1 namespaces (6)
  - [ ] Priority 2 namespaces (4)
  - [ ] Priority 3 namespaces (4)
- [ ] 1.3 Relationship Preservation
  - [ ] Relationships class fixes
  - [ ] External relationship handling
  - [ ] ID preservation

### Phase 2: Complete Document Elements
- [ ] 2.1 Headers and Footers
  - [ ] Header types
  - [ ] Footer types
  - [ ] Section support
  - [ ] Field codes
- [ ] 2.2 Footnotes and Endnotes
  - [ ] Footnote class complete
  - [ ] Endnote class complete
  - [ ] Numbering preservation
  - [ ] Configuration files
- [ ] 2.3 Comments and Track Changes
  - [ ] Comment system
  - [ ] Track changes (insertions)
  - [ ] Track changes (deletions)
  - [ ] Track changes (formatting)
- [ ] 2.4 Field Codes
  - [ ] Field class
  - [ ] Common field types
  - [ ] Complex fields

### Phase 3: Advanced Elements
- [ ] 3.1 Images and Drawing Objects
  - [ ] Inline images
  - [ ] Floating images
  - [ ] Drawing namespace support
  - [ ] Positioning and wrapping
- [ ] 3.2 Math Equations
  - [ ] OMML parsing
  - [ ] Plurimath integration
  - [ ] Round-trip testing
- [ ] 3.3 SmartArt and Charts
  - [ ] Basic modeling
  - [ ] Unknown preservation

### Phase 4: Properties and Metadata
- [ ] 4.1 Document Properties
  - [ ] Custom properties
  - [ ] Extended properties
- [ ] 4.2 Settings
  - [ ] Settings file
  - [ ] View settings
  - [ ] Compatibility settings

### Phase 5: Validation and Testing
- [ ] 5.1 Round-Trip Test Suite
  - [ ] Simple document tests
  - [ ] Complex document tests
  - [ ] All feature tests
- [ ] 5.2 Real-World Documents
  - [ ] Test corpus assembled
  - [ ] All documents passing
- [ ] 5.3 Performance Testing
  - [ ] Benchmarks created
  - [ ] Targets met

### Phase 6: Documentation
- [ ] 6.1 Round-Trip Guide
- [ ] 6.2 Examples
- [ ] 6.3 API Documentation

---

## Timeline Estimate

**Total**: 12-17 days

- Phase 1: 2-3 days
- Phase 2: 3-4 days
- Phase 3: 3-4 days
- Phase 4: 1-2 days
- Phase 5: 2-3 days
- Phase 6: 1 day

**Parallelization Opportunities**:
- Phases 2 and 3 can partially overlap
- Phase 6 can start once Phase 5.1 begins
- Testing can be continuous

---

## Success Criteria

### MVP (Minimum Viable Product)
- ✅ Load and save simple documents (5-10 pages)
- ✅ Preserve all text content
- ✅ Preserve basic formatting (bold, italic, fonts)
- ✅ Preserve paragraph properties
- ✅ Preserve styles
- ✅ Zero data loss

### Full Features
- ✅ Support documents up to 500 pages
- ✅ Preserve ALL formatting
- ✅ Preserve headers/footers
- ✅ Preserve images
- ✅ Preserve tables
- ✅ Preserve comments
- ✅ Preserve track changes
- ✅ Preserve unknown elements
- ✅ 95%+ test corpus success rate

### Performance
- ✅ < 50ms for simple documents
- ✅ < 500ms for complex documents
- ✅ < 100MB memory for 200-page documents

---

## Risk Mitigation

### Technical Risks

**Risk**: Unknown elements not preserved correctly
- **Mitigation**: Comprehensive preservation system (Phase 1.1)
- **Fallback**: Raw XML storage for problematic elements

**Risk**: Namespace conflicts
- **Mitigation**: Complete namespace mapping (Phase 1.2)
- **Fallback**: Dynamic namespace detection

**Risk**: Relationship ID collisions
- **Mitigation**: ID tracking and generation (Phase 1.3)
- **Fallback**: Relationship validation layer

**Risk**: Memory issues with large documents
- **Mitigation**: Streaming parsers, lazy loading
- **Fallback**: Chunked processing

### Project Risks

**Risk**: Timeline overrun
- **Mitigation**: Phased approach, MVP first
- **Fallback**: Reduce scope to MVP only

**Risk**: Test corpus inadequate
- **Mitigation**: Generate diverse test documents
- **Fallback**: Community-contributed documents

---

## Next Steps

1. **Immediate**: Start Phase 1.1 (Unknown Element Preservation)
2. **Week 1**: Complete Phase 1
3. **Week 2**: Complete Phase 2
4. **Week 3**: Complete Phases 3-4
5. **Week 4**: Complete Phases 5-6

**Priority Order**:
1. Unknown element preservation (critical)
2. Namespaces (critical)
3. Relationships (critical)
4. Headers/footers (high)
5. Images (high)
6. Comments/track changes (medium)
7. SmartArt/charts (low)

---

## Resources Required

**Libraries**:
- lutaml-model (already integrated)
- nokogiri (already integrated)
- rubyzip (already integrated)
- canon (for XML comparison)
- plurimath (for math equations)

**Test Documents**:
- Simple templates (create)
- Business documents (create/download)
- Scientific papers (public domain)
- Legal documents (sanitized examples)

**Development Tools**:
- RSpec (testing)
- RuboCop (code quality)
- Benchmark-ips (performance)
- Memory profiler (optimization)

---

## Conclusion

Perfect round-trip fidelity is achievable with a systematic approach:
1. Preserve what we don't understand (unknown elements)
2. Model what matters most (core elements)
3. Test exhaustively (real-world documents)
4. Document clearly (guides and examples)

This plan provides a roadmap to v2.0.0 with industry-leading round-trip support.
# Feature 1: Full Schema Support & Complex File Round-Trip

## Objective

**Goal**: Support complete OOXML schema (250+ elements) with perfect round-trip fidelity for complex files.

**Current State**: 124 elements supported, ~40% ISO/IEC 29500-1 coverage
**Target State**: 250+ elements, 100% ISO/IEC 29500-1 WordProcessingML coverage

## User Problem

Users have complex Word documents with:
- Charts and diagrams
- SmartArt graphics
- Content controls (forms)
- Complex fields (auto-updating)
- Custom XML bindings
- Advanced formatting

**Issue**: Current Uniword drops these elements during read/write → data loss in round-trip

**Need**: Perfect preservation - read complex file, modify, write → no data loss

## Architecture Design

### Principle: Unknown Element Preservation

**Pattern**: Preserve unknown elements as "opaque blobs" until schema support added

```ruby
module Uniword
  # Unknown element - preserves content we don't understand yet
  #
  # Responsibility: Hold raw OOXML for elements not in schema
  # Single Responsibility: Preservation only
  class UnknownElement < Element
    attribute :tag_name, :string      # Original tag (e.g., "w:chart")
    attribute :raw_xml, :string       # Complete XML preserved
    attribute :namespace, :string     # Namespace URI

    # Serialize back to original XML (no modification)
    def to_xml
      @raw_xml
    end
  end

  # Enhanced deserializer - creates UnknownElement for unsupported tags
  class OoxmlDeserializer
    def parse_element(xml_node)
      element_name = xml_node.name

      if @schema.has_element?(element_name)
        # Parse using schema
        parse_known_element(xml_node)
      else
        # Preserve as UnknownElement
        UnknownElement.new(
          tag_name: element_name,
          raw_xml: xml_node.to_xml,
          namespace: xml_node.namespace&.href
        )
      end
    end
  end
end
```

### Schema Expansion Strategy

**Phase-by-Phase Addition** (external YAML configuration):

```
config/ooxml/schemas/
  # Existing (124 elements)
  01-11_*.yml

  # NEW Phase 1 (50 elements) - Charts & Diagrams
  13_charts.yml              # c:chart, c:plotArea, c:barChart, c:lineChart, etc.
  14_diagrams.yml            # w:diagr, dgm:* elements

  # NEW Phase 2 (40 elements) - SmartArt & Graphics
  15_smartart.yml            # SmartArt definition elements
  16_vml.yml                 # VML legacy graphics (complete)

  # NEW Phase 3 (40 elements) - Content Controls & Fields
  17_content_controls.yml    # w:sdt, w:sdtPr, w:sdtContent
  18_fields_advanced.yml     # w:fldSimple (complete), field codes

  # NEW Phase 4 (50 elements) - Custom XML & Advanced
  19_custom_xml.yml          # Custom XML data binding
  20_document_settings.yml   # Complete document settings
  21_compatibility.yml       # Compatibility options
  22_web_settings.yml        # Web page settings
```

### Round-Trip Validation

**Test Strategy**: Real-world document corpus

```ruby
# Comprehensive round-trip test
RSpec.describe 'Complex Document Round-Trip' do
  context 'with charts' do
    it 'preserves chart data and formatting' do
      original = Document.open('document_with_charts.docx')
      original.save('temp.docx')
      roundtrip = Document.open('temp.docx')

      # Verify chart preserved (even if we can't edit it yet)
      expect(roundtrip.elements.count { |e| e.is_a?(UnknownElement) && e.tag_name == 'chart' })
        .to eq(original.elements.count { |e| e.is_a?(UnknownElement) && e.tag_name == 'chart' })

      # Verify file sizes similar (within 1%)
      expect(File.size('temp.docx')).to be_within(0.01 * File.size('document_with_charts.docx'))
        .of(File.size('document_with_charts.docx'))
    end
  end

  context 'with SmartArt' do
    # Similar tests for SmartArt preservation
  end

  # Test with REAL documents from corpus
  Dir.glob('spec/fixtures/complex/*.docx').each do |doc_path|
    it "preserves #{File.basename(doc_path)} perfectly" do
      original_hash = Digest::SHA256.file(doc_path).hexdigest
      doc = Document.open(doc_path)
      doc.save('temp.docx')
      roundtrip_hash = Digest::SHA256.file('temp.docx').hexdigest

      expect(roundtrip_hash).to eq(original_hash),
        "Perfect round-trip: file should be byte-identical"
    end
  end
end
```

## Implementation Plan

### Phase 1: Unknown Element Preservation (Week 1-2)
1. Create `UnknownElement` class
2. Update `OoxmlDeserializer` to create `UnknownElement` for unknown tags
3. Update `OoxmlSerializer` to preserve `UnknownElement` raw XML
4. Add warning logger for unknown elements (see Feature 3)
5. **Test**: Round-trip documents with charts/SmartArt (preserve but don't edit)

### Phase 2: Chart Support (Week 3-5)
1. Create `config/ooxml/schemas/13_charts.yml` (50 chart elements)
2. Create `lib/uniword/chart.rb` class
3. Update deserializer to parse charts
4. Update serializer to write charts
5. **Test**: Read/write documents with charts

### Phase 3: Content Controls (Week 6-7)
1. Create `config/ooxml/schemas/17_content_controls.yml` (20 elements)
2. Create `lib/uniword/content_control.rb` class
3. Parsing and serialization
4. **Test**: Form documents round-trip

### Phase 4: SmartArt (Week 8-9)
1. Create `config/ooxml/schemas/15_smartart.yml` (40 elements)
2. Create `lib/uniword/smartart.rb` class
3. **Test**: SmartArt preservation

### Phase 5: Remaining Elements (Week 10-12)
1. Complete all remaining schemas
2. Test comprehensive round-trip
3. Validate against ISO/IEC 29500-1

## File Structure

```
lib/uniword/
  unknown_element.rb                   # NEW - preserve unsupported elements
  chart.rb                            # NEW - chart support
  smartart.rb                         # NEW - SmartArt support
  content_control.rb                  # NEW - form controls
  custom_xml.rb                       # NEW - custom XML binding

  serialization/
    ooxml_deserializer.rb             # ENHANCED - unknown element handling
    ooxml_serializer.rb               # ENHANCED - unknown element preservation

config/ooxml/schemas/
  13_charts.yml                       # NEW - 50 chart elements
  14_diagrams.yml                     # NEW - 10 diagram elements
  15_smartart.yml                     # NEW - 40 SmartArt elements
  16_vml.yml                          # NEW - 30 VML elements
  17_content_controls.yml             # NEW - 20 content control elements
  18_fields_advanced.yml              # NEW - 15 advanced field elements
  19_custom_xml.yml                   # NEW - 15 custom XML elements
  20_document_settings.yml            # NEW - 30 settings elements
  21_compatibility.yml                # NEW - 10 compatibility elements
  22_web_settings.yml                 # NEW - 10 web elements

spec/uniword/
  unknown_element_spec.rb             # NEW - unknown element tests
  chart_spec.rb                       # NEW - chart tests
  smartart_spec.rb                    # NEW - SmartArt tests
  content_control_spec.rb             # NEW - content control tests

spec/integration/
  complex_roundtrip_spec.rb           # NEW - comprehensive round-trip tests

spec/fixtures/complex/
  document_with_charts.docx           # NEW - test corpus
  document_with_smartart.docx         # NEW
  document_with_forms.docx            # NEW
  document_with_custom_xml.docx       # NEW
```

## Success Criteria

- [ ] 250+ OOXML elements in schema
- [ ] 100% ISO/IEC 29500-1 WordProcessingML coverage
- [ ] Complex documents round-trip perfectly (byte-identical)
- [ ] Unknown elements preserved as UnknownElement
- [ ] All tests passing (2,692 + new tests)
- [ ] Documentation complete

## Timeline

**Total**: 12 weeks
- Weeks 1-2: Unknown element preservation
- Weeks 3-5: Chart support
- Weeks 6-7: Content controls
- Weeks 8-9: SmartArt
- Weeks 10-12: Remaining elements + comprehensive testing

## Architecture Benefits

✅ **No Data Loss**: Unknown elements preserved
✅ **Incremental**: Add schema support gradually
✅ **External Config**: All elements in YAML
✅ **Clean Architecture**: UnknownElement pattern maintains SRP
✅ **MECE**: Each schema file covers distinct element set

This provides perfect round-trip immediately via UnknownElement, with gradual schema expansion for edit support.
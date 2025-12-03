# Continue Session 12: Custom XML + Bibliography Namespaces

## Context

You are continuing Uniword v2.0 development. Session 11 completed PresentationML namespace with 50 elements in record time (~1 hour). The project is now at 87.1% completion (662/760 elements, 17/30 namespaces).

**Current Status**:
- Progress: 87.1% (662/760 elements, 17/30 namespaces)
- Completed: WordProcessingML (100), Math (65), DrawingML (92), Picture (10), Relationships (5), WP Drawing (27), Content Types (3), VML (15), Office (40), VML Office (25), Document Properties (20), Word 2010 (25), Word 2013 (20), Word 2016 (15), SpreadsheetML (83), Chart (70), PresentationML (50)
- Infrastructure: SchemaLoader, ModelGenerator, autoload pattern - all working perfectly
- Velocity: ~50 elements/hour (highest velocity achieved!)
- Known Issue: ModelGenerator outputs bare type identifiers - use fix script pattern

## Session 12 Objectives

**Target**: Add 55 elements (Custom XML: 30, Bibliography: 25)
**Duration**: 3-4 hours
**Expected Progress**: 87.1% → 94.3%

### Task 1: Create Custom XML Schema (+30 elements)

**File**: `config/ooxml/schemas/customxml.yml`

Custom XML namespace (cxml:) provides support for custom XML parts in documents, enabling structured data integration.

**Namespace**:
```yaml
namespace:
  uri: 'http://schemas.openxmlformats.org/officeDocument/2006/customXml'
  prefix: 'cxml'
  description: 'Custom XML - Structured data integration and custom XML parts'
```

**Key Element Groups** (30 total):

#### 1. Custom XML Parts (8 elements)
- `customXml` - Custom XML root element
- `customXmlPr` - Custom XML properties
- `attr` - Custom attribute
- `dataStoreItem` - Data store item reference
- `schemaRef` - XML schema reference
- `xpath` - XPath expression
- `placeholder` - Placeholder text
- `showingPlcHdr` - Show placeholder flag

#### 2. Data Binding (8 elements)
- `dataBinding` - Data binding configuration
- `prefixMappings` - Namespace prefix mappings
- `xpath` - XPath query
- `storeItemID` - Store item identifier
- `customXmlMoveFromRangeStart` - Move from range start
- `customXmlMoveFromRangeEnd` - Move from range end
- `customXmlMoveToRangeStart` - Move to range start
- `customXmlMoveToRangeEnd` - Move to range end

#### 3. Custom XML Block (7 elements)
- `customXmlBlock` - Block-level custom XML
- `customXmlRun` - Run-level custom XML  
- `customXmlCell` - Cell-level custom XML
- `customXmlRow` - Row-level custom XML
- `customXmlInsRangeStart` - Insertion range start
- `customXmlInsRangeEnd` - Insertion range end
- `customXmlDelRangeStart` - Deletion range start

#### 4. Smart Tags (7 elements)
- `smartTag` - Smart tag element
- `smartTagPr` - Smart tag properties
- `smartTagType` - Smart tag type definition
- `attr` - Smart tag attribute
- `element` - Smart tag element name
- `uri` - Smart tag namespace URI
- `name` - Smart tag name

**Schema Structure Example**:
```yaml
elements:
  custom_xml:
    class_name: CustomXml
    description: 'Custom XML root element for structured data'
    attributes:
      - name: uri
        type: :string
        xml_name: uri
        xml_attribute: true
        description: 'Custom XML namespace URI'
      - name: element
        type: :string
        xml_name: element
        xml_attribute: true
        required: true
        description: 'Root element name'
      - name: custom_xml_pr
        type: CustomXmlProperties
        xml_name: customXmlPr
        description: 'Custom XML properties'
      - name: content
        type: String
        collection: true
        description: 'Custom XML content elements'

  data_binding:
    class_name: DataBinding
    description: 'Data binding configuration for custom XML'
    attributes:
      - name: prefix_mappings
        type: :string
        xml_name: prefixMappings
        xml_attribute: true
        description: 'Namespace prefix mappings'
      - name: xpath
        type: :string
        xml_name: xpath
        xml_attribute: true
        required: true
        description: 'XPath query for data selection'
      - name: store_item_id
        type: :string
        xml_name: storeItemID
        xml_attribute: true
        required: true
        description: 'Data store item identifier'
```

### Task 2: Create Bibliography Schema (+25 elements)

**File**: `config/ooxml/schemas/bibliography.yml`

Bibliography namespace (b:) provides citation and bibliography management for academic and professional documents.

**Namespace**:
```yaml
namespace:
  uri: 'http://schemas.openxmlformats.org/officeDocument/2006/bibliography'
  prefix: 'b'
  description: 'Bibliography - Citation and reference management'
```

**Key Element Groups** (25 total):

#### 1. Source Management (8 elements)
- `sources` - Bibliography sources list
- `source` - Individual source entry
- `sourceType` - Type of source (book, article, website, etc.)
- `tag` - Source identifier tag
- `guid` - Globally unique identifier
- `lcid` - Locale identifier
- `author` - Author information
- `title` - Source title

#### 2. Author Information (6 elements)
- `author` - Author container
- `nameList` - List of names
- `person` - Individual person
- `corporate` - Corporate author
- `first` - First name
- `last` - Last name

#### 3. Publication Details (6 elements)
- `year` - Publication year
- `month` - Publication month
- `day` - Publication day
- `publisher` - Publisher name
- `city` - Publication city
- `pages` - Page range

#### 4. Additional Fields (5 elements)
- `volumeNumber` - Volume number
- `issue` - Issue number
- `edition` - Edition information
- `url` - Web URL
- `refOrder` - Reference order

**Schema Structure Example**:
```yaml
elements:
  sources:
    class_name: Sources
    description: 'Container for bibliography sources'
    attributes:
      - name: selected_style
        type: :string
        xml_name: SelectedStyle
        xml_attribute: true
        description: 'Selected citation style'
      - name: style_name
        type: :string
        xml_name: StyleName
        xml_attribute: true
        description: 'Citation style name'
      - name: source
        type: Source
        xml_name: Source
        collection: true
        description: 'Individual bibliography sources'

  source:
    class_name: Source
    description: 'Individual bibliography source entry'
    attributes:
      - name: source_type
        type: :string
        xml_name: SourceType
        required: true
        description: 'Type of source (Book, JournalArticle, etc.)'
      - name: tag
        type: :string
        xml_name: Tag
        required: true
        description: 'Unique identifier tag'
      - name: guid
        type: :string
        xml_name: GUID
        description: 'Globally unique identifier'
      - name: lcid
        type: :integer
        xml_name: LCID
        description: 'Locale identifier'
      - name: author
        type: Author
        xml_name: Author
        description: 'Author information'
      - name: title
        type: :string
        xml_name: Title
        required: true
        description: 'Source title'
      - name: year
        type: :string
        xml_name: Year
        description: 'Publication year'
      - name: publisher
        type: :string
        xml_name: Publisher
        description: 'Publisher name'
```

### Task 3: Generate Classes

Use proven generation pattern with type fix:

```ruby
require_relative 'lib/uniword/schema/model_generator'

# Generate Custom XML
gen1 = Uniword::Schema::ModelGenerator.new('customxml')
results1 = gen1.generate_all
puts "Generated #{results1.size} Custom XML classes"

# Generate Bibliography
gen2 = Uniword::Schema::ModelGenerator.new('bibliography')
results2 = gen2.generate_all
puts "Generated #{results2.size} Bibliography classes"
```

**IMPORTANT**: After generation, run type fix script:
```ruby
# Fix Custom XML types
Dir.glob('lib/generated/customxml/*.rb').each do |file|
  content = File.read(file)
  content.gsub!(/, integer$/, ', :integer')
  content.gsub!(/, string$/, ', :string')
  File.write(file, content) if content != File.read(file)
end

# Fix Bibliography types
Dir.glob('lib/generated/bibliography/*.rb').each do |file|
  content = File.read(file)
  content.gsub!(/, integer$/, ', :integer')
  content.gsub!(/, string$/, ', :string')
  File.write(file, content) if content != File.read(file)
end
```

### Task 4: Create Autoload Indexes

**File 1**: `lib/generated/customxml.rb`
**File 2**: `lib/generated/bibliography.rb`

Pattern:
```ruby
module Uniword
  module Generated
    module Customxml
      autoload :CustomXml, File.expand_path('customxml/custom_xml', __dir__)
      autoload :DataBinding, File.expand_path('customxml/data_binding', __dir__)
      # ... 28 more autoloads
    end
  end
end
```

### Task 5: Test Everything

Create `test_session12_autoload.rb`:
```ruby
require_relative 'lib/generated/customxml'
require_relative 'lib/generated/bibliography'

puts "Testing Custom XML namespace (cxml:)..."
sample_classes = [
  Uniword::Generated::Customxml::CustomXml,
  Uniword::Generated::Customxml::DataBinding,
  Uniword::Generated::Customxml::CustomXmlProperties,
  Uniword::Generated::Customxml::SmartTag
]
puts "✅ Loaded #{sample_classes.size} Custom XML classes"

puts "\nTesting Bibliography namespace (b:)..."
sample_classes = [
  Uniword::Generated::Bibliography::Sources,
  Uniword::Generated::Bibliography::Source,
  Uniword::Generated::Bibliography::Author,
  Uniword::Generated::Bibliography::NameList
]
puts "✅ Loaded #{sample_classes.size} Bibliography classes"
```

### Task 6: Update Documentation

1. Update `docs/V2.0_IMPLEMENTATION_STATUS.md`:
   - Progress: 87.1% → 94.3%
   - Elements: 662 → 717 (+55)
   - Namespaces: 17 → 19 (+2)

2. Create `SESSION_12_SUMMARY.md`

3. Move Session 11 docs to `old-docs/`:
   - `CONTINUE_SESSION_11.md`
   - `SESSION_11_SUMMARY.md`
   - `generate_session11_classes.rb`
   - `test_session11_autoload.rb`
   - `fix_presentationml_types.rb`

## Critical Reminders

1. **Pattern 0 Compliance**: ALWAYS declare attributes BEFORE xml blocks
2. **Type Consistency**: Use `:string` and `:integer` (symbols) for primitives
3. **Type Fix Required**: Run fix script after generation (ModelGenerator bug)
4. **Collections**: Use `collection: true` for arrays
5. **Cross-Namespace**: Use `String` type for cross-namespace references
6. **Namespace URI**: Use exact OpenXML namespace URI
7. **Testing**: Verify autoload after generation

## Expected Deliverables

1. ✅ `customxml.yml` created (30 elements)
2. ✅ `bibliography.yml` created (25 elements)
3. ✅ 55+ new classes generated
4. ✅ 2 autoload indexes created
5. ✅ All tests passing
6. ✅ Documentation updated
7. ✅ SESSION_12_SUMMARY.md created

## Success Criteria

- [ ] Custom XML namespace complete (30 elements)
- [ ] Bibliography namespace complete (25 elements)
- [ ] All classes generated without errors
- [ ] Type fix applied successfully
- [ ] Autoload working correctly
- [ ] Pattern 0 compliance: 100%
- [ ] Zero syntax errors
- [ ] Progress: 94.3% overall (717/760 elements)

## Architecture Notes

### Custom XML Integration Strategy

Custom XML namespace is critical for:
1. **Structured Data**: Embed structured business data in documents
2. **Data Binding**: Connect document content to external data sources
3. **Content Controls**: Smart forms and dynamic content
4. **Smart Tags**: Context-aware metadata tagging
5. **XML Parts**: Store and retrieve custom XML parts

### Bibliography Integration Strategy

Bibliography namespace enables:
1. **Citation Management**: Insert and manage citations
2. **Bibliography Generation**: Auto-generate bibliographies
3. **Style Support**: Multiple citation styles (APA, MLA, Chicago, etc.)
4. **Source Types**: Books, articles, websites, reports, etc.
5. **Metadata Management**: Author, title, publisher, date, etc.

### Namespace Dependencies

```
Custom XML (cxml:) relies on:
- WordProcessingML (w:) - for document integration
- Relationships (r:) - for linking XML parts

Bibliography (b:) relies on:
- WordProcessingML (w:) - for citation fields
- No other namespaces (self-contained)
```

## Phase 2 Progress Tracker

### Completed (717/760 = 94.3% after Session 12)
- ✅ Sessions 1-11: 662 elements
- 🎯 Session 12: Custom XML + Bibliography (55 elements)

### Remaining After Session 12 (43/760 = 5.7% remaining)
Final namespaces:
- Glossary (g:): 20 elements
- Shared Types (st:): 15 elements
- Document Variables (dv:): 8 elements

**Timeline**: 1 more session to complete Phase 2!

## Performance Target

With velocity of 50+ elements/hour:
- Session 12: 55 elements → 3-4 hours
- Session 13: 43 elements → 2-3 hours
- Phase 2 completion: End of Day 4 (3 days ahead of schedule!)

## Next Session Preview

### Session 13: Final Namespaces
- **Target**: ~43 elements (Glossary + Shared Types + Document Variables)
- **Focus**: Complete remaining namespaces
- **Expected Progress**: 94.3% → 100.0%
- **Milestone**: Phase 2 COMPLETE! 🎉

## Critical Success Factors

1. **Type Fix Script**: Create reusable script for both namespaces
2. **Schema Accuracy**: Carefully model Custom XML and Bibliography structures
3. **Cross-References**: Handle relationships between sources and citations
4. **Testing Thoroughness**: Verify all generated classes load correctly
5. **Documentation**: Complete and accurate schema descriptions

## Known Issues & Solutions

### Issue 1: ModelGenerator Type Bug
**Problem**: Outputs `integer` instead of `:integer`
**Solution**: Use fix script pattern from Session 11
**Script Template**:
```ruby
Dir.glob('lib/generated/NAMESPACE/*.rb').each do |file|
  content = File.read(file)
  original = content.dup
  content.gsub!(/, integer$/, ', :integer')
  content.gsub!(/, string$/, ', :string')
  File.write(file, content) if content != original
end
```

### Issue 2: XML Attribute Mapping
**Problem**: Need to distinguish between element attributes and XML attributes
**Solution**: Use `xml_attribute: true` for XML attributes, `xml_name` for elements

### Issue 3: Namespace Prefix Handling
**Problem**: Custom XML and Bibliography use different conventions
**Solution**: Follow exact OOXML specification for each namespace

Good luck with Session 12! 🚀
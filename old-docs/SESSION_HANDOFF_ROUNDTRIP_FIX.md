# Session Handoff: Round-Trip Fidelity Fix

## Date
2025-01-14

## Executive Summary

The Uniword round-trip implementation has fundamental architectural problems that prevent perfect document fidelity. The deserializer uses **Nokogiri directly** for XML parsing instead of using **lutaml-model**, which is the correct approach for round-trip preservation. This document outlines the problems, the correct architecture, and a complete implementation plan.

## 1. Architectural Problems Discovered

### 1.1 Core Problem: Manual XML Parsing via Nokogiri

**Current State:** [`OoxmlDeserializer`](lib/uniword/serialization/ooxml_deserializer.rb:23) uses Nokogiri's manual XML parsing:

```ruby
# lib/uniword/serialization/ooxml_deserializer.rb:152
xml_doc = Nokogiri::XML(xml_string)
body_node = xml_doc.at_xpath('//w:body', NAMESPACES)
```

**Problem:** Manual parsing loses information that wasn't explicitly coded for. Every XML element, attribute, and namespace must be manually handled. Any unhandled elements require custom preservation logic.

**Impact:**
- New OOXML features require code changes
- Round-trip fidelity depends on manually preserving every detail
- High maintenance burden as OOXML evolves
- Prone to data loss when encountering unexpected elements

### 1.2 Hash-Based Metadata Storage

**Current State:** Document metadata stored as Hash:

```ruby
# In OoxmlDeserializer
document.metadata[:title] = title_node.text
document.metadata[:creator] = creator_node.text
```

**Problem:** Hash doesn't provide:
- Type safety
- Validation
- XML serialization/deserialization
- Round-trip preservation of XML structure

**Correct Approach:** Use lutaml-model classes like [`Theme`](lib/uniword/theme.rb:20) and [`StyleSet`](lib/uniword/styleset.rb:20)

### 1.3 Missing Lutaml-Model Classes for OOXML Parts

**Current State:** Only [`Theme`](lib/uniword/theme.rb:20) and [`StyleSet`](lib/uniword/styleset.rb:20) use lutaml-model properly.

**Missing Lutaml-Model Classes:**
- Core properties (`docProps/core.xml`)
- App properties (`docProps/app.xml`)
- Relationships (`.rels` files)
- Content types (`[Content_Types].xml`)
- Settings (`word/settings.xml`)
- Numbering (`word/numbering.xml`)
- Footnotes/Endnotes (`word/footnotes.xml`, `word/endnotes.xml`)
- Comments (`word/comments.xml`)
- Custom XML parts

### 1.4 Inconsistent Architecture

**Current Inconsistency:**
- [`Theme`](lib/uniword/theme.rb:20) uses lutaml-model ✅
- [`StyleSet`](lib/uniword/styleset.rb:20) uses lutaml-model ✅
- Document body uses manual Nokogiri ❌
- Metadata uses Hash ❌
- Relationships use Hash ❌

**Result:** Fragmented architecture that's hard to maintain and doesn't guarantee round-trip fidelity.

## 2. The Correct Lutaml-Model-Based Approach

### 2.1 Why Lutaml-Model?

Lutaml-model provides:
1. **Declarative XML mapping** - Define structure once, get serialization/deserialization
2. **Round-trip preservation** - Automatically preserves all XML structure
3. **Type safety** - Strong typing prevents data corruption
4. **Validation** - Built-in validation of data structures
5. **Maintainability** - Changes to OOXML schema only require model updates

### 2.2 Example: Theme (Correct Implementation)

[`Theme`](lib/uniword/theme.rb:20) shows the correct pattern:

```ruby
class Theme < Lutaml::Model::Serializable
  xml do
    root 'theme'
    namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

    map_attribute 'name', to: :name
    map_element 'themeElements', to: :theme_elements
  end

  attribute :name, :string, default: -> { 'Office Theme' }
  # ... other attributes
end
```

**Benefits:**
- Serialization: `theme.to_xml` produces OOXML
- Deserialization: `Theme.from_xml(xml_string)` parses OOXML
- Round-trip: Preserves all XML structure automatically

### 2.3 Architecture Comparison

#### Current (Broken) Architecture
```
OOXML File → Nokogiri → Manual Parsing → Uniword Models → Manual Serialization → OOXML File
                ↑                                                    ↑
            Data Loss                                           Data Loss
```

#### Correct Architecture
```
OOXML File → Lutaml-Model → Uniword Models → Lutaml-Model → OOXML File
                         (Perfect Preservation)
```

## 3. Detailed Implementation Plan

### Phase 1: Create Core Lutaml-Model Classes

#### 3.1 Metadata Models

Create [`lib/uniword/ooxml/core_properties.rb`](lib/uniword/ooxml/core_properties.rb):
```ruby
module Uniword
  module Ooxml
    class CoreProperties < Lutaml::Model::Serializable
      xml do
        root 'coreProperties'
        namespace 'http://schemas.openxmlformats.org/package/2006/metadata/core-properties', 'cp'

        map_element 'title', to: :title, prefix: 'dc', namespace: 'http://purl.org/dc/elements/1.1/'
        map_element 'subject', to: :subject, prefix: 'dc', namespace: 'http://purl.org/dc/elements/1.1/'
        map_element 'creator', to: :creator, prefix: 'dc', namespace: 'http://purl.org/dc/elements/1.1/'
        map_element 'keywords', to: :keywords
        map_element 'description', to: :description
        map_element 'lastModifiedBy', to: :last_modified_by
        map_element 'created', to: :created, prefix: 'dcterms', namespace: 'http://purl.org/dc/terms/'
        map_element 'modified', to: :modified, prefix: 'dcterms', namespace: 'http://purl.org/dc/terms/'
        map_element 'revision', to: :revision
      end

      attribute :title, :string
      attribute :subject, :string
      attribute :creator, :string
      attribute :keywords, :string
      attribute :description, :string
      attribute :last_modified_by, :string
      attribute :created, :string
      attribute :modified, :string
      attribute :revision, :string
    end
  end
end
```

Create [`lib/uniword/ooxml/app_properties.rb`](lib/uniword/ooxml/app_properties.rb):
```ruby
module Uniword
  module Ooxml
    class AppProperties < Lutaml::Model::Serializable
      xml do
        root 'Properties'
        namespace 'http://schemas.openxmlformats.org/officeDocument/2006/extended-properties', 'app'

        map_element 'Application', to: :application
        map_element 'Company', to: :company
        map_element 'TotalTime', to: :total_time
        map_element 'ScaleCrop', to: :scale_crop
      end

      attribute :application, :string
      attribute :company, :string
      attribute :total_time, :string
      attribute :scale_crop, :string
    end
  end
end
```

#### 3.2 Relationships Model

Create [`lib/uniword/ooxml/relationships.rb`](lib/uniword/ooxml/relationships.rb):
```ruby
module Uniword
  module Ooxml
    class Relationship < Lutaml::Model::Serializable
      xml do
        root 'Relationship'
        namespace 'http://schemas.openxmlformats.org/package/2006/relationships', 'r'

        map_attribute 'Id', to: :id
        map_attribute 'Type', to: :type
        map_attribute 'Target', to: :target
        map_attribute 'TargetMode', to: :target_mode
      end

      attribute :id, :string
      attribute :type, :string
      attribute :target, :string
      attribute :target_mode, :string
    end

    class Relationships < Lutaml::Model::Serializable
      xml do
        root 'Relationships'
        namespace 'http://schemas.openxmlformats.org/package/2006/relationships', 'r'

        map_element 'Relationship', to: :relationships
      end

      attribute :relationships, Relationship, collection: true, default: -> { [] }
    end
  end
end
```

#### 3.3 Content Types Model

Create [`lib/uniword/ooxml/content_types.rb`](lib/uniword/ooxml/content_types.rb):
```ruby
module Uniword
  module Ooxml
    class ContentType < Lutaml::Model::Serializable
      xml do
        root 'Override'
        namespace 'http://schemas.openxmlformats.org/package/2006/content-types', 'ct'

        map_attribute 'PartName', to: :part_name
        map_attribute 'ContentType', to: :content_type
      end

      attribute :part_name, :string
      attribute :content_type, :string
    end

    class ContentTypes < Lutaml::Model::Serializable
      xml do
        root 'Types'
        namespace 'http://schemas.openxmlformats.org/package/2006/content-types', 'ct'

        map_element 'Default', to: :defaults
        map_element 'Override', to: :overrides
      end

      attribute :defaults, ContentType, collection: true, default: -> { [] }
      attribute :overrides, ContentType, collection: true, default: -> { [] }
    end
  end
end
```

#### 3.4 Document.xml Core Model

Create [`lib/uniword/ooxml/w_document.rb`](lib/uniword/ooxml/w_document.rb):
```ruby
module Uniword
  module Ooxml
    # Represents the complete word/document.xml structure
    class WDocument < Lutaml::Model::Serializable
      xml do
        root 'document'
        namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

        map_element 'body', to: :body
        map_element 'background', to: :background
      end

      attribute :body, WBody
      attribute :background, WBackground
    end

    class WBody < Lutaml::Model::Serializable
      xml do
        root 'body'
        namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

        # Mixed content - paragraphs, tables, sections
        map_element 'p', to: :paragraphs
        map_element 'tbl', to: :tables
        map_element 'sectPr', to: :section_properties
      end

      attribute :paragraphs, WParagraph, collection: true, default: -> { [] }
      attribute :tables, WTable, collection: true, default: -> { [] }
      attribute :section_properties, WSectionProperties
    end

    class WParagraph < Lutaml::Model::Serializable
      xml do
        root 'p'
        namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

        map_element 'pPr', to: :properties
        map_element 'r', to: :runs
        map_element 'hyperlink', to: :hyperlinks
        map_element 'bookmarkStart', to: :bookmark_starts
        map_element 'bookmarkEnd', to: :bookmark_ends
      end

      attribute :properties, WParagraphProperties
      attribute :runs, WRun, collection: true, default: -> { [] }
      attribute :hyperlinks, WHyperlink, collection: true, default: -> { [] }
      attribute :bookmark_starts, WBookmarkStart, collection: true, default: -> { [] }
      attribute :bookmark_ends, WBookmarkEnd, collection: true, default: -> { [] }
    end

    # ... Continue for all OOXML elements
  end
end
```

#### 3.5 Complete OOXML Element Models

**Required Classes:**
- `WRun` - Text runs with formatting
- `WRunProperties` - Run formatting properties
- `WParagraphProperties` - Paragraph formatting properties
- `WTable` - Tables
- `WTableRow` - Table rows
- `WTableCell` - Table cells
- `WTableProperties` - Table formatting
- `WSectionProperties` - Section properties
- `WBookmarkStart` / `WBookmarkEnd` - Bookmarks
- `WHyperlink` - Hyperlinks
- `WDrawing` - Images/diagrams
- `WMath` - Math equations (with proper namespace)

### Phase 2: Document Package Model

#### 2.1 Create Package Manager

Create [`lib/uniword/ooxml/package.rb`](lib/uniword/ooxml/package.rb):
```ruby
module Uniword
  module Ooxml
    # Represents complete OOXML package structure
    class Package
      attr_accessor :document        # WDocument
      attr_accessor :styles          # WStyles
      attr_accessor :theme           # Theme
      attr_accessor :numbering       # WNumbering
      attr_accessor :settings        # WSettings
      attr_accessor :core_properties # CoreProperties
      attr_accessor :app_properties  # AppProperties
      attr_accessor :relationships   # Hash of path => Relationships
      attr_accessor :content_types   # ContentTypes
      attr_accessor :media_files     # Hash of path => binary data

      # Load from ZIP file
      def self.from_file(path)
        extractor = Infrastructure::ZipExtractor.new
        parts = extractor.extract(path)
        from_parts(parts)
      end

      # Load from extracted parts
      def self.from_parts(parts)
        package = new

        # Parse each part using appropriate lutaml-model class
        package.document = WDocument.from_xml(parts['word/document.xml'])
        package.styles = WStyles.from_xml(parts['word/styles.xml']) if parts['word/styles.xml']
        package.theme = Theme.from_xml(parts['word/theme/theme1.xml']) if parts['word/theme/theme1.xml']
        package.core_properties = CoreProperties.from_xml(parts['docProps/core.xml']) if parts['docProps/core.xml']
        # ... parse all parts

        package
      end

      # Convert to hash of XML parts
      def to_parts
        parts = {}

        parts['word/document.xml'] = document.to_xml if document
        parts['word/styles.xml'] = styles.to_xml if styles
        parts['word/theme/theme1.xml'] = theme.to_xml if theme
        parts['docProps/core.xml'] = core_properties.to_xml if core_properties
        # ... serialize all parts

        parts
      end

      # Save to file
      def save(path)
        parts = to_parts
        packager = Infrastructure::ZipPackager.new
        packager.package(parts, path)
      end
    end
  end
end
```

### Phase 3: Unified Deserializer/Serializer

#### 3.1 New Lutaml-Based Deserializer

Create [`lib/uniword/serialization/ooxml_package_deserializer.rb`](lib/uniword/serialization/ooxml_package_deserializer.rb):
```ruby
module Uniword
  module Serialization
    # Deserialize OOXML using lutaml-model for perfect round-trip
    class OoxmlPackageDeserializer
      # Deserialize complete package
      def deserialize(file_path_or_parts)
        # Load OOXML package
        package = if file_path_or_parts.is_a?(String)
          Ooxml::Package.from_file(file_path_or_parts)
        else
          Ooxml::Package.from_parts(file_path_or_parts)
        end

        # Convert OOXML models to Uniword document model
        convert_to_document(package)
      end

      private

      def convert_to_document(package)
        document = Document.new

        # Convert body
        document.body = convert_body(package.document.body)

        # Convert metadata
        document.metadata = convert_metadata(package.core_properties, package.app_properties)

        # Attach theme
        document.theme = package.theme

        # Attach raw package for round-trip
        document.instance_variable_set(:@_ooxml_package, package)

        document
      end

      def convert_body(w_body)
        body = Body.new

        w_body.paragraphs.each do |w_para|
          body.add_paragraph(convert_paragraph(w_para))
        end

        w_body.tables.each do |w_table|
          body.add_table(convert_table(w_table))
        end

        body
      end
    end
  end
end
```

#### 3.2 New Lutaml-Based Serializer

Create [`lib/uniword/serialization/ooxml_package_serializer.rb`](lib/uniword/serialization/ooxml_package_serializer.rb):
```ruby
module Uniword
  module Serialization
    # Serialize Uniword document to OOXML using lutaml-model
    class OoxmlPackageSerializer
      # Serialize document to OOXML package
      def serialize(document, output_path)
        # Get original package if available (for round-trip)
        package = document.instance_variable_get(:@_ooxml_package) || create_new_package

        # Update package from document
        update_package_from_document(package, document)

        # Save package
        package.save(output_path)
      end

      private

      def update_package_from_document(package, document)
        # Update body
        package.document.body = convert_to_w_body(document.body)

        # Update metadata
        update_metadata(package, document.metadata)

        # Update theme if changed
        package.theme = document.theme if document.theme
      end
    end
  end
end
```

### Phase 4: Migration Strategy

#### 4.1 Backward Compatibility

Keep existing [`OoxmlDeserializer`](lib/uniword/serialization/ooxml_deserializer.rb:23) temporarily:
- Add deprecation warnings
- Provide migration path
- Document differences

#### 4.2 Feature Flag

```ruby
# lib/uniword/config.rb
module Uniword
  class Config
    # Enable new lutaml-based round-trip
    attr_accessor :use_lutaml_roundtrip

    def initialize
      @use_lutaml_roundtrip = false  # Default: maintain compatibility
    end
  end
end
```

#### 4.3 Gradual Migration

```ruby
# lib/uniword/document.rb
def self.from_file(path)
  if Uniword.config.use_lutaml_roundtrip
    # New lutaml-based approach
    deserializer = Serialization::OoxmlPackageDeserializer.new
    deserializer.deserialize(path)
  else
    # Legacy Nokogiri approach
    deserializer = Serialization::OoxmlDeserializer.new
    # ... existing code
  end
end
```

## 4. Current Status

### 4.1 What's Done Correctly ✅

1. **Theme Implementation** - [`Theme`](lib/uniword/theme.rb:20) uses lutaml-model properly
2. **StyleSet Implementation** - [`StyleSet`](lib/uniword/styleset.rb:20) uses lutaml-model properly
3. **Unknown Element Preservation** - [`UnknownElement`](lib/uniword/unknown_element.rb:36) class exists
4. **Warning System** - Warning collector integrated

### 4.2 What Needs Redesign ❌

1. **Complete Deserializer Rewrite** - Replace [`OoxmlDeserializer`](lib/uniword/serialization/ooxml_deserializer.rb:23) with lutaml-model
2. **Metadata Models** - Create CoreProperties and AppProperties classes
3. **Relationships Models** - Create Relationship classes
4. **Content Types Models** - Create ContentTypes classes
5. **Complete OOXML Element Models** - Create WDocument, WBody, WParagraph, etc.
6. **Package Manager** - Create Package class to manage all parts
7. **Serializer Update** - Update OoxmlSerializer to use lutaml-model

### 4.3 Dependencies

Required gems (already in use):
- `lutaml-model ~> 0.7` - Core serialization framework
- `nokogiri` - XML parsing (used by lutaml-model)
- `rubyzip` - ZIP file handling

## 5. Next Steps with Clear Priorities

### Priority 1: Foundation (Week 1)

1. **Create OOXML namespace module**
   - File: `lib/uniword/ooxml.rb`
   - Purpose: Namespace for all OOXML models

2. **Create core property models**
   - Files: `lib/uniword/ooxml/core_properties.rb`, `lib/uniword/ooxml/app_properties.rb`
   - Test with existing documents

3. **Create relationship models**
   - File: `lib/uniword/ooxml/relationships.rb`
   - Test serialization/deserialization

4. **Create content types model**
   - File: `lib/uniword/ooxml/content_types.rb`
   - Validate against real OOXML files

### Priority 2: Document Structure (Week 2)

5. **Create WDocument model**
   - File: `lib/uniword/ooxml/w_document.rb`
   - Start with basic body structure

6. **Create paragraph/run models**
   - Files: `lib/uniword/ooxml/w_paragraph.rb`, `lib/uniword/ooxml/w_run.rb`
   - Complete property classes

7. **Create table models**
   - Files: `lib/uniword/ooxml/w_table.rb`, etc.
   - Include all table-related classes

### Priority 3: Package Management (Week 3)

8. **Create Package class**
   - File: `lib/uniword/ooxml/package.rb`
   - Coordinate all OOXML parts

9. **Create new deserializer**
   - File: `lib/uniword/serialization/ooxml_package_deserializer.rb`
   - Use Package class

10. **Create new serializer**
    - File: `lib/uniword/serialization/ooxml_package_serializer.rb`
    - Perfect round-trip

### Priority 4: Testing & Migration (Week 4)

11. **Comprehensive round-trip tests**
    - Test with ISO 8601 documents
    - Verify byte-level fidelity

12. **Add feature flag**
    - Enable gradual migration
    - Keep backward compatibility

13. **Documentation**
    - Migration guide
    - API documentation
    - Examples

## 6. Testing Strategy

### 6.1 Unit Tests

For each lutaml-model class:
```ruby
RSpec.describe Uniword::Ooxml::CoreProperties do
  it 'serializes to XML' do
    props = described_class.new(title: 'Test', creator: 'Author')
    xml = props.to_xml
    expect(xml).to include('<dc:title>Test</dc:title>')
  end

  it 'deserializes from XML' do
    xml = '<cp:coreProperties>...</cp:coreProperties>'
    props = described_class.from_xml(xml)
    expect(props.title).to eq('Test')
  end

  it 'round-trips perfectly' do
    original_xml = File.read('spec/fixtures/core.xml')
    props = described_class.from_xml(original_xml)
    regenerated_xml = props.to_xml
    expect(regenerated_xml).to eq(original_xml)
  end
end
```

### 6.2 Integration Tests

```ruby
RSpec.describe 'Perfect Round-Trip' do
  let(:test_doc) { 'spec/fixtures/iso-wd-8601-2-2026.docx' }

  it 'preserves document exactly' do
    # Load
    doc = Uniword::Document.from_file(test_doc)

    # Save
    output = 'tmp/roundtrip.docx'
    doc.save(output)

    # Compare
    original_package = Uniword::Ooxml::Package.from_file(test_doc)
    roundtrip_package = Uniword::Ooxml::Package.from_file(output)

    expect(roundtrip_package.to_parts).to eq(original_package.to_parts)
  end
end
```

### 6.3 Performance Tests

```ruby
RSpec.describe 'Performance' do
  it 'deserializes large documents efficiently' do
    expect {
      Uniword::Document.from_file('large_document.docx')
    }.to perform_under(5.seconds)
  end
end
```

## 7. Success Criteria

### 7.1 Technical Criteria

- ✅ All OOXML parts use lutaml-model
- ✅ No manual Nokogiri parsing in deserializer
- ✅ No Hash-based metadata
- ✅ 100% round-trip fidelity for test documents
- ✅ All tests passing

### 7.2 Quality Criteria

- ✅ Code follows Ruby style guide
- ✅ Comprehensive RSpec tests
- ✅ Documentation complete
- ✅ No deprecation warnings
- ✅ Performance acceptable

### 7.3 Validation Criteria

- ✅ ISO 8601 documents round-trip perfectly
- ✅ Math equations preserved
- ✅ Images preserved
- ✅ Styles preserved
- ✅ Themes preserved
- ✅ Metadata preserved

## 8. Files to Create

### New Model Files
```
lib/uniword/ooxml.rb
lib/uniword/ooxml/core_properties.rb
lib/uniword/ooxml/app_properties.rb
lib/uniword/ooxml/relationships.rb
lib/uniword/ooxml/content_types.rb
lib/uniword/ooxml/w_document.rb
lib/uniword/ooxml/w_body.rb
lib/uniword/ooxml/w_paragraph.rb
lib/uniword/ooxml/w_paragraph_properties.rb
lib/uniword/ooxml/w_run.rb
lib/uniword/ooxml/w_run_properties.rb
lib/uniword/ooxml/w_table.rb
lib/uniword/ooxml/w_table_row.rb
lib/uniword/ooxml/w_table_cell.rb
lib/uniword/ooxml/w_table_properties.rb
lib/uniword/ooxml/w_section_properties.rb
lib/uniword/ooxml/w_bookmark.rb
lib/uniword/ooxml/w_hyperlink.rb
lib/uniword/ooxml/w_drawing.rb
lib/uniword/ooxml/w_math.rb
lib/uniword/ooxml/w_styles.rb
lib/uniword/ooxml/w_numbering.rb
lib/uniword/ooxml/w_settings.rb
lib/uniword/ooxml/package.rb
```

### New Serialization Files
```
lib/uniword/serialization/ooxml_package_deserializer.rb
lib/uniword/serialization/ooxml_package_serializer.rb
```

### Test Files
```
spec/uniword/ooxml/core_properties_spec.rb
spec/uniword/ooxml/app_properties_spec.rb
spec/uniword/ooxml/relationships_spec.rb
spec/uniword/ooxml/package_spec.rb
spec/uniword/serialization/ooxml_package_deserializer_spec.rb
spec/uniword/serialization/ooxml_package_serializer_spec.rb
spec/uniword/round_trip_spec.rb
```

## 9. Key Architectural Decision Records

### ADR-001: Use Lutaml-Model for All OOXML Parts

**Context:** Need perfect round-trip fidelity

**Decision:** Use lutaml-model for all OOXML XML parts, not manual Nokogiri

**Consequences:**
- ✅ Perfect round-trip preservation
- ✅ Reduced maintenance burden
- ✅ Type safety
- ⚠️ Migration effort required

### ADR-002: Package-Based Architecture

**Context:** OOXML is a package of multiple XML files

**Decision:** Create Package class to manage all parts cohesively

**Consequences:**
- ✅ Clean separation of concerns
- ✅ Easier testing
- ✅ Better round-trip control
- ⚠️ Additional abstraction layer

### ADR-003: Gradual Migration Strategy

**Context:** Existing code uses manual Nokogiri

**Decision:** Keep legacy code temporarily with feature flag

**Consequences:**
- ✅ Backward compatibility maintained
- ✅ Gradual migration possible
- ⚠️ Dual maintenance burden temporarily

## 10. References

### Lutaml-Model Documentation
- README: `$HOME/src/lutaml/lutaml-model/README.adoc`
- Version: `~> 0.7`

### OOXML Standards
- ECMA-376: Office Open XML File Formats
- Namespace reference in [`lib/uniword/ooxml/namespaces.rb`](lib/uniword/ooxml/namespaces.rb:5)

### Existing Implementations
- [`Theme`](lib/uniword/theme.rb:20) - Good example of lutaml-model usage
- [`StyleSet`](lib/uniword/styleset.rb:20) - Good example of lutaml-model usage
- [`OoxmlDeserializer`](lib/uniword/serialization/ooxml_deserializer.rb:23) - Legacy manual parsing (to be replaced)

## 11. Contact & Handoff Notes

### Current Implementation Issues
1. Math namespace added but manual parsing still used
2. Bookmark elements partially supported but not as lutaml-model
3. Metadata stored as Hash instead of proper models
4. No round-trip guarantee due to manual parsing

### Key Insight
The **root problem** is architectural: using Nokogiri directly instead of lutaml-model. This cannot be fixed with incremental changes—a complete rewrite using lutaml-model is required.

### Next Developer Should Start With
1. Read lutaml-model README at `$HOME/src/lutaml/lutaml-model/README.adoc`
2. Study [`Theme`](lib/uniword/theme.rb:20) implementation as reference
3. Create one complete model (e.g., CoreProperties) with tests
4. Validate round-trip before proceeding to other models

### Critical Success Factors
- **Don't use Nokogiri directly** - Use lutaml-model
- **Model everything** - Every XML element needs a class
- **Test round-trip** - Every model must round-trip perfectly
- **Follow Theme pattern** - Use existing good examples

---

**Document Version:** 1.0
**Last Updated:** 2025-01-14
**Status:** Ready for implementation
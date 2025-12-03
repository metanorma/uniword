// ... existing code ...
# Uniword: System Architecture

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Uniword Gem                            │
│                   (Public API Layer)                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌────────────────┐           ┌──────────────────┐         │
│  │  Format Layer  │           │  Document Layer  │         │
│  │                │           │                  │         │
│  │ - DOCX Handler │◄──────────┤ - Document Model │         │
│  │   (Read/Write) │           │   (lutaml-model) │         │
│  │ - MHTML Handler│           │ - Element Models │         │
│  │   (Read/Write) │           │ - Style Models   │         │
│  └────────────────┘           └──────────────────┘         │
│         │                              │                   │
│         ▼                              ▼                   │
│  ┌────────────────┐           ┌──────────────────┐         │
│  │ Serialization  │           │  Component Layer │         │
│  │     Layer      │           │                  │         │
│  │                │           │ - Paragraphs     │         │
│  │ - XML Parser/  │◄──────────┤ - Tables         │         │
│  │   Serializer   │           │ - Images         │         │
│  │   (lutaml)     │           │ - Lists          │         │
│  │ - MIME Handler │           │ - Styles         │         │
│  │ - ZIP Handler  │           │ - Runs           │         │
│  └────────────────┘           └──────────────────┘         │
└─────────────────────────────────────────────────────────────┘
```

## Core Design Principles

### 1. SOLID Principles
- **Single Responsibility**: Each class has one clear purpose
- **Open/Closed**: Extensible without modification (e.g., Element registry)
- **Liskov Substitution**: Element subtypes properly substitutable
- **Interface Segregation**: Focused interfaces (Serializable, Visitable)
- **Dependency Inversion**: Depend on abstractions (Format handlers)

### 2. MECE Architecture
All components are **Mutually Exclusive, Collectively Exhaustive**:
- No overlap in responsibilities
- Complete coverage of functionality
- Clear separation of concerns

### 3. Model-Driven Design
- Document structure is pure Ruby objects
- Serialization is separate from model
- Format-agnostic domain models

## Key Architecture Layers

### Layer 1: Document Model (`lib/uniword/`)

**Primary Classes:**
- [`Document`](../lib/uniword/document.rb) - Root document container
- [`Body`](../lib/uniword/body.rb) - Document body with elements
- [`Paragraph`](../lib/uniword/paragraph.rb) - Text paragraphs
- [`Run`](../lib/uniword/run.rb) - Text runs with formatting
- [`Table`](../lib/uniword/table.rb) - Table structures
- [`Style`](../lib/uniword/style.rb) - Style definitions

**Characteristics:**
- Inherit from `Lutaml::Model::Serializable`
- Format-agnostic (no XML/MHTML knowledge)
- Use value objects for properties
- Support visitor pattern

### Layer 2: Properties (`lib/uniword/properties/`)

**Value Objects:**
- [`ParagraphProperties`](../lib/uniword/properties/paragraph_properties.rb) - Paragraph formatting
- [`RunProperties`](../lib/uniword/properties/run_properties.rb) - Character formatting
- [`TableProperties`](../lib/uniword/properties/table_properties.rb) - Table formatting

**Pattern**: Immutable value objects
- No setters after initialization
- Value-based equality
- Self-validating

### Layer 3: Serialization (`lib/uniword/serialization/`)

**Key Components:**
- [`OoxmlSerializer`](../lib/uniword/serialization/ooxml_serializer.rb) - DOCX XML generation
- [`OoxmlDeserializer`](../lib/uniword/serialization/ooxml_deserializer.rb) - DOCX XML parsing
- [`HtmlDeserializer`](../lib/uniword/serialization/html_deserializer.rb) - HTML import

**Responsibilities:**
- Convert models to/from XML
- Handle namespaces (w:, m:, wp:, etc.)
- Preserve unknown elements for round-trip

**Current Approach**: Hardcoded XML building with Nokogiri
**Future (v2.0)**: Schema-driven with YAML definitions

### Layer 4: Format Handlers (`lib/uniword/formats/`)

**Handler Pattern:**
- `BaseHandler` - Abstract interface
- `DocxHandler` - DOCX format (ZIP + XML)
- `MhtmlHandler` - MHTML format (MIME multipart)
- `FormatHandlerRegistry` - Factory registration

**Flow:**
```ruby
Document → Handler.save(path) → Serializer → ZIP/MIME → File
File → Handler.load(path) → Deserializer → Document
```

### Layer 5: Infrastructure (`lib/uniword/infrastructure/`)

**Support Components:**
- `ZipPackager` - ZIP file creation/extraction
- `MimePackager` - MHTML packaging
- `ContentTypes` - [Content_Types].xml management
- `Relationships` - .rels file management

## Critical Implementation Patterns

### Pattern 0: Lutaml-Model Attribute Declaration (THE MOST CRITICAL)

**🚨 THE PATTERN THAT BROKE EVERYTHING AND WAS FIXED IN v1.1.0**

**Rule**: Attributes MUST be declared BEFORE xml mappings in lutaml-model classes.

**Why**: Lutaml-model builds its internal schema by reading attribute declarations sequentially. If xml mappings come first, the framework doesn't know the attributes exist and cannot serialize them.

**The Bug** (v1.0.0):
```ruby
# lib/uniword/document.rb - WRONG (caused empty XML)
class Document < Lutaml::Model::Serializable
  xml do
    root 'document'
    namespace Ooxml::Namespaces::WordProcessingML
    map_element 'body', to: :body
  end
  
  attribute :body, Body  # ❌ TOO LATE - Framework already processed xml block
end
```

**The Fix** (v1.1.0):
```ruby
# lib/uniword/document.rb - CORRECT
class Document < Lutaml::Model::Serializable
  attribute :body, Body  # ✅ DECLARE FIRST
  
  xml do
    root 'document'
    namespace Ooxml::Namespaces::WordProcessingML
    mixed_content       # ✅ Added for nested elements
    map_element 'body', to: :body
  end
end
```

**Impact of Bug**:
- `Document.to_xml()` produced `<document xmlns="..."/>`  (empty!)
- Body element completely missing from serialization
- Round-trip testing impossible
- All dependent features blocked

**Impact of Fix**:
- Full document structure now serializes correctly
- Body, paragraphs, runs all preserved
- Round-trip testing working
- Foundation for all enhanced properties

**Additional Fixes Required**:
- Added `mixed_content` for elements with nested content
- Removed multiple namespace declarations (only ONE allowed per level)
- Removed raw XML storage (violated model-driven architecture)
- Fixed `initialize` methods to use `||=` instead of `=` (preserves lutaml-model values)

**Files Fixed**:
- [`lib/uniword/document.rb`](../lib/uniword/document.rb)
- [`lib/uniword/body.rb`](../lib/uniword/body.rb)
- [`lib/uniword/styles_configuration.rb`](../lib/uniword/styles_configuration.rb)
- [`lib/uniword/numbering_configuration.rb`](../lib/uniword/numbering_configuration.rb)
- [`lib/uniword/formats/docx_handler.rb`](../lib/uniword/formats/docx_handler.rb)
- [`lib/uniword/ooxml/docx_package.rb`](../lib/uniword/ooxml/docx_package.rb)

**Lesson**: This pattern is SO critical that it's now documented in THREE memory bank files (context.md, tech.md, architecture.md) to ensure it's never violated again.

### Pattern 1: Element Registry

**Purpose**: Decouple element types from deserialization

**Implementation** in `element_registry.rb`:
```ruby
class ElementRegistry
  def self.register(tag_name, klass)
    @registry[tag_name] = klass
  end

  def self.for_tag(tag_name)
    @registry[tag_name] || UnknownElement
  end
end
```

**Usage**: Serializer looks up element class by XML tag name

### Pattern 2: Namespace Handling (v0.7+)

**New Approach** using lutaml-model:
```ruby
class Document < Lutaml::Model::Serializable
  xml do
    root 'document'
    namespace 'http://schemas...wordprocessingml/2006/main', 'w'
    namespace 'http://schemas...relationships', 'r'
  end
end
```

**Namespace Registry** in [`namespaces.rb`](../lib/uniword/ooxml/namespaces.rb):
- WordProcessingML (w:)
- MathML (m:) - For equations
- DrawingML (wp:, a:) - For images
- Relationships (r:)
- VML (v:) - Legacy

### Pattern 3: Lazy Loading

**Performance Optimization:**
```ruby
class Document
  def paragraphs
    @cached_paragraphs ||= body.paragraphs
  end
end
```

**Why**: Large documents (1000+ pages) load only needed parts

### Pattern 4: Visitor Pattern

**Purpose**: Traverse document tree without coupling

**Implementation:**
```ruby
class Document
  def accept(visitor)
    visitor.visit_document(self)
    body.elements.each { |e| e.accept(visitor) }
  end
end

class TextExtractor
  def visit_document(doc)
    @text = []
  end

  def visit_paragraph(para)
    @text << para.text
  end
end
```

**Use Cases**: Text extraction, validation, transformation

### Pattern 5: Complete Schema Coverage (v2.0)

**Problem**: Must model 100% of OOXML spec for perfect round-trip

**Solution**: Schema-driven generation of ALL elements
```ruby
# config/ooxml/schemas/wordprocessingml.yml
elements:
  bookmarkStart:
    class_name: BookmarkStart
    attributes:
      - name: id
        type: :string
      - name: name
        type: :string
```

**NO RAW XML**: Every element must be a proper lutaml-model class

**Critical for**: True model-driven architecture, 100% type safety

## StyleSet Architecture

### Loading Flow
```
.dotx file → ZipExtractor → word/styles.xml
   ↓
StyleSetXmlParser → Parse <w:style> elements
   ↓
Style objects with Properties → StyleSet
   ↓
Apply to Document → Merge into styles_configuration
```

### Key Components

**StyleSet** ([`styleset.rb`](../lib/uniword/styleset.rb)):
- Container for Style collection
- Apply strategy (keep_existing, replace, rename)
- YAML serialization for bundled sets

**StyleSetXmlParser** ([`styleset_xml_parser.rb`](../lib/uniword/stylesets/styleset_xml_parser.rb)):
- Parse word/styles.xml from .dotx
- Extract paragraph/run/table properties
- Currently ~30% property coverage (target: 100%)

**Property Parsing Flow:**
```
<w:style> → parse_style_node()
   ↓
<w:pPr> → parse_paragraph_properties() → ParagraphProperties
<w:rPr> → parse_run_properties() → RunProperties
<w:tblPr> → parse_table_properties() → TableProperties
```

## Theme Architecture

### Theme Components

**Theme** ([`theme.rb`](../lib/uniword/theme.rb)):
- ColorScheme (12 theme colors)
- FontScheme (major/minor fonts)
- FormatScheme (future)
- ThemeVariant support

**Loading Sources:**
1. `.thmx` files (ZIP packages)
2. Bundled YAML files (28 Office themes)
3. Extracted from documents

### Application Flow
```
doc.apply_theme('celestial')
   ↓
Load theme YAML → Theme object
   ↓
Update document.theme
   ↓
Serializer includes theme1.xml in package
```

## OOXML Serialization Architecture

### Current (v1.x): Hardcoded Approach

**Method**: Manual Nokogiri XML building

**Example** from [`ooxml_serializer.rb`](../lib/uniword/serialization/ooxml_serializer.rb):
```ruby
def build_paragraph(xml, paragraph)
  xml['w'].p do
    build_paragraph_properties(xml, paragraph.properties)
    paragraph.runs.each { |run| build_run(xml, run) }
  end
end
```

**Pros**: Works, explicit, debuggable
**Cons**: Maintenance burden, hard to extend

### Future (v2.0): Schema-Driven Approach

**Method**: External YAML schema definitions

**Example Schema:**
```yaml
# config/ooxml/schema_main.yml
elements:
  paragraph:
    tag: 'w:p'
    namespace: 'w'
    children:
      - element: paragraph_properties
        tag: 'w:pPr'
        optional: true
      - element: run
        tag: 'w:r'
        multiple: true
```

**Generic Serializer:**
```ruby
class ElementSerializer
  def serialize(element)
    schema_def = OoxmlSchema.definition_for(element.class)
    build_xml_from_schema(element, schema_def)
  end
end
```

**Benefits**:
- Zero hardcoding
- Easy to extend (edit YAML, not Ruby)
- 100% ISO 29500 coverage possible
- Community contributions easier

## File Structure

### Core Library Files
```
lib/uniword/
├── document.rb           # Main document model
├── body.rb               # Document body
├── paragraph.rb          # Paragraph element
├── run.rb                # Text run
├── table.rb              # Table element
├── style.rb              # Style definition
├── theme.rb              # Theme system
├── styleset.rb           # StyleSet system
│
├── properties/           # Value objects
│   ├── paragraph_properties.rb
│   ├── run_properties.rb
│   └── table_properties.rb
│
├── serialization/        # Format serialization
│   ├── ooxml_serializer.rb
│   ├── ooxml_deserializer.rb
│   └── html_deserializer.rb
│
├── formats/              # Format handlers
│   ├── base_handler.rb
│   ├── docx_handler.rb
│   └── mhtml_handler.rb
│
├── ooxml/                # OOXML infrastructure
│   ├── namespaces.rb     # Namespace definitions
│   ├── content_types.rb
│   └── relationships.rb
│
├── stylesets/            # StyleSet loading
│   ├── styleset_loader.rb
│   └── styleset_xml_parser.rb
│
└── theme/                # Theme loading
    ├── theme_loader.rb
    └── theme_package_reader.rb
```

### Data Files
```
data/
├── themes/               # 28 bundled Office themes (YAML)
│   ├── celestial.yml
│   ├── atlas.yml
│   └── ...
│
└── stylesets/            # 12 bundled StyleSets (YAML)
    ├── distinctive.yml
    ├── formal.yml
    └── ...
```

## Testing Architecture

### Test Organization
```
spec/
├── uniword/
│   ├── document_spec.rb           # Unit tests
│   ├── paragraph_spec.rb
│   ├── style_spec.rb
│   ├── styleset_spec.rb
│   ├── styleset_integration_spec.rb  # Integration tests
│   └── styleset_roundtrip_spec.rb    # Round-trip tests
│
└── fixtures/              # Test files
    └── ...
```

### Test Strategies

**Unit Tests**: Individual class behavior
**Integration Tests**: Component interaction
**Round-Trip Tests**: Load → Modify → Save → Compare

**Semantic Comparison** using Canon gem:
```ruby
expect(generated_xml).to be_xml_equivalent_to(original_xml)
```

## Dependencies Architecture

### Production Dependencies
- **lutaml-model ~> 0.7** - XML serialization framework
- **nokogiri ~> 1.15** - XML parsing
- **rubyzip ~> 2.3** - ZIP handling
- **thor ~> 1.3** - CLI framework
- **mail ~> 2.8** - MHTML MIME handling

### Development Dependencies
- **rspec** - Testing framework
- **canon** - Semantic XML comparison
- **plurimath** - Math equation support
- **rubocop** - Code quality

### Local Development Paths
For bleeding-edge features during development:
- lutaml-model: `/Users/mulgogi/src/lutaml/lutaml-model`
- plurimath: `/Users/mulgogi/src/plurimath/plurimath`
- canon: `/Users/mulgogi/src/lutaml/canon`

## Performance Considerations

### Optimization Strategies

**1. Lazy Loading**
- Cache expensive operations
- Load elements on-demand
- Clear cache when modified

**2. Streaming**
- Stream large XML parsing
- Process chunks incrementally
- Limit memory footprint

**3. Efficient Serialization**
- Reuse XML builders
- Minimize object allocation
- Use string builders for large output

### Performance Targets
- Simple doc (5 pages): < 50ms
- Complex doc (50 pages): < 500ms
- StyleSet load+apply: < 500ms
- Theme application: < 100ms

## Critical Implementation Paths

### 1. Document Save Path
```
Document → DocumentWriter.save()
   ↓
Format detection (extension)
   ↓
FormatHandler.save()
   ↓
OoxmlSerializer.serialize_package()
   ↓
Build all XML parts (document.xml, styles.xml, etc.)
   ↓
ZipPackager.package()
   ↓
Write to file
```

### 2. Document Load Path
```
File → DocumentFactory.from_file()
   ↓
Format detection
   ↓
FormatHandler.load()
   ↓
ZipExtractor.extract()
   ↓
OoxmlDeserializer.deserialize()
   ↓
Parse XML → Build models
   ↓
Document object
```

### 3. StyleSet Apply Path
```
StyleSet.load('distinctive')
   ↓
Load YAML → StyleSet with Style[]
   ↓
doc.apply_styleset()
   ↓
StyleSet.apply_to(doc, strategy)
   ↓
For each Style:
  - Check conflicts (based on strategy)
  - Add/Replace/Rename
  - Merge into styles_configuration
```

## Future Architecture (v2.0)

### Schema-Driven System

**External Schema Files:**
```
config/ooxml/
├── schema_main.yml          # w: namespace (200+ elements)
├── schema_relationships.yml # r: namespace
├── schema_drawing.yml       # wp:, a: namespaces
├── schema_math.yml          # m: namespace (OMML)
├── schema_vml.yml           # v:, o: namespaces
└── ...
```

**Generic Serializer:**
- No hardcoded XML generation
- All structure in YAML
- Easy to extend (community contributions)
- 100% ISO 29500 coverage

**Timeline**: 8-10 weeks after v1.1.0 release
// ... existing code ...
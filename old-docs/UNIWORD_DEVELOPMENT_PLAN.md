= Uniword Development Plan
:toc: macro
:toclevels: 3

toc::[]

== Executive Summary

=== Project Overview

The Uniword gem is a comprehensive Ruby library for reading and writing Microsoft Word documents in multiple formats. The project aims to provide a unified, model-driven architecture for handling:

* **DOC MHTML format** (read and write capabilities)
* **DOCX format** (read and write capabilities)

The gem will leverage `lutaml-model` for XML parsing and model representation, with full bidirectional support (read/write) for both formats from the outset. This approach ensures consistency and allows for round-trip conversions.

=== Strategic Goals

. Create a production-ready Ruby gem for Word document manipulation
. Provide a clean, declarative API for document creation and modification
. Support both legacy (DOC MHTML) and modern (DOCX) formats with read/write
. Enable seamless integration with existing Metanorma toolchain
. Establish extensible architecture for future format support
. Use lutaml-model for automatic XML serialization/deserialization

== Design Principles

=== Core Architectural Principles

The Uniword gem follows strict object-oriented design principles to ensure maintainability, extensibility, and clean separation of concerns.

==== SOLID Principles

**Single Responsibility Principle (SRP)**:
- Each class has ONE clearly defined responsibility
- Document model: Represents document structure only
- Format handlers: Handle format-specific serialization only
- Serializers: Convert between representations only
- Validators: Validate data integrity only

**Open/Closed Principle (OCP)**:
- Classes open for extension, closed for modification
- New formats added via new handler classes, not modifying existing code
- New element types added via inheritance, not changing base classes
- Plugin architecture for custom elements and formats

**Liskov Substitution Principle (LSP)**:
- All format handlers implement common interface
- Any handler can be substituted without breaking code
- All element types inherit from base Element class

**Interface Segregation Principle (ISP)**:
- Specific interfaces for specific capabilities
- Readable interface separate from Writable interface
- Serializable interface separate from Parseable interface

**Dependency Inversion Principle (DIP)**:
- Depend on abstractions, not concrete implementations
- Document model depends on abstract Element, not concrete Paragraph
- Format handlers depend on abstract Serializer, not concrete XMLSerializer

==== MECE (Mutually Exclusive, Collectively Exhaustive)

**Component Organization**:
- Each layer handles distinct concerns with no overlap
- Public API layer: User-facing interface ONLY
- Document layer: Document model ONLY
- Format layer: Format-specific handling ONLY
- Serialization layer: Data conversion ONLY
- Utility layer: Reusable utilities ONLY

**Element Hierarchy**:
- Elements mutually exclusive: Paragraph ≠ Table ≠ Image
- Elements collectively exhaustive: All document content represented
- No ambiguous or overlapping element types

==== Separation of Concerns

**Layered Architecture**:
```
┌─────────────────────────────────────┐
│  Public API (Document, Element)     │ ← User Interface
├─────────────────────────────────────┤
│  Domain Model (Paragraph, Table)    │ ← Business Logic
├─────────────────────────────────────┤
│  Format Handlers (DOCX, MHTML)      │ ← Format Logic
├─────────────────────────────────────┤
│  Serializers (XML, HTML)            │ ← Data Conversion
├─────────────────────────────────────┤
│  Infrastructure (ZIP, MIME)         │ ← Technical Details
└─────────────────────────────────────┘
```

**Clear Boundaries**:
- No business logic in format handlers
- No format-specific code in domain model
- No infrastructure concerns in public API
- Each layer communicates only with adjacent layers

==== Design Patterns

**Strategy Pattern**: Format handlers as interchangeable strategies
**Factory Pattern**: Element creation based on type
**Visitor Pattern**: Element traversal and transformation
**Builder Pattern**: Complex document construction
**Template Method**: Common format handling workflow
**Registry Pattern**: Element type registration
**Adapter Pattern**: External library integration

== Architecture Overview

=== High-Level Architecture

[source]
----
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
│  │ - Format       │           └──────────────────┘         │
│  │   Detection    │                    │                   │
│  └────────────────┘                    │                   │
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
│         │                              │                   │
│         ▼                              ▼                   │
│  ┌─────────────────────────────────────────────┐           │
│  │          Utility Layer                      │           │
│  │                                             │           │
│  │ - Image Processing  - Math Conversion       │           │
│  │ - CSS Handling      - ID/Anchor Management  │           │
│  └─────────────────────────────────────────────┘           │
└─────────────────────────────────────────────────────────────┘
----

=== Core Components

==== Document Model

The central abstraction representing a Word document. Following SRP, the Document class is responsible ONLY for holding document structure, NOT for file I/O or format conversion.

[source,ruby]
----
module Uniword
  # Represents the document structure (domain model)
  # Responsibility: Hold document elements and provide access
  # Does NOT handle: File I/O, format conversion, serialization
  class Document < Lutaml::Model::Serializable
    # XML namespace configuration for OOXML
    xml do
      root "document", namespace: "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
           prefix: "w"

      map_element "body", to: :body
    end

    # Document structure (domain entities)
    attribute :elements, :array, item_class: Element  # Base element
    attribute :styles, StylesConfiguration
    attribute :sections, :array, item_class: Section
    attribute :properties, DocumentProperties

    # Convenience accessors (derived from elements)
    def paragraphs
      elements.select { |e| e.is_a?(Paragraph) }
    end

    def tables
      elements.select { |e| e.is_a?(Table) }
    end

    # Element management
    def add_element(element)
      raise ArgumentError unless element.is_a?(Element)
      elements << element
    end

    # Visitor pattern for traversal
    def accept(visitor)
      visitor.visit_document(self)
      elements.each { |e| e.accept(visitor) }
    end
  end

  # Factory for document creation (separate concern)
  # Responsibility: Create documents from various sources
  class DocumentFactory
    def self.from_file(path, format: :auto)
      format = detect_format(path) if format == :auto
      handler = FormatHandlerRegistry.handler_for(format)
      handler.read(path)
    end

    def self.create
      Document.new.tap do |doc|
        doc.elements = []
        doc.styles = StylesConfiguration.new
        doc.properties = DocumentProperties.new
      end
    end

    private

    def self.detect_format(path)
      FormatDetector.detect(path)
    end
  end

  # Separate concern for saving (Open/Closed Principle)
  # Responsibility: Coordinate document saving
  class DocumentWriter
    def initialize(document)
      @document = document
    end

    def save(path, format: :auto)
      format = infer_format(path) if format == :auto
      handler = FormatHandlerRegistry.handler_for(format)
      handler.write(@document, path)
    end

    private

    def infer_format(path)
      case File.extname(path).downcase
      when '.docx' then :docx
      when '.doc' then :mhtml
      else raise ArgumentError, "Unknown format for #{path}"
      end
    end
  end
end
----

**Key Design Decisions**:
- `Document`: Pure domain model, no I/O concerns
- `DocumentFactory`: Separate factory for creation (SRP)
- `DocumentWriter`: Separate writer for persistence (SRP)
- Visitor pattern for extensible traversal
- Elements stored as base `Element` class (LSP)

==== Format Handler Architecture

Format handlers follow the **Strategy Pattern** for complete interchangeability and **Template Method** for common workflow.

===== Abstract Base Handler

[source,ruby]
----
module Uniword
  module Formats
    # Abstract base defining the format handler interface
    # Responsibility: Define contract for all format handlers
    class BaseHandler
      # Template method defining the workflow
      def read(path)
        validate_read_path(path)
        content = extract_content(path)
        deserialize(content)
      end

      def write(document, path)
        validate_document(document)
        serialized = serialize(document)
        package_and_save(serialized, path)
      end

      # Subclasses must implement these
      def extract_content(path)
        raise NotImplementedError
      end

      def deserialize(content)
        raise NotImplementedError
      end

      def serialize(document)
        raise NotImplementedError
      end

      def package_and_save(content, path)
        raise NotImplementedError
      end

      private

      def validate_read_path(path)
        raise ArgumentError, "File not found: #{path}" unless File.exist?(path)
      end

      def validate_document(document)
        raise ArgumentError, "Not a Document" unless document.is_a?(Document)
      end
    end
  end
end
----

===== DOCX Handler (Concrete Strategy)

[source,ruby]
----
module Uniword
  module Formats
    # Handles DOCX format using OOXML
    # Responsibility: DOCX-specific serialization ONLY
    class DocxHandler < BaseHandler
      def extract_content(path)
        # Delegate to ZIP extractor (SRP)
        ZipExtractor.new(path).extract
      end

      def deserialize(content)
        # Delegate to OOXML deserializer (SRP)
        OoxmlDeserializer.new(content).to_document
      end

      def serialize(document)
        # Delegate to OOXML serializer (SRP)
        OoxmlSerializer.new(document).to_ooxml
      end

      def package_and_save(ooxml_parts, path)
        # Delegate to ZIP packager (SRP)
        ZipPackager.new(ooxml_parts).save(path)
      end
    end
  end
end
----

===== MHTML Handler (Concrete Strategy)

[source,ruby]
----
module Uniword
  module Formats
    # Handles MHTML format using Word HTML
    # Responsibility: MHTML-specific serialization ONLY
    class MhtmlHandler < BaseHandler
      def extract_content(path)
        # Delegate to MIME parser (SRP)
        MimeParser.new(path).parse
      end

      def deserialize(mime_parts)
        # Delegate to HTML deserializer (SRP)
        HtmlDeserializer.new(mime_parts).to_document
      end

      def serialize(document)
        # Delegate to HTML serializer (SRP)
        HtmlSerializer.new(document).to_html
      end

      def package_and_save(html_parts, path)
        # Delegate to MIME packager (SRP)
        MimePackager.new(html_parts).save(path)
      end
    end
  end
end
----

===== Format Handler Registry (Extension Point)

[source,ruby]
----
module Uniword
  module Formats
    # Registry for format handlers (Open/Closed Principle)
    # Responsibility: Manage handler registration
    class FormatHandlerRegistry
      @handlers = {}

      # Register new handler without modifying existing code
      def self.register(format, handler_class)
        raise ArgumentError unless handler_class < BaseHandler
        @handlers[format] = handler_class
      end

      def self.handler_for(format)
        handler_class = @handlers[format]
        raise ArgumentError, "Unknown format: #{format}" unless handler_class
        handler_class.new
      end

      # Built-in registrations
      register(:docx, DocxHandler)
      register(:mhtml, MhtmlHandler)

      # Users can add custom formats:
      # FormatHandlerRegistry.register(:odt, OdtHandler)
    end
  end
end
----

**Extensibility**:
- Adding new format = implement BaseHandler + register
- No modification to existing handlers (OCP)
- All handlers interchangeable (LSP)
- Each handler delegates to specialized classes (SRP)

==== Component Model Architecture

Components follow a strict inheritance hierarchy with clear separation of concerns. Each class has ONE responsibility.

===== Element Base Class

[source,ruby]
----
module Uniword
  # Abstract base for all document elements
  # Responsibility: Define element interface and common behavior
  class Element < Lutaml::Model::Serializable
    # All elements have ID for referencing
    attribute :id, :string

    # Visitor pattern support
    def accept(visitor)
      raise NotImplementedError, "Subclass must implement accept"
    end

    # Validation (separate concern)
    def valid?
      validator.valid?(self)
    end

    def validator
      @validator ||= ElementValidator.for(self.class)
    end

    # Type checking
    def self.inherited(subclass)
      ElementRegistry.register(subclass)
    end
  end
end
----

===== Block Elements (Container Elements)

[source,ruby]
----
module Uniword
  # Paragraph: Contains inline elements
  # Responsibility: Manage inline content ONLY
  class Paragraph < Element
    xml do
      root "p", namespace: "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
      map_element "pPr", to: :properties
      map_element "r", to: :runs
    end

    attribute :properties, ParagraphProperties  # Composition
    attribute :runs, :array, item_class: Run    # Composition

    def accept(visitor)
      visitor.visit_paragraph(self)
      runs.each { |r| r.accept(visitor) }
    end

    # Derived value, not stored
    def text
      runs.map(&:text).join
    end
  end

  # Table: Contains rows
  # Responsibility: Manage table structure ONLY
  class Table < Element
    xml do
      root "tbl"
      map_element "tblPr", to: :properties
      map_element "tr", to: :rows
    end

    attribute :properties, TableProperties
    attribute :rows, :array, item_class: TableRow

    def accept(visitor)
      visitor.visit_table(self)
      rows.each { |r| r.accept(visitor) }
    end

    # Convenience method (derived)
    def cell_at(row, col)
      rows[row]&.cells[col]
    end
  end

  # TableRow: Contains cells
  # Responsibility: Manage row cells ONLY
  class TableRow < Element
    xml do
      root "tr"
      map_element "trPr", to: :properties
      map_element "tc", to: :cells
    end

    attribute :properties, TableRowProperties
    attribute :cells, :array, item_class: TableCell

    def accept(visitor)
      visitor.visit_table_row(self)
      cells.each { |c| c.accept(visitor) }
    end
  end

  # TableCell: Contains block elements
  # Responsibility: Manage cell content ONLY
  class TableCell < Element
    xml do
      root "tc"
      map_element "tcPr", to: :properties
      map_element "p", to: :paragraphs
    end

    attribute :properties, TableCellProperties
    attribute :paragraphs, :array, item_class: Paragraph

    def accept(visitor)
      visitor.visit_table_cell(self)
      paragraphs.each { |p| p.accept(visitor) }
    end
  end
end
----

===== Inline Elements

[source,ruby]
----
module Uniword
  # Run (Text Run): Formatted text segment
  # Responsibility: Contain formatted text ONLY
  class Run < Element
    xml do
      root "r"
      map_element "rPr", to: :properties
      map_element "t", to: :text_element
    end

    attribute :properties, RunProperties
    attribute :text_element, TextElement

    def accept(visitor)
      visitor.visit_run(self)
    end

    # Convenience accessor
    def text
      text_element&.content || ""
    end

    def text=(value)
      self.text_element = TextElement.new(content: value)
    end
  end

  # Image: Embedded image
  # Responsibility: Reference image data ONLY
  class Image < Element
    xml do
      root "drawing"
      map_element "inline", to: :inline_properties
    end

    attribute :inline_properties, InlineProperties
    attribute :image_data, ImageData  # References actual image

    def accept(visitor)
      visitor.visit_image(self)
    end
  end
end
----

===== Properties Classes (Value Objects)

[source,ruby]
----
module Uniword
  # Properties are value objects - immutable data holders
  # Responsibility: Hold property values ONLY

  class ParagraphProperties < Lutaml::Model::Serializable
    xml do
      root "pPr"
      map_element "pStyle", to: :style
      map_element "jc", to: :alignment
      map_element "spacing", to: :spacing
    end

    attribute :style, StyleReference
    attribute :alignment, Alignment
    attribute :spacing, Spacing

    # Properties are compared by value
    def ==(other)
      other.is_a?(self.class) &&
        style == other.style &&
        alignment == other.alignment &&
        spacing == other.spacing
    end
  end

  class RunProperties < Lutaml::Model::Serializable
    xml do
      root "rPr"
      map_element "b", to: :bold
      map_element "i", to: :italic
      map_element "u", to: :underline
      map_element "sz", to: :size
    end

    attribute :bold, BooleanValue
    attribute :italic, BooleanValue
    attribute :underline, UnderlineValue
    attribute :size, SizeValue
  end
end
----

===== Element Registry (Extensibility)

[source,ruby]
----
module Uniword
  # Registry for element types (Open/Closed)
  # Responsibility: Manage element type registration
  class ElementRegistry
    @elements = {}

    def self.register(element_class)
      raise ArgumentError unless element_class < Element
      tag = element_class.xml_tag_name
      @elements[tag] = element_class
    end

    def self.create(tag, attributes = {})
      element_class = @elements[tag]
      raise ArgumentError, "Unknown element: #{tag}" unless element_class
      element_class.new(attributes)
    end

    # Users can register custom elements:
    # class CustomElement < Element
    #   # ... implementation ...
    # end
    # ElementRegistry automatically registers via Element.inherited
  end
end
----

**Design Highlights**:
- Clear inheritance hierarchy (Element → BlockElement, InlineElement)
- Composition over inheritance (Elements contain Properties)
- Value objects for properties (immutable)
- Visitor pattern for extensible operations
- Registry pattern for element discovery
- Each class has single, clear responsibility
- No business logic in data classes

==== Advanced Features Architecture

**Styles System**:
```
Style (base)
├── ParagraphStyle (inherits from Style)
├── CharacterStyle (inherits from Style)
├── TableStyle (inherits from Style)
└── ListStyle (inherits from Style)

StylesConfiguration
├── default_styles (Normal, Heading1-9, etc.)
├── custom_styles (user-defined)
└── style_inheritance (basedOn chain)
```

**Lists & Numbering**:
```
NumberingDefinition (abstract)
├── levels (0-8 levels)
├── format (decimal, roman, letter, bullet)
├── alignment, indent
└── start value

NumberingInstance (concrete)
├── references NumberingDefinition
├── level_overrides
└── used by ListParagraph

ListParagraph (extends Paragraph)
├── numbering_instance_id
├── numbering_level (0-8)
└── inherits all Paragraph features
```

**Headers & Footers**:
```
Section
├── page_setup (margins, orientation, size)
├── header_reference (first, even, odd)
└── footer_reference (first, even, odd)

Header/Footer
├── content (Paragraphs, Tables, Images)
├── type (first, even, odd, default)
└── fields (PAGE, NUMPAGES, etc.)
```

**Text Boxes**:
```
TextBox (anchored element)
├── positioning (absolute x,y or relative)
├── size (width, height)
├── wrapping (square, tight, through)
├── border & fill
└── content (Paragraphs)
```

**Captions**:
```
Caption (special Paragraph)
├── label ("Figure", "Table", etc.)
├── SEQ_field (auto-numbering)
├── separator (" - ", ": ", etc.)
└── caption_text
```

**Field System**:
```
Field (complex field)
├── field_code (SEQ, REF, PAGEREF, etc.)
├── field_switches (formatting options)
└── field_result (current display value)
```

=== Technology Stack

==== Core Dependencies

* **lutaml-model** (~> 0.7) - XML parsing and automatic serialization
* **nokogiri** - XML/HTML manipulation
* **rubyzip** - ZIP file handling for DOCX
* **mime-types** - MIME type detection
* **uuidtools** - UUID generation for resources

==== Development Dependencies

* **rspec** - Testing framework
* **rubocop** - Code quality and style
* **vcr** - HTTP request recording for tests
* **simplecov** - Code coverage analysis
* **yard** - Documentation generation

== Development Phases

=== Phase 1: Foundation & Core Document Model

**Duration**: 2-3 weeks

**Goal**: Establish project structure, core architecture, and unified document model that supports both DOCX and MHTML formats

==== Milestones

===== Milestone 1.1: Project Setup & Architecture (Week 1)
[cols="2,3,1,1"]
|===
| Task | Description | Priority | Est. Time

| Project scaffolding
| Create gem structure using edoxen template
| High
| 1 day

| Setup lutaml-model integration
| Configure XML parsing and serialization with lutaml-model
| High
| 1.5 days

| Configure build system
| Setup Rakefile, gemspec, bundler config
| High
| 0.5 day

| Initial test framework
| Configure RSpec, fixtures, and test helpers
| High
| 0.5 day

| CI/CD pipeline
| Setup GitHub Actions for tests and linting
| Medium
| 0.5 day

| Documentation structure
| Create README.adoc with AsciiDoc format
| Medium
| 0.5 day

| Architecture design
| Design format-agnostic document model
| High
| 0.5 day
|===

**Success Criteria**:
- [ ] Gem can be built and installed locally
- [ ] Test suite runs successfully (even if empty)
- [ ] CI pipeline executes on push
- [ ] README documents basic installation
- [ ] Architecture supports both DOCX and MHTML

===== Milestone 1.2: Core Document Model with lutaml-model (Week 2)
[cols="2,3,1,1"]
|===
| Task | Description | Priority | Est. Time

| Define base document model
| Create `Uniword::Document` using lutaml-model with XML mapping
| High
| 2 days

| Implement paragraph model
| Create `Uniword::Paragraph` with text runs and XML serialization
| High
| 1 day

| Implement text run model
| Create `Uniword::TextRun` with formatting and XML serialization
| High
| 1 day

| Implement table model
| Create `Uniword::Table`, `TableRow`, `TableCell` with XML mapping
| High
| 1.5 days

| Implement style model
| Create `Uniword::Style` for style definitions with XML serialization
| High
| 1 day

| Model validation
| Add validation for required attributes
| Medium
| 0.5 day
|===

**Success Criteria**:
- [ ] Can create document objects programmatically
- [ ] Models serialize to/from XML correctly using lutaml-model
- [ ] All models have comprehensive tests
- [ ] Validation prevents invalid states
- [ ] XML namespaces handled correctly

===== Milestone 1.3: Format Handler Infrastructure (Week 3)
[cols="2,3,1,1"]
|===
| Task | Description | Priority | Est. Time

| BaseHandler abstract class
| Create abstract handler with template method pattern
| High
| 1 day

| Format handler registry
| Implement registry for handler registration (OCP)
| High
| 0.5 day

| DocxHandler implementation
| Create DOCX handler following BaseHandler interface
| High
| 1 day

| MhtmlHandler implementation
| Create MHTML handler following BaseHandler interface
| High
| 1 day

| Infrastructure layer
| Implement ZipExtractor/Packager and MimeParser/Packager
| High
| 1.5 days

| DocumentFactory and Writer
| Implement factory and writer following SRP
| High
| 1 day

| Format detection
| Auto-detect file format (separate utility class)
| Medium
| 0.5 day
|===

**Success Criteria**:
- [ ] All handlers implement BaseHandler (LSP)
- [ ] Registry enables adding formats without modification (OCP)
- [ ] Each class has single responsibility (SRP)
- [ ] Infrastructure separated from business logic
- [ ] Factory and Writer separated from Document
- [ ] Can add new format by implementing interface
- [ ] Handler infrastructure fully tested

**Phase 1 Deliverables**:
- Core document model with lutaml-model
- Format handler infrastructure
- Project foundation with CI/CD
- Initial documentation

**Phase 1 Risks**:
- lutaml-model XML namespace complexity → Mitigation: Study sts-ruby implementation
- Format handler abstraction complexity → Mitigation: Keep interface minimal initially
- Model design mistakes → Mitigation: Iterative refinement based on both formats

=== Phase 2: DOCX Read & Write Support

**Duration**: 4-5 weeks

**Goal**: Implement comprehensive DOCX reading and writing capabilities using lutaml-model serialization

==== Milestones

===== Milestone 2.1: OOXML Structure & Serialization (Week 1)
[cols="2,3,1,1"]
|===
| Task | Description | Priority | Est. Time

| OOXML namespace configuration
| Configure OOXML namespaces in lutaml-model
| High
| 1 day

| Document.xml schema mapping
| Map document.xml to lutaml-model classes
| High
| 2 days

| Relationships handling
| Implement relationship parsing and generation
| High
| 1.5 days

| Content types handling
| Implement [Content_Types].xml management
| High
| 1 day

| Settings and properties
| Handle document settings and core properties
| Medium
| 0.5 day
|===

**Success Criteria**:
- [ ] OOXML namespaces configured correctly
- [ ] Can parse document.xml into model
- [ ] Can serialize model to document.xml
- [ ] Relationships preserved in round-trip
- [ ] Content types maintained correctly

===== Milestone 2.2: DOCX Read Implementation (Week 2)
[cols="2,3,1,1"]
|===
| Task | Description | Priority | Est. Time

| DOCX extraction pipeline
| Implement full DOCX to model conversion
| High
| 2 days

| Paragraph extraction
| Extract paragraphs with all properties
| High
| 1 day

| Text run extraction
| Extract formatted text runs
| High
| 1 day

| Table extraction
| Extract table structure and cells
| High
| 1.5 days

| Style extraction
| Extract and map style definitions
| High
| 1 day

| Image extraction
| Extract embedded images with dimensions
| Medium
| 0.5 day
|===

**Success Criteria**:
- [ ] Can read DOCX files into document model
- [ ] All document elements extracted correctly
- [ ] Formatting preserved accurately
- [ ] Nested structures maintained
- [ ] Tests use real DOCX fixtures

===== Milestone 2.3: DOCX Write Implementation (Week 3)
[cols="2,3,1,1"]
|===
| Task | Description | Priority | Est. Time

| DOCX generation pipeline
| Implement model to DOCX conversion
| High
| 2 days

| XML serialization
| Use lutaml-model to serialize to OOXML
| High
| 1.5 days

| ZIP packaging
| Package all parts into valid DOCX
| High
| 1 day

| Relationship generation
| Generate relationship files
| High
| 1 day

| Content type generation
| Generate [Content_Types].xml
| Medium
| 0.5 day

| Image embedding
| Embed images in DOCX package
| Medium
| 1 day
|===

**Success Criteria**:
- [ ] Can generate valid DOCX files
- [ ] Generated files open in Microsoft Word
- [ ] Generated files open in LibreOffice
- [ ] All document elements serialized correctly
- [ ] Images embedded properly

===== Milestone 2.4: Advanced DOCX Features (Week 4-5)

**Scope Expansion**: Critical Word document features for production use

[cols="2,3,1,1"]
|===
| Task | Description | Priority | Est. Time

| **Styles implementation**
| Implement document styles (styles.xml)
| **Critical**
| **2 days**

| **List styles (numbered)**
| Implement numbered list styles and numbering.xml
| **Critical**
| **1.5 days**

| **List styles (bulleted)**
| Implement bulleted list styles
| **Critical**
| **1 day**

| **Table enhancements**
| Complete table borders, shading, cell merging
| High
| 1.5 days

| **Headers implementation**
| Implement header sections (header1.xml, header2.xml, etc.)
| High
| 1.5 days

| **Footers implementation**
| Implement footer sections (footer1.xml, footer2.xml, etc.)
| High
| 1.5 days

| **TextBox implementation**
| Implement text boxes with positioning
| Medium
| 1.5 days

| **Caption implementation**
| Implement figure/table captions with auto-numbering
| Medium
| 1 day

| Bookmarks and anchors
| Implement bookmark handling
| Medium
| 1 day

| Footnotes and endnotes
| Implement notes handling
| Medium
| 1 day

| Sections and page setup
| Implement section properties
| Medium
| 1 day
|===

**Detailed Feature Breakdown**:

**1. Styles (styles.xml)**:
- Create [`lib/uniword/style.rb`](lib/uniword/style.rb:1):
  - Style definition with styleId, name, type
  - Paragraph styles, character styles, table styles
  - Style inheritance (basedOn)
  - Linked styles
- Create [`lib/uniword/styles_configuration.rb`](lib/uniword/styles_configuration.rb:1):
  - Manages document-level styles
  - Default styles (Normal, Heading1-9, etc.)
  - Custom user styles
- OOXML: Generate/parse word/styles.xml
- Integration: Link paragraphs/runs to styles

**2. List Styles (Numbered)**:
- Create [`lib/uniword/numbering_definition.rb`](lib/uniword/numbering_definition.rb:1):
  - Abstract numbering definition
  - Numbering levels (0-8)
  - Number format (decimal, upperRoman, lowerLetter, etc.)
  - Start value, restart rules
- Create [`lib/uniword/numbering_instance.rb`](lib/uniword/numbering_instance.rb:1):
  - Concrete numbering instance
  - Links to abstract definition
  - Level overrides
- Create [`lib/uniword/list_paragraph.rb`](lib/uniword/list_paragraph.rb:1):
  - Paragraph with numbering properties
  - Level (indent level)
  - Reference to numbering instance
- OOXML: Generate/parse word/numbering.xml
- Features: Multi-level lists, restart numbering, custom formats

**3. List Styles (Bulleted)**:
- Extend NumberingDefinition for bullets
- Bullet character customization
- Bullet font/symbol selection
- Integration with paragraph properties

**4. Table Enhancements**:
- Enhance [`lib/uniword/table.rb`](lib/uniword/table.rb:1):
  - Table borders (all sides, individual cells)
  - Cell shading/background colors
  - Cell padding and spacing
  - Column widths
- Create [`lib/uniword/table_border.rb`](lib/uniword/table_border.rb:1):
  - Border style, width, color
  - Per-cell border customization
- Cell merging:
  - Horizontal merge (gridSpan)
  - Vertical merge (vMerge)

**5. Headers**:
- Create [`lib/uniword/header.rb`](lib/uniword/header.rb:1):
  - Header content (paragraphs, tables, images)
  - Different header types (first page, even/odd pages)
  - Header reference in section properties
- OOXML: Generate/parse word/header*.xml
- Relationships: Link headers to document
- Integration: Section-specific headers

**6. Footers**:
- Create [`lib/uniword/footer.rb`](lib/uniword/footer.rb:1):
  - Footer content (paragraphs, tables, images)
  - Different footer types (first page, even/odd pages)
  - Footer reference in section properties
  - Page numbering fields
- OOXML: Generate/parse word/footer*.xml
- Relationships: Link footers to document
- Integration: Section-specific footers

**7. TextBox**:
- Create [`lib/uniword/text_box.rb`](lib/uniword/text_box:1):
  - Text box shape
  - Positioning (absolute, relative)
  - Wrapping style (square, tight, through, etc.)
  - Border and fill properties
  - Text content (paragraphs)
- OOXML: Use VML or DrawingML based on compatibility
- Anchoring: Paragraph or character anchor

**8. Caption**:
- Create [`lib/uniword/caption.rb`](lib/uniword/caption.rb:1):
  - Caption text with label
  - Caption numbering (Figure 1, Table 1, etc.)
  - SEQ field for auto-numbering
  - Caption placement (above/below)
- Integration with figures and tables
- Create [`lib/uniword/field.rb`](lib/uniword/field.rb:1):
  - Complex field structure
  - Field codes (SEQ, REF, PAGEREF, etc.)
  - Field results

**Success Criteria**:
- [ ] ✅ **Can apply paragraph styles (Normal, Heading1-9)**
- [ ] ✅ **Can create numbered lists (1, 2, 3 or a, b, c or i, ii, iii)**
- [ ] ✅ **Can create bulleted lists with custom bullets**
- [ ] ✅ **Tables have borders, shading, merged cells**
- [ ] ✅ **Documents have headers (first page, even/odd different)**
- [ ] ✅ **Documents have footers with page numbers**
- [ ] ✅ **Can insert text boxes with positioning**
- [ ] ✅ **Figures and tables have auto-numbered captions**
- [ ] [ ] Bookmarks navigable in Word
- [ ] [ ] Footnotes/endnotes functional
- [ ] [ ] Multiple sections supported

===== Milestone 2.5: DOCX Round-trip Testing (Week 5)
[cols="2,3,1,1"]
|===
| Task | Description | Priority | Est. Time

| Round-trip validation
| Test read → write → read cycles
| High
| 2 days

| Compatibility testing
| Test with Word 2007, 2010, 2013, 2016, 2019, 365
| High
| 1.5 days

| LibreOffice testing
| Test with LibreOffice Writer
| Medium
| 1 day

| Edge case handling
| Handle malformed/non-standard DOCX
| Medium
| 1 day

| Performance optimization
| Optimize DOCX read/write performance
| Low
| 0.5 day
|===

**Success Criteria**:
- [ ] Round-trip preserves all data
- [ ] Compatible with all tested Word versions
- [ ] Works with LibreOffice Writer
- [ ] Handles edge cases gracefully
- [ ] Performance acceptable (<5s for typical docs)

**Phase 2 Deliverables**:
- Complete DOCX read and write support
- lutaml-model serialization for OOXML
- Round-trip capability
- Extensive DOCX test fixtures
- DOCX API documentation

**Phase 2 Risks**:
- OOXML serialization complexity → Mitigation: Use lutaml-model features; study reference docx gem
- ZIP corruption issues → Mitigation: Validate packages; use proven rubyzip gem
- Namespace handling → Mitigation: Comprehensive lutaml-model namespace configuration
- Performance with large files → Mitigation: Lazy loading; streaming where possible
- Missing edge cases → Mitigation: Build comprehensive test fixture library

=== Phase 3: MHTML Read & Write Support

**Duration**: 3-4 weeks

**Goal**: Implement comprehensive DOC MHTML reading and writing capabilities

==== Milestones

===== Milestone 3.1: MHTML Write Implementation (Week 1)
[cols="2,3,1,1"]
|===
| Task | Description | Priority | Est. Time

| MIME package generator
| Implement MIME multipart structure
| High
| 1.5 days

| HTML to Word converter
| Convert document model to Word HTML
| High
| 2 days

| CSS stylesheet handling
| Integrate Word-specific CSS
| High
| 1 day

| Image embedding
| Embed images in MIME package
| High
| 1 day

| File list generation
| Generate filelist.xml for resources
| Medium
| 0.5 day

| Table HTML generation
| Generate Word-compatible table HTML
| High
| 0.5 day
|===

**Success Criteria**:
- [ ] Can generate valid .doc MHTML files
- [ ] Microsoft Word can open generated files
- [ ] Images display correctly
- [ ] Basic formatting preserved
- [ ] Tables render properly

===== Milestone 3.2: MHTML Read Implementation (Week 2)
[cols="2,3,1,1"]
|===
| Task | Description | Priority | Est. Time

| MIME package parser
| Parse MIME multipart structure
| High
| 1.5 days

| Word HTML parser
| Parse Word-specific HTML into model
| High
| 2 days

| CSS style extraction
| Extract styles from embedded CSS
| High
| 1 day

| Image extraction
| Extract images from MIME parts
| Medium
| 1 day

| List and table parsing
| Parse Word HTML lists and tables
| High
| 1.5 days
|===

**Success Criteria**:
- [ ] Can read .doc MHTML files
- [ ] Extract all document elements
- [ ] Parse formatting correctly
- [ ] Images extracted properly
- [ ] Lists and tables parsed correctly

===== Milestone 3.3: Advanced MHTML Features (Week 3)
[cols="2,3,1,1"]
|===
| Task | Description | Priority | Est. Time

| Math content support
| Add MathML/AsciiMath conversion to Word
| High
| 2 days

| Footnotes and endnotes
| Implement footnote HTML generation
| High
| 1.5 days

| Bookmarks and anchors
| Implement bookmark HTML generation
| Medium
| 1 day

| Section and page layout
| Support multiple sections with different layouts
| Medium
| 1 day

| Header/footer templates
| Support header.html templates
| Medium
| 0.5 day
|===

**Success Criteria**:
- [ ] Math formulas render correctly in Word
- [ ] Footnotes/endnotes functional
- [ ] Bookmarks navigable
- [ ] Multi-section documents supported
- [ ] Headers/footers work with templates

===== Milestone 3.4: MHTML Round-trip Testing (Week 4)
[cols="2,3,1,1"]
|===
| Task | Description | Priority | Est. Time

| Round-trip validation
| Test read → write → read cycles for MHTML
| High
| 2 days

| Compatibility testing
| Test with Word 2003, 2007+, LibreOffice
| High
| 1.5 days

| Format conversion testing
| Test DOCX ↔ MHTML conversions
| High
| 1.5 days

| Edge case handling
| Handle non-standard HTML/CSS
| Medium
| 1 day
|===

**Success Criteria**:
- [ ] Round-trip preserves all data
- [ ] Compatible with tested Word versions
- [ ] DOCX ↔ MHTML conversions work
- [ ] Handles edge cases gracefully

**Phase 3 Deliverables**:
- Complete MHTML read and write support
- Format conversion capability (DOCX ↔ MHTML)
- Math formula support
- Comprehensive MHTML test fixtures
- MHTML API documentation

**Phase 3 Risks**:
- Word HTML/CSS compatibility → Mitigation: Use proven CSS from html2doc
- MIME packaging complexity → Mitigation: Follow html2doc implementation
- Math conversion accuracy → Mitigation: Use Plurimath gem; extensive validation
- Image sizing issues → Mitigation: Use Vectory gem for calculations

=== Phase 4: Enhancement & Release Preparation

**Duration**: 2-3 weeks

**Goal**: Polish functionality, optimize performance, and prepare for v1.0 release

==== Milestones

===== Milestone 4.1: Performance Optimization (Week 1)
[cols="2,3,1,1"]
|===
| Task | Description | Priority | Est. Time

| Memory optimization
| Reduce memory footprint for large docs
| High
| 2 days

| Parsing performance
| Optimize XML/HTML parsing speed
| High
| 1.5 days

| Image optimization
| Optimize image processing pipeline
| Medium
| 1 day

| Lazy loading
| Implement lazy loading for large elements
| Medium
| 1 day

| Benchmarking
| Create performance benchmark suite
| Medium
| 0.5 day
|===

**Success Criteria**:
- [ ] Can handle documents >100 pages efficiently
- [ ] Memory usage <100MB for typical docs
- [ ] Benchmark suite in place
- [ ] No performance regressions

===== Milestone 4.2: Developer Experience (Week 2)
[cols="2,3,1,1"]
|===
| Task | Description | Priority | Est. Time

| API refinement
| Polish public API for ease of use
| High
| 1.5 days

| Error handling
| Comprehensive error messages
| High
| 1 day

| CLI tool
| Command-line interface for conversions
| High
| 1.5 days

| Example applications
| Create example scripts and use cases
| Medium
| 1 day

| Logging and debugging
| Add helpful logging and debug modes
| Medium
| 1 day
|===

**Success Criteria**:
- [ ] API intuitive and well-documented
- [ ] Error messages helpful and actionable
- [ ] CLI tool functional with both formats
- [ ] Examples cover common use cases
- [ ] Debugging tools available

===== Milestone 4.3: Documentation & Release (Week 3)
[cols="2,3,1,1"]
|===
| Task | Description | Priority | Est. Time

| Complete API documentation
| Full API reference with YARD
| High
| 1.5 days

| User guide
| Comprehensive user guide in README.adoc
| High
| 1.5 days

| Migration guides
| Document migration from docx/html2doc gems
| Medium
| 1 day

| Release preparation
| Version tagging, changelog, gem publishing
| High
| 1 day

| Announcement and outreach
| Prepare release announcement
| Low
| 0.5 day
|===

**Success Criteria**:
- [ ] Complete API documentation with examples
- [ ] User guide covers all features
- [ ] Migration guides available
- [ ] v1.0.0 published to RubyGems
- [ ] Release announcement ready

**Phase 4 Deliverables**:
- Performance optimizations
- CLI tool for both formats
- Complete documentation
- Example applications
- v1.0.0 release

**Phase 4 Risks**:
- Documentation incomplete → Mitigation: Start early, iterate throughout
- Performance regressions → Mitigation: Continuous benchmarking
- API breaking changes → Mitigation: Semantic versioning, beta releases

== Resource Planning

=== Team Structure

**Recommended Team**:
- 1 Senior Ruby Developer (full-time)
- 1 Ruby Developer (full-time, Phases 2-4)
- 1 QA Engineer (part-time, all phases)
- 1 Technical Writer (part-time, Phases 3-4)

=== Skill Requirements

**Essential Skills**:
- Advanced Ruby programming
- XML/OOXML expertise
- Object-oriented design
- Model-driven architecture
- Test-driven development
- lutaml-model experience or willingness to learn

**Beneficial Skills**:
- Microsoft Word internals knowledge
- MIME/MHTML format experience
- Document processing experience
- Technical writing

=== Development Environment

**Required Tools**:
- Ruby 2.6+ (preferably 3.x)
- Microsoft Word (for validation)
- LibreOffice (for testing compatibility)
- Git for version control
- VS Code or similar IDE

== Testing Strategy

=== Test Coverage Goals

**Minimum Coverage**: 90% across all phases

**Coverage Breakdown**:
- Unit tests: 95%
- Integration tests: 85%
- End-to-end tests: 80%

=== Test Types

==== Unit Tests

**Scope**: Individual model classes and utilities

**Tools**: RSpec

**Example Focus Areas**:
[source,ruby]
----
describe Uniword::Paragraph do
  it "serializes to XML correctly with lutaml-model"
  it "handles nested text runs"
  it "applies styles properly"
  it "validates required attributes"
  it "round-trips through XML"
end
----

==== Integration Tests

**Scope**: Component interactions

**Example Focus Areas**:
- Document model assembly
- Format handlers working together
- Style inheritance chain
- Image embedding pipeline
- lutaml-model serialization

==== End-to-End Tests

**Scope**: Complete workflows

**Test Fixtures**:
- Simple document (basic.docx, basic.doc)
- Complex formatting (formatting.docx, formatting.doc)
- Tables and lists (tables.docx, tables.doc)
- Images (images.docx, images.doc)
- Math content (math.docx, math.doc)
- Multi-section (sections.docx, sections.doc)

**Validation**:
- Generated files open in Microsoft Word
- Generated files open in LibreOffice
- Round-trip preservation (read → write → read)
- Format conversions (DOCX ↔ MHTML)

==== Regression Tests

**Scope**: Previously fixed bugs

**Maintenance**:
- Add test for each bug fix
- Run full suite before each release
- Track flaky tests separately

=== Testing Tools

* **RSpec** - Main testing framework
* **VCR** - Record/replay HTTP interactions (if needed)
* **SimpleCov** - Code coverage reporting
* **FactoryBot** - Test data factories (if needed)
* **Faker** - Random test data generation

== Success Criteria

=== Phase Success Metrics

==== Phase 1 Success Criteria

- [ ] Core document model implemented with lutaml-model
- [ ] Format handler infrastructure in place
- [ ] Can handle both DOCX and MHTML structures
- [ ] 90%+ test coverage
- [ ] CI/CD pipeline functional
- [ ] Architecture supports extensibility

==== Phase 2 Success Criteria

- [ ] Read and write DOCX files successfully
- [ ] Generated DOCX files open in Word and LibreOffice
- [ ] Round-trip preserves all data
- [ ] Handle 100+ DOCX test fixtures
- [ ] 90%+ test coverage maintained
- [ ] DOCX documentation complete

==== Phase 3 Success Criteria

- [ ] Read and write MHTML files successfully
- [ ] Generated .doc files open in Word and LibreOffice
- [ ] Can convert between DOCX and MHTML
- [ ] Math formulas work in both formats
- [ ] 90%+ test coverage maintained
- [ ] MHTML documentation complete

==== Phase 4 Success Criteria

- [ ] Performance benchmarks met
- [ ] CLI tool functional for both formats
- [ ] Complete API documentation
- [ ] Example applications working
- [ ] Migration guides available
- [ ] Ready for v1.0 release

=== Quality Gates

Each phase must pass these gates before proceeding:

. **Code Review**: All code reviewed and approved
. **Test Coverage**: Minimum 90% coverage achieved
. **Documentation**: All public APIs documented
. **Performance**: No regressions from previous phase
. **Manual Testing**: Sample documents validated in Word/LibreOffice

== Risk Management

=== Technical Risks

[cols="3,2,2,3"]
|===
| Risk | Probability | Impact | Mitigation Strategy

| lutaml-model serialization complexity
| Medium
| High
| Study sts-ruby; extensive testing; iterative refinement

| OOXML namespace handling
| Medium
| High
| Comprehensive namespace config; follow standards

| Word CSS compatibility
| Medium
| High
| Use proven CSS from html2doc; test across Word versions

| MIME packaging issues
| Medium
| Medium
| Follow html2doc implementation; extensive testing

| Image processing bugs
| Medium
| Medium
| Use Vectory gem; validate dimensions; test various formats

| Performance with large docs
| Medium
| High
| Early benchmarking; lazy loading; memory profiling

| Math conversion accuracy
| Medium
| Medium
| Use Plurimath gem; validate against Word; extensive test cases

| ZIP corruption
| Low
| High
| Use rubyzip gem; validate packages; error handling

| Round-trip data loss
| Medium
| High
| Extensive round-trip tests; comparison utilities
|===

=== Project Risks

[cols="3,2,2,3"]
|===
| Risk | Probability | Impact | Mitigation Strategy

| Scope creep
| Medium
| High
| Strict phase boundaries; deferred features list; change control

| Resource availability
| Medium
| High
| Cross-training; documentation; modular design

| Dependency issues
| Low
| Medium
| Pin versions; monitor updates; test compatibility

| Format specification changes
| Low
| Medium
| Monitor OOXML specs; version compatibility matrix

| Performance issues at scale
| Medium
| High
| Early benchmarking; performance tests; optimization sprints
|===

=== Risk Response Plan

**High Priority Risks** (weekly monitoring):
- lutaml-model serialization complexity
- OOXML namespace handling
- Word CSS compatibility
- Performance with large docs
- Round-trip data loss

**Medium Priority Risks** (bi-weekly monitoring):
- Scope creep
- Resource availability
- Image processing bugs
- Math conversion accuracy

**Low Priority Risks** (monthly monitoring):
- Dependency issues
- Format specification changes
- ZIP corruption

== Dependencies & Prerequisites

=== External Dependencies

==== Required Gems

[source,ruby]
----
# Core dependencies
gem "lutaml-model", "~> 0.7"
gem "nokogiri", "~> 1.15"
gem "rubyzip", "~> 2.3"
gem "mime-types", "~> 3.5"
gem "uuidtools", "~> 2.2"

# Optional dependencies
gem "vectory", "~> 0.7"  # Image processing
gem "plurimath", "~> 0.8"  # Math conversion
----

==== Development Gems

[source,ruby]
----
# Testing
gem "rspec"
gem "vcr"
gem "webmock"
gem "simplecov"

# Code quality
gem "rubocop"
gem "rubocop-rspec"

# Development
gem "rake"
gem "pry"
gem "yard"  # Documentation
----

=== Knowledge Prerequisites

**Team should understand**:
- Office Open XML (OOXML) structure
- MIME multipart format
- lutaml-model DSL and serialization
- Word HTML/CSS specifics
- Image format conversions
- XML namespaces

=== Infrastructure Prerequisites

- GitHub repository with CI/CD
- RubyGems account for publishing
- Documentation hosting (GitHub Pages)
- Issue tracking system

== Timeline Summary

=== Overall Schedule

[source]
----
Phase 1: Foundation & Core Model     │██████│ Weeks 1-3
Phase 2: DOCX Read & Write          │██████████│ Weeks 4-8
Phase 3: MHTML Read & Write         │████████│ Weeks 9-12
Phase 4: Enhancement & Release      │██████│ Weeks 13-15
                                     │
Release v1.0.0                       │▲
                                     └────────────────────────
                                     Week 0   5   10   15
----

=== Critical Path

. Project setup → Core models → Format handlers → Phase 1 complete
. OOXML parsing → XML serialization → DOCX write → Phase 2 complete
. MIME parsing → HTML generation → MHTML write → Phase 3 complete
. Optimization → Documentation → CLI tool → Release

=== Milestones & Deliverables

**Week 3**: Phase 1 complete - Core model and architecture
**Week 8**: Phase 2 complete - DOCX read/write support
**Week 12**: Phase 3 complete - MHTML read/write support
**Week 15**: Phase 4 complete - v1.0.0 release ready

== Post-Release Plan

=== Maintenance & Support

**Version 1.x Maintenance**:
- Bug fixes released within 1 week
- Security patches within 24 hours
- Minor feature additions in 1.x.y releases

**Support Channels**:
- GitHub Issues for bug reports
- GitHub Discussions for questions
- Gitter/Discord for community chat

=== Future Enhancements (v2.0+)

**Planned Features**:
- ODT format support
- PDF generation
- Template engine
- Diff/merge capabilities
- Advanced macro handling
- RTF format support

**Community Contributions**:
- Accept pull requests after v1.0
- Maintain CONTRIBUTING.md
- Regular community updates

== Appendices

=== Appendix A: Reference Architecture Comparison

[cols="2,3,3,2"]
|===
| Aspect | docx gem | html2doc gem | Uniword (planned)

| Format Support
| DOCX read/write
| DOC MHTML write
| Both formats read/write

| Architecture
| Container-based
| Procedural
| Model-driven (lutaml)

| XML Handling
| Nokogiri direct
| Nokogiri direct
| lutaml-model (bidirectional)

| API Style
| Imperative
| Functional
| Declarative

| Extensibility
| Moderate
| Low
| High

| Serialization
| Manual XML building
| String templates
| lutaml-model automatic
|===

=== Appendix B: Format Specifications

**DOCX (Office Open XML)**:
- Specification: ECMA-376, ISO/IEC 29500
- Structure: ZIP archive with XML files
- Key components: document.xml, styles.xml, relationships
- Namespaces: Multiple OOXML namespaces

**DOC MHTML**:
- Structure: MIME multipart with HTML
- CSS: Word-specific extensions
- Images: Base64 embedded in MIME parts
- Legacy format (pre-2007)

=== Appendix C: Glossary

**DOCX**:: Modern Word document format (Office 2007+)
**DOC MHTML**:: HTML-based Word format with MIME packaging
**OOXML**:: Office Open XML, Microsoft's document standard
**OMML**:: Office Math Markup Language
**lutaml-model**:: Ruby gem for declarative XML models with automatic serialization
**Vectory**:: Image processing gem used by Metanorma
**Plurimath**:: Math conversion gem supporting multiple formats

=== Appendix D: Related Projects

**Within Metanorma Ecosystem**:
- edoxen - Template for new gems
- html2doc - HTML to DOC converter
- sts-ruby - STS XML parser demonstrating lutaml-model usage

**External References**:
- docx-js - TypeScript DOCX library
- docxjs - DOCX to HTML renderer
- word-to-markdown - Word to Markdown converter
- docx gem - Ruby DOCX read/write library

=== Appendix E: lutaml-model Usage Examples

**Example 1: Simple Element**
[source,ruby]
----
class Paragraph < Lutaml::Model::Serializable
  xml do
    root "p", namespace: "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    map_element "r", to: :runs
  end

  attribute :runs, :array, item_class: Run
end
----

**Example 2: Attributes and Elements**
[source,ruby]
----
class Style < Lutaml::Model::Serializable
  xml do
    root "style"
    map_attribute "styleId", to: :id
    map_attribute "type", to: :type
    map_element "name", to: :name
  end

  attribute :id, :string
  attribute :type, :string
  attribute :name, :string
end
----

**Example 3: Nested Structures**
[source,ruby]
----
class Table < Lutaml::Model::Serializable
  xml do
    root "tbl"
    map_element "tblPr", to: :properties
    map_element "tr", to: :rows
  end

  attribute :properties, TableProperties
  attribute :rows, :array, item_class: TableRow
end
----

== Conclusion

This development plan provides a comprehensive roadmap for building the Uniword gem with full read/write support for both DOCX and MHTML formats. The phased approach allows for iterative development with clear milestones and success criteria.

**Key Success Factors**:
- Strong model-driven architecture using lutaml-model
- Bidirectional serialization from the start
- Comprehensive testing at all levels
- Clear phase boundaries with gates
- Risk management and mitigation
- Focus on developer experience
- Format conversion capabilities

**Unique Advantages**:
- Unified model for both formats
- Automatic XML serialization with lutaml-model
- Round-trip capability for both formats
- Format conversion (DOCX ↔ MHTML)
- Clean, declarative API
- Extensible architecture

**Next Steps**:
1. Review and approve this plan
2. Allocate resources and team
3. Setup development environment
4. Begin Phase 1 implementation
5. Schedule weekly progress reviews
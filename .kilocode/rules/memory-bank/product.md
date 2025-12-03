// ... existing code ...
# Uniword: Product Description

## What is Uniword?

Uniword is a comprehensive Ruby library for creating and manipulating Microsoft Word documents programmatically. It provides a high-level, object-oriented API for working with both modern DOCX (Word 2007+) and legacy MHTML (Word 2003+) formats.

## Problems It Solves

### 1. Document Generation Complexity
**Problem**: Creating Word documents programmatically is complex - developers must understand OOXML (Office Open XML) specification, ZIP packaging, XML namespaces, and intricate relationships between document parts.

**Solution**: Uniword abstracts OOXML complexity behind an intuitive Ruby API. Developers work with Ruby objects (Document, Paragraph, Run, Table) rather than raw XML.

### 2. Format Compatibility
**Problem**: Supporting both modern DOCX and legacy MHTML formats requires separate implementations and conversion logic.

**Solution**: Uniword provides unified API for both formats with automatic conversion and format detection.

### 3. Professional Document Styling
**Problem**: Creating professionally styled documents requires deep knowledge of Word's style system, themes, and StyleSets.

**Solution**: Uniword bundles Microsoft Office themes and StyleSets, allowing developers to apply professional formatting with single method calls like `doc.apply_theme('celestial')` or `doc.apply_styleset('distinctive')`.

### 4. Round-Trip Fidelity
**Problem**: Reading and writing documents often loses formatting, styles, or content due to incomplete parsing or serialization.

**Solution**: Uniword focuses on perfect round-trip support - documents loaded and saved should be byte-identical or semantically equivalent, preserving all formatting and structure.

### 5. HTML to Word Conversion
**Problem**: Converting HTML content to Word format is challenging, especially maintaining formatting and structure.

**Solution**: Uniword includes comprehensive HTML importer that handles paragraphs, headings, tables, lists, images, inline formatting, and CSS styles, providing html2doc gem compatibility.

## How It Works

### Document Model Architecture

Uniword uses a **domain-driven model**:
- `Document` contains `Body` with `Elements` (Paragraphs, Tables)
- `Paragraph` contains `Runs` (text with formatting)
- Properties objects (`ParagraphProperties`, `RunProperties`) define formatting
- Styles, Themes, and StyleSets provide reusable formatting

### Serialization Layer

Uniword separates concerns:
- **Models** (document structure) are format-agnostic
- **Serializers** (OoxmlSerializer, MhtmlSerializer) handle format-specific XML generation
- **Deserializers** parse XML back into models
- **Format Handlers** orchestrate serialization, ZIP packaging, and relationships

### Theme and StyleSet System

Professional documents require:
- **Themes**: Define colors and fonts (e.g., "Celestial", "Atlas")
- **StyleSets**: Define style definitions for headings, body text, etc (e.g., "Distinctive", "Formal")
- **Combination**: Apply both for complete professional styling

## User Experience Goals

### 1. Intuitive API

```ruby
# Simple document creation
doc = Uniword::Document.new
doc.add_paragraph("Hello World", bold: true, heading: :heading_1)
doc.save('output.docx')

# Professional styling
doc.apply_theme('celestial')
doc.apply_styleset('distinctive')
```

### 2. Builder Pattern for Fluent Construction

```ruby
doc = Uniword::Builder.new
  .add_heading('Report', level: 1)
  .add_paragraph('Introduction')
  .add_table do
    row do
      cell 'Header 1', bold: true
      cell 'Header 2', bold: true
    end
  end
  .build
```

### 3. Format Transparency

```ruby
# Auto-detects format from extension
doc = Uniword::Document.open('document.docx')
doc.save('output.doc')  # Auto-converts to MHTML
```

### 4. Comprehensive Feature Support

- Text formatting (bold, italic, fonts, colors, sizes)
- Paragraph formatting (alignment, spacing, indentation, numbering)
- Tables (borders, cell merging, styling)
- Images (inline and positioned)
- Headers and footers
- Hyperlinks and bookmarks
- Math equations (Office Math Markup Language)
- Track changes and comments
- StyleSets and themes

### 5. Developer Experience

- Clear error messages with context
- Comprehensive test suite (2100+ test examples)
- Extensive documentation with examples
- CLI tools for common operations
- Performance optimization for large documents (lazy loading, streaming)

## Target Users

### Primary: Ruby Developers
Developers building applications that generate Word documents - reports, invoices, contracts, form letters, etc.

### Secondary: System Integrators
Teams converting legacy document generation systems or integrating document generation into workflows.

### Use Cases
- **Report Generation**: Automated business reports with charts and tables
- **Document Templates**: Fill template documents with dynamic data
- **Content Management**: Generate documents from CMS content
- **HTML to Word**: Convert web content to Word format
- **Document Processing**: Batch process and transform Word documents
- **Compliance Documents**: Generate standardized documents with consistent styling

## Success Metrics

1. **Correctness**: Perfect round-trip for common documents (< 5% size variance)
2. **Completeness**: 100% feature parity with docx-js and html2doc gems
3. **Performance**: < 500ms to load and apply StyleSet
4. **Developer Experience**: Clear API, comprehensive docs, helpful error messages
5. **Adoption**: Use in production applications for report generation and document processing

## Future Vision (v2.0.0)

**Schema-Driven Architecture**: Move from hardcoded XML generation to external YAML-based OOXML schema definitions, enabling:
- 100% ISO 29500 specification coverage
- Easy extensibility for new OOXML elements
- Zero hardcoding in serializers
- Community contributions for new features

This transforms Uniword from a "pretty good" Word library to the **definitive Ruby solution for OOXML documents**.
// ... existing code ...
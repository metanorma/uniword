# 10: CLI `generate` — style-driven document generation from structured text

**Priority:** P1
**Effort:** Large (~8 hours)
**Files:**
- `lib/uniword/cli.rb` (add `generate` command)
- `lib/uniword/generation/style_extractor.rb` (new)
- `lib/uniword/generation/style_mapper.rb` (new)
- `lib/uniword/generation/structured_text_parser.rb` (new)
- `lib/uniword/generation/document_generator.rb` (new)
- `config/style_mappings/iso_publication.yml` (new)

## Use Case

ISO editors have structured content (title, scope, terms, definitions, annexes)
and need to produce DOCX files that match ISO Central Secretariat formatting.
The styles live in existing ISO documents (461 named styles in ISO 6709).

The workflow:
1. Extract styles from an existing ISO document (e.g., ISO 6709 ed.3)
2. Define a mapping from semantic text elements to ISO style names
3. Feed structured text through the mapping
4. Generate a DOCX that looks like an ISO standard

## Proposed CLI Syntax

```bash
# Generate from YAML input using styles extracted from an ISO document
uniword generate document.yml output.docx --style-source "ISO 6709 ed.3.docx"

# Generate with explicit style mapping
uniword generate document.yml output.docx \
  --style-source "ISO 6709 ed.3.docx" \
  --style-mapping config/style_mappings/iso_publication.yml

# Extract styles from an ISO document into a reusable YAML StyleSet
uniword styleset extract "ISO 6709 ed.3.docx" --name iso-6709

# Then generate using the extracted StyleSet
uniword generate document.yml output.docx --styleset iso-6709

# Generate from Markdown with frontmatter style configuration
uniword generate document.md output.docx --style-source "ISO 6709 ed.3.docx"

# Generate from AsciiDoc
uniword generate document.adoc output.docx --style-source "ISO 6709 ed.3.docx"
```

## Structured Text Input Formats

### YAML Input (most precise)

```yaml
# document.yml
metadata:
  title: "ISO 6709:2023"
  subtitle: "Standard representation of geographic point location"
  doc_number: "6709"
  edition: "3"
  stage: "60.60"  # publication stage

content:
  - element: cover
    style: zzCover
    lines:
      - style: std_docNumber
        text: "ISO 6709"
      - style: std_docPartNumber
        text: ""
      - style: std_docTitle
        text: "Standard representation of geographic point location"
      - style: std_publisher
        text: "Reference number"

  - element: copyright
    style: zzCopyright
    text: "ISO 2023"

  - element: section
    number: "1"
    title:
      style: Heading1
      text: "Scope"
    body:
      - style: BodyText
        text: "This document specifies the representation of latitude..."
      - style: BodyText
        text: "It is applicable to the interchange..."

  - element: section
    number: "2"
    title:
      style: Heading1
      text: "Normative references"
    body:
      - style: BodyText
        text: "The following documents are referred to..."

  - element: terms
    title:
      style: Heading1
      text: "Terms and definitions"
    terms:
      - number:
          style: TermNum
          text: "3.1"
        term:
          style: "Term(s)"
          text: "geographic point location"
        definition:
          style: Definition
          text: "position of a specific point on the surface of the Earth..."
        examples:
          - style: Example
            text: "The coordinates of ISO's headquarters are..."

  - element: note
    style: Note
    text: "For the purposes of this document..."

  - element: table
    title:
      style: "Table title"
      text: "Table 1 — Example coordinates"
    header_style: "Table header"
    body_style: "Table body"
    rows:
      - ["Location", "Latitude", "Longitude"]
      - ["London", "51.50853", "-0.12574"]
      - ["Tokyo", "35.67856", "139.68166"]

  - element: annex
    letter: "A"
    title:
      style: ANNEX
      text: "Examples of representation"
    body:
      - style: BodyText
        text: "This annex provides examples..."
```

### Markdown Input (simpler)

```markdown
---
style-source: "ISO 6709 ed.3.docx"
mapping: iso_publication
---

# 1 Scope

This document specifies the representation of latitude...

It is applicable to the interchange...

> **NOTE** For the purposes of this document...

## 1.1 General

The representation consists of...

# 2 Normative references

The following documents are referred to...

# 3 Terms and definitions

For the purposes of this document, the following terms apply.

## 3.1
**geographic point location**
position of a specific point on the surface of the Earth

> **EXAMPLE** The coordinates are...

# Annex A (informative)
Examples of representation

This annex provides examples...
```

## Style Mapping Configuration

```yaml
# config/style_mappings/iso_publication.yml
# Maps semantic elements to ISO-specific OOXML style names

document:
  default_paragraph_style: "Body Text"
  default_character_style: null

elements:
  cover:
    paragraph_style: "zzCover"
    children:
      doc_number: "std_docNumber"
      doc_part: "std_docPartNumber"
      doc_title: "std_docTitle"
      publisher: "std_publisher"

  copyright:
    paragraph_style: "zzCopyright"

  heading_1:
    paragraph_style: "Heading1"

  heading_2:
    paragraph_style: "Heading2"

  heading_3:
    paragraph_style: "Heading3"

  body:
    paragraph_style: "Body Text"

  body_indent:
    paragraph_style: "Body Text Indent"

  block_text:
    paragraph_style: "Block Text"

  term_number:
    paragraph_style: "TermNum"

  term:
    paragraph_style: "Term(s)"

  definition:
    paragraph_style: "Definition"

  note:
    paragraph_style: "Note"
    prefix: "NOTE"

  note_heading:
    paragraph_style: "Note Heading"

  example:
    paragraph_style: "Example"
    prefix: "EXAMPLE"

  table_title:
    paragraph_style: "Table title"

  table_header:
    paragraph_style: "Table header"

  table_body:
    paragraph_style: "Table body"

  figure_title:
    paragraph_style: "Figure title"

  annex_title:
    paragraph_style: "ANNEX"

  biblio_title:
    paragraph_style: "Biblio Title"

  foreword_title:
    paragraph_style: "Foreword Title"

  foreword_text:
    paragraph_style: "Foreword Text"

  formula:
    paragraph_style: "Formula"

  source:
    paragraph_style: "Source"

  list_bullet:
    paragraph_style: "List Bullet 1"

  list_number:
    paragraph_style: "List Number 1"
```

## Implementation

### Style Extractor

```ruby
module Uniword
  module Generation
    class StyleExtractor
      # Extracts a complete StyleSet from an existing DOCX file.
      # The DOCX's word/styles.xml contains 100+ style definitions.
      #
      # This already partially works via:
      #   doc = DocumentFactory.from_file('ISO 6709.docx')
      #   doc.styles_configuration.styles
      #
      # What's new: serialize to a reusable YAML StyleSet file.

      def self.extract_from_docx(docx_path)
        doc = DocumentFactory.from_file(docx_path)
        styles = doc.styles_configuration.styles

        StyleSet.new(
          name: File.basename(docx_path, ".docx"),
          styles: styles,
          theme: doc.theme,
          styles_configuration: doc.styles_configuration,
        )
      end

      def self.extract_to_yaml(docx_path, output_path)
        styleset = extract_from_docx(docx_path)

        # Serialize each style to YAML
        yaml_data = {
          name: styleset.name,
          styles: styleset.styles.each_with_object({}) do |style, hash|
            hash[style.style_id] = serialize_style(style)
          end,
        }

        File.write(output_path, YAML.dump(yaml_data))
        yaml_data
      end

      private

      def self.serialize_style(style)
        {
          id: style.style_id,
          type: style.type,
          name: style.name&.value,
          based_on: style.based_on&.value,
          next: style.next&.value,
          properties: style.run_properties&.to_h,
          paragraph_properties: style.paragraph_properties&.to_h,
        }
      end
    end
  end
end
```

### Style Mapper

```ruby
module Uniword::Generation
  class StyleMapper
    def initialize(mapping_config)
      @mapping = load_mapping(mapping_config)
    end

    def style_for(element_type, context = {})
      mapping = @mapping.dig("elements", element_type.to_s)
      return nil unless mapping

      mapping["paragraph_style"]
    end

    def default_paragraph_style
      @mapping.dig("document", "default_paragraph_style") || "Normal"
    end

    def child_style(parent, child_type)
      @mapping.dig("elements", parent.to_s, "children", child_type.to_s)
    end

    private

    def load_mapping(config)
      if config.is_a?(String)
        path = File.join(Uniword.root, "config", "style_mappings", "#{config}.yml")
        YAML.safe_load(File.read(path))
      else
        config
      end
    end
  end
end
```

### Structured Text Parser

```ruby
module Uniword::Generation
  class StructuredTextParser
    def parse(input_path)
      case File.extname(input_path).downcase
      when ".yml", ".yaml"
        parse_yaml(input_path)
      when ".md", ".markdown"
        parse_markdown(input_path)
      when ".adoc", ".asciidoc"
        parse_asciidoc(input_path)
      else
        raise Error, "Unsupported input format: #{File.extname(input_path)}"
      end
    end

    private

    def parse_yaml(path)
      data = YAML.safe_load(File.read(path))
      StructuredDocument.new(data)
    end

    def parse_markdown(path)
      content = File.read(path)

      # Extract YAML frontmatter
      frontmatter = {}
      if content.start_with?("---")
        _, fm, body = content.split("---", 3)
        frontmatter = YAML.safe_load(fm) || {}
        content = body
      end

      elements = []
      current_section = nil

      content.each_line do |line|
        stripped = line.strip

        if stripped.start_with?("# ")
          # Heading 1
          elements << { element: :heading_1, text: stripped.sub("# ", "") }
        elsif stripped.start_with?("## ")
          elements << { element: :heading_2, text: stripped.sub("## ", "") }
        elsif stripped.start_with?("### ")
          elements << { element: :heading_3, text: stripped.sub("### ", "") }
        elsif stripped.start_with?("> **NOTE**")
          elements << { element: :note, text: stripped.sub("> **NOTE** ", "") }
        elsif stripped.start_with?("> **EXAMPLE**")
          elements << { element: :example, text: stripped.sub("> **EXAMPLE** ", "") }
        elsif stripped.start_with?(">")
          # Continuation of previous note/example or blockquote
          elements << { element: :block_text, text: stripped.sub("> ", "") }
        elsif stripped.match?(/\*\*(.+)\*\*/) && elements.last&.dig(:element) == :heading_2
          # Term after heading — likely a term definition
          elements << { element: :term, text: stripped.gsub(/\*\*/, "") }
        elsif stripped.start_with?("# Annex")
          elements << { element: :annex_title, text: stripped.sub("# ", "") }
        elsif stripped.match?(/\A\|.*\|\z/)
          # Table row — handled separately
        elsif stripped.present?
          elements << { element: :body, text: stripped }
        end
      end

      StructuredDocument.new(
        metadata: frontmatter,
        content: elements
      )
    end

    def parse_asciidoc(path)
      # AsciiDoc parsing for structured content
      # Uses simple line-based parsing (not full Asciidoctor AST)
      # Headers: == Heading 1, === Heading 2, etc.
      # Terms: term:: definition
      # Notes: [NOTE]\n====
      # Annexes: [appendix]\n== Annex title
      raise NotImplementedError, "AsciiDoc parsing not yet implemented"
    end
  end

  StructuredDocument = Struct.new(:metadata, :content, keyword_init: true)
end
```

### Document Generator

```ruby
module Uniword::Generation
  class DocumentGenerator
    def initialize(style_source:, style_mapping: nil)
      @style_source = style_source
      @style_mapping = style_mapping
      @mapper = nil
    end

    def generate(structured_doc, output_path)
      # 1. Load styles from source DOCX
      source_doc = DocumentFactory.from_file(@style_source)
      styles_config = source_doc.styles_configuration

      # 2. Load style mapping
      @mapper = StyleMapper.new(@style_mapping || infer_mapping(structured_doc))

      # 3. Build new document with those styles
      builder = Builder::DocumentBuilder.new

      # Copy all styles from source into new document
      styles_config.styles.each do |style|
        builder.define_style(style.style_id) do |s|
          copy_style_properties(s, style)
        end
      end

      # Copy theme
      if source_doc.theme
        builder.document.theme = source_doc.theme
      end

      # 4. Generate content using structured doc + style mapping
      generate_content(builder, structured_doc)

      # 5. Save
      builder.save(output_path)
    end

    private

    def generate_content(builder, structured_doc)
      return unless structured_doc.content

      structured_doc.content.each do |element|
        style_name = @mapper.style_for(element[:element])
        text = element[:text]

        builder.paragraph do |p|
          p.style = style_name if style_name
          p << text if text
        end
      end
    end

    def infer_mapping(structured_doc)
      # If no mapping specified, try to detect from metadata or use defaults
      structured_doc.metadata&.dig("mapping") || "iso_publication"
    end

    def copy_style_properties(style_builder, source_style)
      # Copy properties from source style to builder
      if rp = source_style.run_properties
        style_builder.font_size(rp.font_size) if rp.respond_to?(:font_size) && rp.font_size
        style_builder.bold(rp.bold) if rp.respond_to?(:bold) && rp.bold
        style_builder.italic(rp.italic) if rp.respond_to?(:italic) && rp.italic
        # ... etc
      end
    end
  end
end
```

### CLI Integration

```ruby
desc "generate INPUT OUTPUT", "Generate DOCX from structured text with style source"
long_desc <<~DESC
  Generate a DOCX document from structured text (YAML/Markdown) using styles
  extracted from an existing DOCX file.

  Examples:
    $ uniword generate document.yml output.docx --style-source "ISO 6709.docx"
    $ uniword generate document.md output.docx --style-source "ISO 6709.docx" --style-mapping iso_publication
DESC
option :style_source, required: true, desc: "Source DOCX for styles"
option :style_mapping, desc: "Style mapping config name or path"
option :styleset, desc: "Use a pre-extracted StyleSet (alternative to --style-source)"
def generate(input_path, output_path)
  generator = Generation::DocumentGenerator.new(
    style_source: options[:style_source],
    style_mapping: options[:style_mapping]
  )

  parser = Generation::StructuredTextParser.new
  structured_doc = parser.parse(input_path)

  generator.generate(structured_doc, output_path)
  say("Generated: #{output_path}", :green)
end
```

Also add `styleset extract` command:

```ruby
# In StyleSetCLI
desc "extract DOCX", "Extract styles from a DOCX file into a YAML StyleSet"
option :name, required: true, desc: "StyleSet name"
option :output, desc: "Output YAML file (default: data/stylesets/<name>.yml)"
def extract(docx_path)
  output = options[:output] || "data/stylesets/#{options[:name]}.yml"
  Generation::StyleExtractor.extract_to_yaml(docx_path, output)
  say("StyleSet extracted: #{output}", :green)
end
```

## Key Design Decisions

1. **Style source is a real DOCX**: extract actual OOXML styles from ISO documents,
   not hand-crafted YAML approximations. The 461 styles in ISO 6709's
   `word/styles.xml` are the ground truth.
2. **Three input formats**: YAML (most precise control), Markdown (easy authoring),
   AsciiDoc (MetaNorma ecosystem). Start with YAML, add Markdown second.
3. **Style mapping is configuration**: `config/style_mappings/iso_publication.yml`
   maps semantic element names to ISO-specific style IDs. Different ISO
   templates (Publication, FDIS, DIS) can have different mappings.
4. **Reuses Builder API**: `DocumentBuilder`, `ParagraphBuilder`, `StyleBuilder`
   already exist. The generator orchestrates them.
5. **Preserves complete style fidelity**: by copying all 461 styles from the
   source document, the generated document looks identical to the source template.

## Verification

```bash
# Extract styles from ISO 6709
bundle exec uniword styleset extract "spec/fixtures/uniword-private/fixtures/iso/ISO 6709 ed.3 - id.75147 Publication Word (en).docx" --name iso-6709

# Create a test YAML document
cat > /tmp/test_iso.yml <<'EOF'
metadata:
  title: "ISO TEST:2023"
content:
  - element: heading_1
    text: "1 Scope"
  - element: body
    text: "This document specifies..."
  - element: note
    text: "For the purposes of this document..."
EOF

# Generate
bundle exec uniword generate /tmp/test_iso.yml /tmp/test_iso.docx --style-source "spec/fixtures/uniword-private/fixtures/iso/ISO 6709 ed.3 - id.75147 Publication Word (en).docx"
```

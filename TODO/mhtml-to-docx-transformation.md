# TODO: MHTML to DOCX Content Transformation

## Status: PENDING IMPLEMENTATION

## Problem Statement

MHTML to DOCX format conversion succeeds but doesn't preserve content because the
transformation doesn't parse HTML and create OOXML paragraph structures.

### Current Behavior

```ruby
# MHTML document has HTML content
mhtml_doc.html_content = "<p>Hello World</p>"

# Convert to DOCX
result = converter.mhtml_to_docx(source: 'input.mhtml', target: 'output.docx')

# Load converted document
docx_doc = Uniword.load('output.docx')
docx_doc.text  # => ""  (empty - content not transformed!)
```

### Expected Behavior

```ruby
docx_doc.text  # => "Hello World"
docx_doc.paragraphs.count  # => 1
docx_doc.paragraphs.first.runs.first.text  # => "Hello World"
```

## Root Cause Analysis

The `Transformer.mhtml_to_docx` method:

1. ✓ Creates a new `Wordprocessingml::DocumentRoot`
2. ✓ Copies metadata (styles, numbering) from source
3. ✗ Tries to transform `source.body.elements` but MHTML has `html_content`, not `body`

```ruby
# lib/uniword/transformation/transformer.rb (current)
def transform_body_elements(source, target, source_format, target_format)
  # For MHTML, this gets empty array because Mhtml::Document has no body.elements
  elements = if source.respond_to?(:body) && source.body
               source.body.elements
             elsif source.respond_to?(:elements)
               source.elements  # Also empty - Mhtml::Document has html_content
             else
               []
             end
  # ...
end
```

## Solution: HTML to OOXML Transformation

### Architecture

```
Mhtml::Document                 Wordprocessingml::DocumentRoot
├── html_content (String)  -->  ├── body
│   "<p>Hello</p>"              │   ├── paragraphs[0]
│                               │   │   └── runs[0].text = "Hello"
│                               │   └── properties...
```

### Implementation Plan

#### Phase 1: HTML Parser

Create an HTML to OOXML element transformer:

```ruby
# lib/uniword/transformation/html_to_ooxml_transformer.rb
module Uniword
  module Transformation
    class HtmlToOoxmlTransformer
      # Transform HTML string to OOXML paragraphs
      #
      # @param html [String] HTML content
      # @return [Array<Wordprocessingml::Paragraph>] Array of paragraphs
      def transform(html)
        doc = Nokogiri::HTML.fragment(html)
        paragraphs = []

        doc.children.each do |node|
          case node.name
          when 'p'
            paragraphs << transform_paragraph(node)
          when 'h1', 'h2', 'h3', 'h4', 'h5', 'h6'
            paragraphs << transform_heading(node)
          when 'table'
            # Handle tables
          when 'ul', 'ol'
            # Handle lists
          when 'div'
            # Recursively process div contents
            paragraphs.concat(transform(node.inner_html))
          when 'text'
            # Plain text becomes a paragraph
            paragraphs << create_text_paragraph(node.text) if node.text.strip.any?
          end
        end

        paragraphs
      end

      private

      def transform_paragraph(node)
        para = Wordprocessingml::Paragraph.new

        node.children.each do |child|
          case child.name
          when 'text'
            para.add_text(child.text) if child.text.strip.any?
          when 'b', 'strong'
            para.add_text(child.text, bold: true)
          when 'i', 'em'
            para.add_text(child.text, italic: true)
          when 'u'
            para.add_text(child.text, underline: true)
          when 'a'
            para.add_hyperlink(child.text, url: child['href'])
          when 'span'
            # Handle span with style attributes
            transform_span(para, child)
          else
            # Recursively handle nested elements
            para.runs.concat(transform_inline(child).runs)
          end
        end

        para
      end

      def transform_heading(node)
        level = node.name.gsub('h', '').to_i
        para = transform_paragraph(node)
        para.properties = Wordprocessingml::ParagraphProperties.new(
          style: "Heading#{level}"
        )
        para
      end
    end
  end
end
```

#### Phase 2: Update Transformer

Integrate HTML transformer into main Transformer class:

```ruby
# lib/uniword/transformation/transformer.rb
def transform_body_elements(source, target, source_format, target_format)
  if source_format == :mhtml && source.respond_to?(:html_content)
    # MHTML -> DOCX: Parse HTML and create paragraphs
    html_transformer = HtmlToOoxmlTransformer.new
    paragraphs = html_transformer.transform(source.html_content)

    paragraphs.each do |para|
      target.add_element(para)
    end
  elsif source.respond_to?(:body) && source.body
    # DOCX -> DOCX or DOCX -> MHTML: Standard transformation
    source.body.elements.each do |element|
      transformed = transform_element(
        element: element,
        source_format: source_format,
        target_format: target_format
      )
      Array(transformed).each { |e| target.add_element(e) }
    end
  end
end
```

#### Phase 3: Style Preservation

Map HTML styles to OOXML properties:

```ruby
def transform_span(para, span_node)
  style = span_node['style']
  options = {}

  if style
    # Parse CSS style attribute
    styles = CSS.parse(style)
    options[:color] = styles['color'] if styles['color']
    options[:size] = parse_font_size(styles['font-size']) if styles['font-size']
    options[:font] = styles['font-family'] if styles['font-family']
  end

  para.add_text(span_node.text, **options)
end
```

#### Phase 4: Table Transformation

Handle HTML tables:

```ruby
def transform_table(node)
  table = Wordprocessingml::Table.new

  node.css('tr').each do |row_node|
    row = Wordprocessingml::TableRow.new

    row_node.css('td, th').each do |cell_node|
      cell = Wordprocessingml::TableCell.new
      # Transform cell content to paragraphs
      transform(cell_node.inner_html).each do |para|
        cell.paragraphs << para
      end
      row.cells << cell
    end

    table.rows << row
  end

  table
end
```

## Testing

```ruby
# spec/uniword/transformation/html_to_ooxml_transformer_spec.rb
RSpec.describe HtmlToOoxmlTransformer do
  subject(:transformer) { described_class.new }

  describe '#transform' do
    it 'transforms simple paragraph' do
      html = '<p>Hello World</p>'
      paragraphs = transformer.transform(html)

      expect(paragraphs.count).to eq(1)
      expect(paragraphs.first.text).to eq('Hello World')
    end

    it 'transforms heading with style' do
      html = '<h1>Title</h1>'
      paragraphs = transformer.transform(html)

      expect(paragraphs.first.style).to eq('Heading1')
    end

    it 'transforms bold text' do
      html = '<p><b>Bold</b> and <strong>Strong</strong></p>'
      paragraphs = transformer.transform(html)

      expect(paragraphs.first.runs[0].properties.bold).to be_truthy
      expect(paragraphs.first.runs[1].properties.bold).to be_truthy
    end

    it 'preserves links' do
      html = '<p><a href="https://example.com">Link</a></p>'
      paragraphs = transformer.transform(html)

      expect(paragraphs.first.hyperlinks.first.id).to eq('https://example.com')
    end
  end
end
```

## Files to Create/Modify

### New Files
1. `lib/uniword/transformation/html_to_ooxml_transformer.rb`
2. `spec/uniword/transformation/html_to_ooxml_transformer_spec.rb`

### Modified Files
1. `lib/uniword/transformation/transformer.rb` - Integrate HTML transformer
2. `lib/uniword/format_converter.rb` - Update error handling

## Affected Tests

```
spec/uniword/format_converter_spec.rb:
  - preserves content in conversion (FAILED)
  - explicitly declares MHTML to DOCX conversion (PASSES but content not preserved)
```

## Dependencies

- `nokogiri` - Already a dependency
- Optionally `css_parser` for CSS style parsing

## Timeline

- **HTML Parser Implementation**: 2026-03-19
- **Transformer Integration**: 2026-03-20
- **Testing**: 2026-03-20
- **Style Preservation**: 2026-03-21

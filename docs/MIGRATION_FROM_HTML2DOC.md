# Migrating from html2doc gem

This guide helps you migrate from the `html2doc` gem to Uniword.

## Overview

The `html2doc` gem converts HTML to MHTML (DOC) format. Uniword provides similar functionality with a more comprehensive API that supports both MHTML and DOCX formats, along with programmatic document creation.

## Installation

**Before (html2doc gem):**
```ruby
gem 'html2doc'
```

**After (uniword):**
```ruby
gem 'uniword'
```

## Basic HTML to DOC Conversion

### Simple Conversion

**Before (html2doc):**
```ruby
require 'html2doc'

Html2Doc.new(
  filename: 'output',
  imagedir: './images'
).process(html_content)
```

**After (uniword):**
```ruby
require 'uniword'

# Option 1: Use HTML deserializer (if you need HTML parsing)
doc = Uniword::Serialization::HtmlDeserializer.new(html_content).to_document
doc.save('output.doc')

# Option 2: Create document programmatically
doc = Uniword::Document.new
# ... add elements ...
doc.save('output.doc')
```

### With Custom Stylesheet

**Before:**
```ruby
Html2Doc.new(
  filename: 'output',
  stylesheet: 'custom.css'
).process(html_content)
```

**After:**
```ruby
# Uniword uses document styles
doc = Uniword::Document.new

# Create custom styles
doc.styles_configuration.create_paragraph_style(
  'CustomPara',
  'Custom Paragraph',
  paragraph_properties: Uniword::Properties::ParagraphProperties.new(
    alignment: 'center'
  ),
  run_properties: Uniword::Properties::RunProperties.new(
    font: 'Arial',
    size: 24
  )
)

# Add content with custom style
para = Uniword::Paragraph.new
para.set_style('CustomPara')
para.add_text("Styled content")
doc.add_element(para)

doc.save('output.doc')
```

## Migrating Common Patterns

### Converting HTML Tables

**Before (html2doc):**
```ruby
html = "<table><tr><td>A1</td><td>B1</td></tr></table>"
Html2Doc.new(filename: 'output').process(html)
```

**After (uniword):**
```ruby
doc = Uniword::Document.new

table = Uniword::Table.new
row = Uniword::TableRow.new

cell1 = Uniword::TableCell.new
cell1.add_paragraph("A1")
row.add_cell(cell1)

cell2 = Uniword::TableCell.new
cell2.add_paragraph("B1")
row.add_cell(cell2)

table.add_row(row)
doc.add_element(table)

doc.save('output.doc')
```

### Converting HTML with Images

**Before:**
```ruby
html = '<img src="image.png" />'
Html2Doc.new(
  filename: 'output',
  imagedir: './images'
).process(html)
```

**After:**
```ruby
doc = Uniword::Document.new

image = Uniword::Image.new(
  path: 'images/image.png',
  width: 300,
  height: 200
)
doc.add_element(image)

doc.save('output.doc')
```

### Converting HTML Headings

**Before:**
```ruby
html = '<h1>Title</h1><h2>Subtitle</h2><p>Content</p>'
Html2Doc.new(filename: 'output').process(html)
```

**After:**
```ruby
doc = Uniword::Builder.new
  .add_heading('Title', level: 1)
  .add_heading('Subtitle', level: 2)
  .add_paragraph('Content')
  .build

doc.save('output.doc')
```

## Programmatic Document Creation

### Using the Fluent API

Uniword provides a more powerful programmatic API than html2doc:

```ruby
doc = Uniword::Builder.new
  .add_heading('Document Title', level: 1)
  .add_paragraph('Introduction text', bold: true)
  .add_blank_line
  .add_table do
    row do
      cell 'Header 1', bold: true
      cell 'Header 2', bold: true
    end
    row do
      cell 'Data 1'
      cell 'Data 2'
    end
  end
  .add_paragraph('Conclusion')
  .build

doc.save('output.doc')
```

### Direct Element Creation

For more control, create elements directly:

```ruby
doc = Uniword::Document.new

# Add formatted paragraph
para = Uniword::Paragraph.new
para.add_text("Bold text", bold: true)
para.add_text(" Normal text")
para.add_text(" Red text", color: 'FF0000')
doc.add_element(para)

# Add table
table = Uniword::Table.new
# ... configure table ...
doc.add_element(table)

doc.save('output.doc')
```

## Format Flexibility

Unlike html2doc which only outputs MHTML, Uniword supports multiple formats:

```ruby
doc = Uniword::Document.new
# ... add content ...

# Save as MHTML (like html2doc)
doc.save('output.doc')

# Save as DOCX (modern format)
doc.save('output.docx')

# Convert between formats
doc_mhtml = Uniword::DocumentFactory.from_file('input.doc')
doc_mhtml.save('output.docx')
```

## Advanced Features

### Headers and Footers

html2doc had limited header/footer support. Uniword provides full control:

```ruby
doc = Uniword::Document.new
section = doc.current_section

# Add header
header = Uniword::Header.new(type: 'default')
header_para = Uniword::Paragraph.new
header_para.add_text("Document Header", bold: true)
header_para.align('center')
header.add_element(header_para)
section.default_header = header

# Add footer
footer = Uniword::Footer.new(type: 'default')
footer_para = Uniword::Paragraph.new
footer_para.add_text("Page ")
footer_para.add_text("1", field_type: 'page_number')
footer.add_element(footer_para)
section.default_footer = footer
```

### Lists and Numbering

```ruby
# Numbered list
['First', 'Second', 'Third'].each do |item|
  para = Uniword::Paragraph.new
  para.set_numbering(1, 0)
  para.add_text(item)
  doc.add_element(para)
end

# Bulleted list
['Apple', 'Banana', 'Cherry'].each do |item|
  para = Uniword::Paragraph.new
  para.set_numbering(2, 0)  # Different numbering ID for bullets
  para.add_text(item)
  doc.add_element(para)
end
```

### Styles and Formatting

```ruby
# Apply built-in styles
para = Uniword::Paragraph.new
para.set_style('Heading1')
para.add_text("Styled Heading")

# Create custom styles
doc.styles_configuration.create_paragraph_style(
  'Quote',
  'Quote Style',
  paragraph_properties: Uniword::Properties::ParagraphProperties.new(
    alignment: 'left',
    spacing_before: 120,
    spacing_after: 120,
    indent_left: 720  # 0.5 inch
  ),
  run_properties: Uniword::Properties::RunProperties.new(
    italic: true,
    color: '404040'
  )
)

para = Uniword::Paragraph.new
para.set_style('Quote')
para.add_text("This is a quote")
doc.add_element(para)
```

## CLI Tool

Uniword includes a command-line interface for document operations:

```shell
# Convert between formats
uniword convert input.doc output.docx

# Get document information
uniword info document.doc

# Validate document
uniword validate document.doc
```

## Error Handling

Uniword provides comprehensive error handling:

```ruby
begin
  doc = Uniword::DocumentFactory.from_file('file.doc')
  doc.save('output.docx')
rescue Uniword::FileNotFoundError => e
  puts "File not found: #{e.path}"
rescue Uniword::CorruptedFileError => e
  puts "Corrupted file: #{e.reason}"
rescue Uniword::ConversionError => e
  puts "Conversion failed: #{e.message}"
rescue Uniword::Error => e
  puts "Error: #{e.message}"
end
```

## Migration Checklist

- [ ] Update Gemfile to use `uniword` instead of `html2doc`
- [ ] Replace `Html2Doc.new(...).process(html)` with Uniword document creation
- [ ] Convert HTML parsing logic to programmatic element creation
- [ ] Update image handling to use Uniword's Image class
- [ ] Update table creation to use Uniword's Table API
- [ ] Add error handling for file operations
- [ ] Test output format compatibility
- [ ] Consider using DOCX format for better compatibility

## Comparison Table

| Feature | html2doc | Uniword |
|---------|----------|---------|
| HTML to DOC | ✓ | ✓ (via deserializer or programmatic) |
| DOCX support | ✗ | ✓ |
| Programmatic API | Limited | Full featured |
| Tables | Basic | Full control with borders, merging |
| Images | Basic | Full control with positioning |
| Styles | CSS-based | Full Word styles |
| Headers/Footers | Limited | Full support |
| Lists | Basic | Multi-level, custom numbering |
| Format conversion | ✗ | ✓ (DOCX ↔ MHTML) |
| CLI tool | ✗ | ✓ |
| Error handling | Basic | Comprehensive |

## Getting Help

- Documentation: https://www.rubydoc.info/gems/uniword
- Migration examples: See `examples/` directory
- Issues: https://github.com/metanorma/uniword/issues

## Summary

While html2doc focuses on HTML to MHTML conversion, Uniword provides a comprehensive document manipulation library with support for multiple formats, programmatic creation, and extensive features. The migration requires moving from HTML-based input to programmatic document creation, but provides much greater control and flexibility.
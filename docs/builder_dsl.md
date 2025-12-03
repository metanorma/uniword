# Uniword Builder DSL Documentation

The Uniword Builder provides a fluent interface and DSL (Domain-Specific Language) for creating Word documents programmatically.

## Table of Contents

1. [Installation](#installation)
2. [Basic Usage](#basic-usage)
3. [DSL Syntax](#dsl-syntax)
4. [Method Reference](#method-reference)
5. [Examples](#examples)

## Installation

```ruby
require 'uniword'
```

## Basic Usage

There are two ways to use the Builder:

### Method Chaining

```ruby
doc = Uniword::Builder.new
  .add_heading("My Document", level: 1)
  .add_paragraph("Introduction text")
  .add_blank_line
  .add_paragraph("Body text", bold: true)
  .build

doc.save("output.docx")
```

### DSL Block Syntax (Recommended)

```ruby
doc = Uniword::Builder.new do |d|
  d.heading "My Document", level: 1
  d.paragraph "Introduction text"
  d.blank_line
  d.paragraph "Body text", bold: true
end

doc.to_doc.save("output.docx")
```

## DSL Syntax

The DSL provides shorter method names for more natural document construction:

| DSL Method | Full Method | Description |
|------------|-------------|-------------|
| `heading` | `add_heading` | Add a heading paragraph |
| `paragraph` | `add_paragraph` | Add a paragraph |
| `table` | `add_table` | Add a table |
| `blank_line` | `add_blank_line` | Add a blank line |
| `to_doc` | `build` | Get the document object |

## Method Reference

### `heading(text, level:, alignment: nil)`

Add a heading to the document.

**Parameters:**
- `text` (String) - The heading text
- `level` (Integer) - Heading level (1-9), defaults to 1
- `alignment` (String, optional) - Text alignment: 'left', 'right', 'center', 'justify'

**Example:**
```ruby
Uniword::Builder.new do |d|
  d.heading "Chapter 1", level: 1
  d.heading "Section 1.1", level: 2
  d.heading "Centered Title", level: 1, alignment: 'center'
end
```

### `paragraph(text = nil, **options)`

Add a paragraph to the document.

**Parameters:**
- `text` (String, optional) - The paragraph text
- `style` (String, optional) - Paragraph style name
- `alignment` (String, optional) - Text alignment
- `bold` (Boolean) - Make text bold
- `italic` (Boolean) - Make text italic
- `underline` (String) - Underline style
- `font` (String) - Font name
- `size` (Integer) - Font size in half-points
- `color` (String) - Text color in hex (e.g., '00FF00')

**Example:**
```ruby
Uniword::Builder.new do |d|
  d.paragraph "Regular text"
  d.paragraph "Bold text", bold: true
  d.paragraph "Colored text", color: 'FF0000'
  d.paragraph "Custom font", font: 'Arial', size: 24
  d.paragraph "Right aligned", alignment: 'right'
end
```

### `table(&block)`

Add a table to the document with a builder block.

**Block DSL:**
- `row(&block)` - Add a row to the table
  - `cell(text, bold:, italic:, alignment:)` - Add a cell to the row

**Example:**
```ruby
Uniword::Builder.new do |d|
  d.table do
    row do
      cell "Header 1", bold: true
      cell "Header 2", bold: true
    end
    row do
      cell "Data 1"
      cell "Data 2"
    end
  end
end
```

### `blank_line`

Add a blank line (empty paragraph) to the document.

**Example:**
```ruby
Uniword::Builder.new do |d|
  d.paragraph "First paragraph"
  d.blank_line
  d.paragraph "Second paragraph"
end
```

### `to_doc`

Get the built Document object.

**Returns:** `Uniword::Document`

**Example:**
```ruby
builder = Uniword::Builder.new do |d|
  d.paragraph "Hello World"
end

doc = builder.to_doc
doc.save("output.docx")
```

## Examples

### Complete Document Example

```ruby
require 'uniword'

doc = Uniword::Builder.new do |d|
  # Title
  d.heading "Annual Report 2024", level: 1, alignment: 'center'
  d.blank_line

  # Introduction
  d.heading "Executive Summary", level: 2
  d.paragraph "This report presents the key findings and achievements of the year 2024."
  d.blank_line

  # Results Table
  d.heading "Financial Results", level: 2
  d.table do
    row do
      cell "Quarter", bold: true
      cell "Revenue", bold: true
      cell "Growth", bold: true
    end
    row do
      cell "Q1"
      cell "$1.2M"
      cell "+15%"
    end
    row do
      cell "Q2"
      cell "$1.5M"
      cell "+25%"
    end
  end
  d.blank_line

  # Conclusion
  d.heading "Conclusion", level: 2
  d.paragraph "We have achieved significant growth this year.", bold: true
  d.blank_line

  # Footer
  d.paragraph "Generated: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}",
    alignment: 'right',
    italic: true
end

# Save the document
doc.to_doc.save("annual_report.docx")
```

### Minimal Example

```ruby
require 'uniword'

doc = Uniword::Builder.new do |d|
  d.heading "Hello World", level: 1
  d.paragraph "This is my first document!"
end

doc.to_doc.save("hello.docx")
```

### Mixed Styling Example

```ruby
require 'uniword'

doc = Uniword::Builder.new do |d|
  d.heading "Styling Demo", level: 1

  d.paragraph "This is normal text"
  d.paragraph "This is bold text", bold: true
  d.paragraph "This is italic text", italic: true
  d.paragraph "This is red text", color: 'FF0000'
  d.paragraph "This is large text", size: 32
  d.paragraph "This combines multiple styles",
    bold: true,
    italic: true,
    color: '0000FF',
    alignment: 'center'
end

doc.to_doc.save("styling_demo.docx")
```

## Best Practices

1. **Use the DSL block syntax** for better readability and more natural document construction
2. **Group related content** using blank lines to improve document structure
3. **Use heading levels consistently** to maintain proper document hierarchy
4. **Leverage tables** for structured data presentation
5. **Apply styling sparingly** for professional-looking documents

## See Also

- [Main Uniword Documentation](../README.adoc)
- [API Reference](api_reference.md)
- [Examples](../examples/)
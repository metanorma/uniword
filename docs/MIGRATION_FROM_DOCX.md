# Migrating from ruby-docx/docx gem

This guide helps you migrate from the `docx` gem to Uniword.

## Overview

Uniword provides a more comprehensive API with better format support (DOCX and MHTML), improved error handling, and a model-driven architecture. The migration is straightforward with a few API changes.

## Installation

**Before (docx gem):**
```ruby
gem 'docx'
```

**After (uniword):**
```ruby
gem 'uniword'
```

## Reading Documents

### Opening a Document

**Before (docx gem):**
```ruby
require 'docx'

doc = Docx::Document.open('file.docx')
```

**After (uniword):**
```ruby
require 'uniword'

doc = Uniword::DocumentFactory.from_file('file.docx')
# OR
doc = Uniword::Document.open('file.docx')
```

### Accessing Paragraphs

**Before:**
```ruby
doc.paragraphs.each do |p|
  puts p.text
end
```

**After:**
```ruby
doc.paragraphs.each do |p|
  puts p.text
end
```

*Note: The API is the same for basic paragraph access.*

### Accessing Text

**Before:**
```ruby
doc.paragraphs.first.text
```

**After:**
```ruby
doc.paragraphs.first.text
```

## Writing Documents

### Creating a New Document

**Before:**
```ruby
doc = Docx::Document.open('template.docx')
```

**After:**
```ruby
doc = Uniword::Document.new
```

### Modifying Text

**Before:**
```ruby
doc.paragraphs.first.text = "New text"
```

**After:**
```ruby
# Uniword uses runs for text content
doc.paragraphs.first.runs.first.text = "New text"

# OR add new text
para = doc.paragraphs.first
para.runs.clear
para.add_text("New text")
```

### Adding Paragraphs

**Before:**
```ruby
doc.paragraphs << Docx::Elements::Paragraph.new
```

**After:**
```ruby
para = Uniword::Paragraph.new
para.add_text("Text content")
doc.add_element(para)
```

### Saving Documents

**Before:**
```ruby
doc.save('output.docx')
```

**After:**
```ruby
doc.save('output.docx')
# OR with explicit format
doc.save('output.docx', format: :docx)
```

## Working with Tables

### Accessing Tables

**Before:**
```ruby
doc.tables.each do |table|
  table.rows.each do |row|
    row.cells.each do |cell|
      puts cell.text
    end
  end
end
```

**After:**
```ruby
doc.tables.each do |table|
  table.rows.each do |row|
    row.cells.each do |cell|
      puts cell.text
    end
  end
end
```

### Creating Tables

**Before:**
```ruby
table = doc.tables.first
row = table.rows.first
cell = row.cells.first
cell.text = "Updated"
```

**After:**
```ruby
table = Uniword::Table.new
row = Uniword::TableRow.new
cell = Uniword::TableCell.new

para = Uniword::Paragraph.new
para.add_text("Cell content")
cell.add_paragraph(para)

row.add_cell(cell)
table.add_row(row)
doc.add_element(table)
```

## Text Formatting

### Bold, Italic, Underline

**Before:**
```ruby
# docx gem has limited formatting support
doc.paragraphs.first.text = "Bold text"
# Formatting had to be done manually in XML
```

**After:**
```ruby
para = Uniword::Paragraph.new
para.add_text("Bold text", bold: true)
para.add_text(" Italic text", italic: true)
para.add_text(" Underlined", underline: 'single')
```

### Font and Size

**Before:**
```ruby
# Limited support in docx gem
```

**After:**
```ruby
para = Uniword::Paragraph.new
para.add_text("Custom font",
  font: 'Arial',
  size: 24,
  color: 'FF0000'
)
```

## Styles

### Applying Styles

**Before:**
```ruby
# Limited style support in docx gem
```

**After:**
```ruby
para = Uniword::Paragraph.new
para.set_style('Heading1')
para.add_text("Chapter Title")
```

### Custom Styles

**Before:**
```ruby
# Not supported in docx gem
```

**After:**
```ruby
doc.styles_configuration.create_paragraph_style(
  'CustomStyle',
  'My Custom Style',
  paragraph_properties: Uniword::Properties::ParagraphProperties.new(
    alignment: 'center'
  ),
  run_properties: Uniword::Properties::RunProperties.new(
    bold: true,
    color: '0000FF'
  )
)
```

## New Features in Uniword

### Format Conversion

Uniword supports both DOCX and MHTML formats:

```ruby
# Convert DOCX to MHTML
doc = Uniword::DocumentFactory.from_file('input.docx')
doc.save('output.doc')

# Convert MHTML to DOCX
doc = Uniword::DocumentFactory.from_file('input.doc')
doc.save('output.docx')
```

### Builder Pattern

Uniword provides a fluent builder API:

```ruby
doc = Uniword::Builder.new
  .add_heading('Title', level: 1)
  .add_paragraph('Content')
  .add_table do
    row do
      cell 'A1'
      cell 'B1'
    end
  end
  .build
```

### CLI Tool

Uniword includes a command-line tool:

```shell
# Convert documents
uniword convert input.docx output.doc

# Show document info
uniword info document.docx

# Validate documents
uniword validate document.docx
```

### Error Handling

Uniword provides comprehensive error handling:

```ruby
begin
  doc = Uniword::DocumentFactory.from_file('file.docx')
rescue Uniword::FileNotFoundError => e
  puts "File not found: #{e.path}"
rescue Uniword::CorruptedFileError => e
  puts "Corrupted: #{e.reason}"
end
```

## Migration Checklist

- [ ] Update Gemfile to use `uniword` instead of `docx`
- [ ] Change `Docx::Document.open` to `Uniword::DocumentFactory.from_file`
- [ ] Update text modifications to use runs instead of direct text assignment
- [ ] Update paragraph/table creation to use Uniword's API
- [ ] Add error handling for file operations
- [ ] Test all document operations
- [ ] Update any custom XML manipulation (Uniword handles this automatically)

## Common Issues

### Issue: "undefined method `text=' for paragraph"

**Solution:** Use runs to modify text:
```ruby
# Instead of:
para.text = "New text"

# Use:
para.runs.clear
para.add_text("New text")
```

### Issue: "Can't find document elements"

**Solution:** Uniword uses `add_element` instead of `<<`:
```ruby
# Instead of:
doc.paragraphs << para

# Use:
doc.add_element(para)
```

### Issue: "Formatting not applied"

**Solution:** Uniword uses explicit formatting options:
```ruby
para.add_text("Formatted",
  bold: true,
  italic: true,
  color: 'FF0000'
)
```

## Getting Help

- Documentation: https://www.rubydoc.info/gems/uniword
- Issues: https://github.com/metanorma/uniword/issues
- Examples: See the `examples/` directory in the gem

## Summary

Uniword provides a more powerful and flexible API than the docx gem, with better format support, comprehensive error handling, and modern Ruby practices. While some API changes are required, the migration is straightforward and provides significant benefits.
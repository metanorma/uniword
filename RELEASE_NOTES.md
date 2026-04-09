# Uniword v1.0.0 Release Notes

We're excited to announce the first stable release of **Uniword**, a comprehensive Ruby library for Word document manipulation!

## 🎉 What is Uniword?

Uniword is a modern, production-ready Ruby library that provides full read/write support for Microsoft Word documents in both:

- **DOCX** (Word 2007+) - Modern Office Open XML format
- **MHTML** (Word 2003+) - HTML-based legacy format

Built with a clean, model-driven architecture using [lutaml-model](https://github.com/lutaml/lutaml-model), Uniword makes it easy to create, read, modify, and convert Word documents programmatically.

## ✨ Highlights

### Dual Format Support
- **Full DOCX support** - Read and write modern Word documents
- **Full MHTML support** - Work with legacy DOC files
- **Seamless conversion** - Convert between DOCX ↔ MHTML formats
- **Round-trip capability** - Preserve document fidelity

### Rich Feature Set
- **Text formatting** - Bold, italic, underline, color, fonts, sizes
- **Styles** - Paragraph, character, and table styles (built-in and custom)
- **Tables** - Full table support with borders, cell merging, and styling
- **Lists** - Numbered and bulleted lists with multi-level support
- **Images** - Embed images with positioning and sizing
- **Headers/Footers** - Add headers and footers to documents
- **Advanced features** - Footnotes, endnotes, bookmarks, text boxes, math formulas

### Developer Experience
- **Fluent API** - Method chaining for easy document creation
- **Builder pattern** - Declarative syntax for streamlined workflows
- **CLI tool** - Command-line utilities for common operations
- **Comprehensive docs** - Full API documentation and examples
- **Error handling** - Clear error messages and proper exception types

### Production Ready
- **1000+ tests** - Comprehensive test coverage
- **Performance optimized** - Efficient memory usage and fast processing
- **SOLID architecture** - Clean, maintainable codebase
- **Well documented** - API docs, examples, and migration guides

## 🚀 Getting Started

### Installation

```shell
gem install uniword
```

Or add to your Gemfile:

```ruby
gem 'uniword'
```

### Quick Example

```ruby
require 'uniword'

# Create a document
doc = Uniword::Builder.new
  .add_heading('My Document', level: 1)
  .add_paragraph('Introduction text', bold: true)
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
  .build

# Save as DOCX or MHTML
doc.save('output.docx')
doc.save('output.doc')
```

### Reading Documents

```ruby
# Read any supported format
doc = Uniword::DocumentFactory.from_file('input.docx')

# Access content
puts doc.text
doc.paragraphs.each { |p| puts p.text }
doc.tables.each { |t| puts "Table: #{t.row_count} rows" }

# Convert formats
doc.save('output.doc')  # DOCX → MHTML
```

### CLI Usage

```shell
# Convert between formats
uniword convert input.docx output.doc

# Get document info
uniword info document.docx --verbose

# Validate documents
uniword validate document.docx
```

## 📚 Documentation

- **README**: https://github.com/metanorma/uniword/blob/main/README.adoc
- **API Docs**: https://www.rubydoc.info/gems/uniword
- **Examples**: https://github.com/metanorma/uniword/tree/main/examples
- **CHANGELOG**: https://github.com/metanorma/uniword/blob/main/CHANGELOG.md
- **Contributing**: https://github.com/metanorma/uniword/blob/main/CONTRIBUTING.md

## 🔄 Migration Guides

Migrating from other gems? We've got you covered:

- [Migrating from docx gem](https://github.com/metanorma/uniword/blob/main/docs/MIGRATION_FROM_DOCX.md)
- [Migrating from html2doc gem](https://github.com/metanorma/uniword/blob/main/docs/MIGRATION_FROM_HTML2DOC.md)

## 🎯 Use Cases

Uniword is perfect for:

- **Document generation** - Create Word documents from templates or data
- **Format conversion** - Convert between DOCX and MHTML formats
- **Document processing** - Extract, modify, or analyze Word documents
- **Report generation** - Generate formatted reports programmatically
- **Automation** - Automate document workflows and transformations

## 🏗️ Architecture

Uniword follows modern software engineering principles:

- **SOLID principles** - Clean, maintainable code
- **Design patterns** - Strategy, Factory, Builder, Visitor, Registry
- **Model-driven** - Declarative document models with lutaml-model
- **Separation of concerns** - Clear layered architecture
- **Comprehensive testing** - High test coverage

## 🔮 What's Next?

While v1.0.0 is feature-complete and production-ready, we have exciting plans for future releases:

### Planned for v2.0
- **ODT support** - OpenDocument Text format
- **RTF support** - Rich Text Format
- **PDF generation** - Export to PDF
- **Change tracking** - Track document changes
- **Document comparison** - Compare document versions
- **Enhanced styling** - More advanced formatting options

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](https://github.com/metanorma/uniword/blob/main/CONTRIBUTING.md) for details.

## 📝 Examples

### Text Formatting

```ruby
para = Uniword::Paragraph.new
para.add_text("Bold", bold: true)
para.add_text(" Italic", italic: true)
para.add_text(" Red", color: 'FF0000')
```

### Custom Styles

```ruby
doc.styles_configuration.create_paragraph_style(
  'Quote',
  'Quote Style',
  paragraph_properties: Uniword::Properties::ParagraphProperties.new(
    alignment: 'center',
    spacing_before: 120
  ),
  run_properties: Uniword::Properties::RunProperties.new(
    italic: true,
    color: '404040'
  )
)
```

### Lists

```ruby
['First', 'Second', 'Third'].each do |item|
  para = Uniword::Paragraph.new
  para.set_numbering(1, 0)
  para.add_text(item)
  doc.add_element(para)
end
```

## 🙏 Acknowledgments

Uniword builds on the excellent work of:

- [lutaml-model](https://github.com/lutaml/lutaml-model) - Model-driven serialization
- [Nokogiri](https://nokogiri.org/) - XML parsing
- [RubyZip](https://github.com/rubyzip/rubyzip) - ZIP file handling
- [Thor](https://github.com/rails/thor) - CLI framework

## 📄 License

Uniword is available under the [BSD 2-Clause License](https://opensource.org/licenses/BSD-2-Clause).

## 📧 Support

- **Issues**: https://github.com/metanorma/uniword/issues
- **Discussions**: https://github.com/metanorma/uniword/discussions
- **Email**: open.source@ribose.com

## 🎊 Thank You!

Thank you to everyone who contributed to making Uniword v1.0.0 possible. We're excited to see what you build with it!

Happy document processing! 📄✨

---

**Copyright (c) 2024 Ribose Inc.**
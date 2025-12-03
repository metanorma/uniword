# Feature 5: Configurable Styles with Builder DSL

## Objective

**Goal**: Define styles in external YAML configuration and provide a fluent DSL interface to apply styles to document constructs.

**User Problem**:
- Creating styled documents programmatically is verbose
- Style definitions scattered in code (hardcoded)
- Applying consistent styles requires repetitive code
- Changing document styling requires code changes
- No reusable style libraries

**Need**: External style definitions + elegant DSL for applying styles

## Architecture Design

### Principle: Declarative Style Definitions + Fluent Application

**Two-Part System**:
1. **Style Library** (external YAML) - Define all styles
2. **Style DSL** (Ruby) - Apply styles fluently

### Part 1: Style Library (External YAML)

**File Structure**:
```
config/styles/
  iso_standard.yml          # ISO standard document styles
  technical_report.yml      # Technical report styles
  legal_document.yml        # Legal document styles
  custom/
    my_organization.yml     # Custom organizational styles
```

**Style Definition Format** (config/styles/iso_standard.yml):

```yaml
# ISO Standard Document Style Library
# External configuration for all document styles

style_library:
  name: "ISO Standard Styles"
  version: "1.0"
  description: "Standard styles for ISO documents"

  # Paragraph styles
  paragraph_styles:
    title:
      name: "Title"
      base_style: null
      next_style: "subtitle"
      properties:
        alignment: center
        spacing_before: 240  # 12pt
        spacing_after: 120   # 6pt
        keep_next: true
      run_properties:
        font: "Arial"
        size: 32  # 16pt (half-points)
        bold: true
        color: "000000"

    subtitle:
      name: "Subtitle"
      base_style: title
      properties:
        spacing_before: 120
        spacing_after: 240
      run_properties:
        size: 28  # 14pt
        bold: false
        italic: true

    heading_1:
      name: "Heading 1"
      properties:
        outline_level: 0
        page_break_before: false
        keep_next: true
        spacing_before: 240
        spacing_after: 120
      run_properties:
        font: "Arial"
        size: 28
        bold: true
        color: "1F4E78"

    heading_2:
      name: "Heading 2"
      base_style: heading_1
      properties:
        outline_level: 1
        spacing_before: 180
        spacing_after: 60
      run_properties:
        size: 24

    body_text:
      name: "Body Text"
      properties:
        alignment: left
        spacing_after: 120
        line_spacing: 1.15
        line_rule: "auto"
      run_properties:
        font: "Calibri"
        size: 22  # 11pt

    quote:
      name: "Quote"
      base_style: body_text
      properties:
        indent_left: 720   # 0.5 inch
        indent_right: 720
        spacing_before: 120
        spacing_after: 120
      run_properties:
        italic: true
        color: "595959"

  # Character (run) styles
  character_styles:
    emphasis:
      name: "Emphasis"
      run_properties:
        italic: true

    strong:
      name: "Strong"
      run_properties:
        bold: true

    code:
      name: "Code"
      run_properties:
        font: "Consolas"
        size: 20  # 10pt
        color: "C7254E"

    hyperlink:
      name: "Hyperlink"
      run_properties:
        color: "0563C1"
        underline: "single"

  # List styles
  list_styles:
    bullet_list:
      name: "Bullet List"
      numbering_definition: 1  # Reference to numbering.xml
      levels:
        - level: 0
          format: bullet
          text: "•"
          alignment: left
          indent_left: 360
        - level: 1
          format: bullet
          text: "◦"
          indent_left: 720
        - level: 2
          format: bullet
          text: "▪"
          indent_left: 1080

    numbered_list:
      name: "Numbered List"
      numbering_definition: 2
      levels:
        - level: 0
          format: decimal
          text: "%1."
          alignment: left
          indent_left: 360
        - level: 1
          format: lowerLetter
          text: "%2."
          indent_left: 720
        - level: 2
          format: lowerRoman
          text: "%3."
          indent_left: 1080
```

### Part 2: Style DSL (Ruby Interface)

```ruby
module Uniword
  module Styles
    # Style Library - loads external style definitions
    #
    # Responsibility: Load and manage style definitions
    # Single Responsibility: Style configuration management only
    #
    # External config: config/styles/*.yml
    class StyleLibrary
      def self.load(library_name)
        config_path = File.join('config', 'styles', "#{library_name}.yml")
        config = Configuration::ConfigurationLoader.load_file(config_path)
        new(config[:style_library])
      end

      def initialize(config)
        @name = config[:name]
        @paragraph_styles = load_paragraph_styles(config[:paragraph_styles])
        @character_styles = load_character_styles(config[:character_styles])
        @list_styles = load_list_styles(config[:list_styles])
      end

      # Get paragraph style definition
      def paragraph_style(style_name)
        @paragraph_styles[style_name.to_sym] ||
          raise("Paragraph style not found: #{style_name}")
      end

      # Get character style definition
      def character_style(style_name)
        @character_styles[style_name.to_sym] ||
          raise("Character style not found: #{style_name}")
      end

      # Get list style definition
      def list_style(style_name)
        @list_styles[style_name.to_sym] ||
          raise("List style not found: #{style_name}")
      end

      private

      def load_paragraph_styles(config)
        config.transform_keys(&:to_sym).transform_values do |style_config|
          ParagraphStyleDefinition.new(style_config)
        end
      end
    end

    # Style Builder DSL - fluent interface for applying styles
    #
    # Responsibility: Provide DSL for style application
    # Single Responsibility: Style application only
    class StyleBuilder
      def initialize(document, style_library:)
        @document = document
        @library = StyleLibrary.load(style_library)
      end

      # Build document using DSL
      def build(&block)
        instance_eval(&block)
        @document
      end

      # Add styled paragraph
      #
      # Usage:
      #   paragraph :title, "Document Title"
      #   paragraph :heading_1, "Chapter 1"
      #   paragraph :body_text, "Content here..."
      def paragraph(style_name, text = nil, &block)
        style_def = @library.paragraph_style(style_name)

        para = Paragraph.new
        apply_paragraph_style(para, style_def)

        if text
          para.add_text(text)
        elsif block_given?
          # Block for complex content
          yield(para)
        end

        @document.add_paragraph(para)
        para
      end

      # Add styled run within current paragraph context
      #
      # Usage within paragraph block:
      #   text "Normal text "
      #   text "bold text", :strong
      #   text "code", :code
      def text(content, style_name = nil)
        run = Run.new(text: content)

        if style_name
          style_def = @library.character_style(style_name)
          apply_run_style(run, style_def)
        end

        # Add to last paragraph
        @document.paragraphs.last.add_run(run)
      end

      # Add styled list
      #
      # Usage:
      #   list :bullet_list do
      #     item "First item"
      #     item "Second item"
      #     item "Third item", level: 1  # Nested
      #   end
      def list(style_name, &block)
        style_def = @library.list_style(style_name)
        list_context = ListContext.new(@document, style_def)
        list_context.instance_eval(&block)
      end

      # Add table with styling
      #
      # Usage:
      #   table do
      #     row header: true do
      #       cell "Column 1"
      #       cell "Column 2"
      #     end
      #     row do
      #       cell "Data 1"
      #       cell "Data 2"
      #     end
      #   end
      def table(&block)
        tbl = Table.new
        table_context = TableContext.new(tbl, @library)
        table_context.instance_eval(&block)
        @document.add_table(tbl)
        tbl
      end

      private

      def apply_paragraph_style(para, style_def)
        # Apply paragraph properties
        if style_def.properties
          para.properties = Properties::ParagraphProperties.new(
            **style_def.properties
          )
        end

        # Apply default run properties
        if style_def.run_properties
          # These will be inherited by runs
          para.instance_variable_set(:@default_run_properties, style_def.run_properties)
        end
      end

      def apply_run_style(run, style_def)
        run.properties = Properties::RunProperties.new(
          **style_def.run_properties
        )
      end
    end

    # Paragraph Style Definition
    class ParagraphStyleDefinition
      attr_reader :name, :base_style, :next_style, :properties, :run_properties

      def initialize(config)
        @name = config[:name]
        @base_style = config[:base_style]
        @next_style = config[:next_style]
        @properties = config[:properties]
        @run_properties = config[:run_properties]
      end
    end

    # List Context - DSL for list building
    class ListContext
      def initialize(document, list_style_def)
        @document = document
        @style_def = list_style_def
        @current_level = 0
      end

      # Add list item
      def item(text, level: nil)
        item_level = level || @current_level
        level_def = @style_def.levels[item_level]

        para = Paragraph.new
        para.add_text(text)
        para.set_numbering(
          @style_def.numbering_definition,
          item_level
        )

        # Apply level-specific formatting if defined
        if level_def[:properties]
          para.properties = Properties::ParagraphProperties.new(
            **level_def[:properties]
          )
        end

        @document.add_paragraph(para)
      end
    end

    # Table Context - DSL for table building
    class TableContext
      def initialize(table, library)
        @table = table
        @library = library
        @current_row = nil
      end

      # Add table row
      def row(header: false, &block)
        @current_row = TableRow.new
        @current_row.header = header

        instance_eval(&block) if block_given?

        @table.add_row(@current_row)
      end

      # Add table cell
      def cell(text, style: nil, colspan: 1, rowspan: 1)
        cell = TableCell.new
        cell.colspan = colspan if colspan > 1
        cell.rowspan = rowspan if rowspan > 1

        # Add text as paragraph
        para = Paragraph.new
        para.add_text(text)

        # Apply style if specified
        if style
          style_def = @library.paragraph_style(style)
          apply_paragraph_style(para, style_def)
        end

        cell.add_paragraph(para)
        @current_row.add_cell(cell)
      end
    end
  end
end
```

## Usage Examples

### Example 1: Using Style Library

```ruby
# Load style library
builder = Uniword::Styles::StyleBuilder.new(
  Document.new,
  style_library: 'iso_standard'
)

# Build document with DSL
doc = builder.build do
  # Title page
  paragraph :title, "ISO 8601-2:2026"
  paragraph :subtitle, "Date and time — Representations for information interchange"

  # Chapter with heading
  paragraph :heading_1, "1. Scope"
  paragraph :body_text, "This document specifies..."

  # Subheading
  paragraph :heading_2, "1.1 General"
  paragraph :body_text, "The representations are..."

  # List
  list :bullet_list do
    item "First point"
    item "Second point"
    item "Nested point", level: 1
  end

  # Quote
  paragraph :quote, "Quotation from standard"

  # Table
  table do
    row header: true do
      cell "Format"
      cell "Example"
    end
    row do
      cell "Basic"
      cell "2023-10-15"
    end
  end
end

doc.save('styled_document.docx')
```

### Example 2: Inline Text Styling

```ruby
# Complex paragraph with mixed styles
builder.build do
  paragraph :body_text do |para|
    para.add_text("Normal text, ")
    para.add_text("emphasized text", :emphasis)
    para.add_text(", ")
    para.add_text("strong text", :strong)
    para.add_text(", and ")
    para.add_text("code example", :code)
    para.add_text(".")
  end
end
```

### Example 3: Custom Style Application

```ruby
# Define custom style on-the-fly
builder.paragraph :body_text do |para|
  para.add_text("Custom styled text")

  # Override properties
  para.alignment = 'center'
  para.spacing_before = 200

  # Apply to specific run
  para.runs.first.tap do |run|
    run.color = 'FF0000'
    run.font_size = 14
  end
end
```

## File Structure

```
lib/uniword/styles/
  style_library.rb                  # NEW - Load external styles
  style_builder.rb                  # NEW - DSL interface
  style_definition.rb               # NEW - Base style definition
  paragraph_style_definition.rb     # NEW - Paragraph style
  character_style_definition.rb     # NEW - Character style
  list_style_definition.rb          # NEW - List style
  table_style_definition.rb         # NEW - Table style

  dsl/
    list_context.rb                 # NEW - List DSL context
    table_context.rb                # NEW - Table DSL context
    paragraph_context.rb            # NEW - Paragraph DSL context

config/styles/
  iso_standard.yml                  # NEW - ISO style library
  technical_report.yml              # NEW - Report styles
  legal_document.yml                # NEW - Legal styles
  minimal.yml                       # NEW - Minimal styles

spec/uniword/styles/
  style_library_spec.rb             # NEW
  style_builder_spec.rb             # NEW
  style_definition_spec.rb          # NEW

  dsl/
    list_context_spec.rb            # NEW
    table_context_spec.rb           # NEW
```

## Advanced Features

### Style Inheritance

```yaml
# Styles can inherit from base styles
heading_2:
  name: "Heading 2"
  base_style: heading_1      # Inherit from Heading 1
  # Only specify differences
  properties:
    outline_level: 1         # Override
  run_properties:
    size: 24                 # Override (smaller than H1)
```

### Semantic Styles

```yaml
# Define semantic meaning, not just formatting
semantic_styles:
  term:
    name: "Term"
    semantic: definition_term
    run_properties:
      bold: true

  definition:
    name: "Definition"
    semantic: definition_text
    properties:
      indent_left: 360

  example:
    name: "Example"
    semantic: code_example
    run_properties:
      font: "Consolas"
```

### Conditional Styles

```yaml
# Styles that apply conditionally
conditional_styles:
  first_paragraph:
    name: "First Paragraph"
    condition:
      type: position
      value: first
    properties:
      spacing_before: 0  # No space before first para

  last_paragraph:
    name: "Last Paragraph"
    condition:
      type: position
      value: last
    properties:
      spacing_after: 0
```

## Integration with Document

```ruby
# Document class enhancement
class Document
  # Apply style library to document
  def apply_style_library(library_name)
    library = Styles::StyleLibrary.load(library_name)

    # Import all styles into document
    library.paragraph_styles.each do |name, definition|
      style = create_paragraph_style(name, definition)
      styles_configuration.add_style(style)
    end

    # Import character styles
    library.character_styles.each do |name, definition|
      style = create_character_style(name, definition)
      styles_configuration.add_style(style)
    end
  end

  # Build content with style DSL
  def styled_content(library_name, &block)
    apply_style_library(library_name) unless has_library?(library_name)

    builder = Styles::StyleBuilder.new(self, style_library: library_name)
    builder.build(&block)
  end
end
```

## Usage in Practice

```ruby
# Create ISO standard document with styling
doc = Document.new

doc.styled_content('iso_standard') do
  # Title page
  paragraph :title, "ISO 8601-2:2026"
  paragraph :subtitle, "Date and time"

  # Foreword
  paragraph :heading_1, "Foreword"
  paragraph :body_text, "ISO (the International Organization..."

  # Scope
  paragraph :heading_1, "1 Scope"
  paragraph :body_text, "This document specifies..."

  # Normative references
  paragraph :heading_1, "2 Normative references"
  list :numbered_list do
    item "ISO 8601-1:2019, Date and time..."
    item "ISO/IEC 27001:2013, Information technology..."
  end

  # Terms and definitions
  paragraph :heading_1, "3 Terms and definitions"

  paragraph :body_text do |para|
    para.add_text("The term ", :normal)
    para.add_text("representation", :term)
    para.add_text(" means:", :normal)
  end

  paragraph :definition, "A specific format for expressing information."
end

doc.save('iso_standard.docx')
```

## Success Criteria

- [ ] StyleLibrary loads external YAML
- [ ] StyleBuilder DSL implemented
- [ ] 4 style types supported (paragraph, character, list, table)
- [ ] Style inheritance working
- [ ] External style libraries (4+ provided)
- [ ] Fluent DSL interface
- [ ] Each class has spec file
- [ ] 100% test coverage

## Timeline

**Total**: 2 weeks
- Week 1: StyleLibrary, StyleBuilder core, 2 style types
- Week 2: Remaining types, DSL contexts, style libraries

## Architecture Benefits

✅ **External Configuration**: All styles in YAML
✅ **MECE**: Each style type distinct
✅ **Separation**: Definition ≠ Application ≠ Storage
✅ **Open/Closed**: Add styles via YAML
✅ **Single Responsibility**: Builder applies, Library loads, Definition holds
✅ **Reusability**: Style libraries shared across documents
✅ **DRY**: Define once, use everywhere

This provides elegant, maintainable document styling with external configuration.
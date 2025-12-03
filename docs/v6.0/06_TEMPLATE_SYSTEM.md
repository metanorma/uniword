# Feature 6: Template System - Word-Designed Templates with Uniword Syntax

## Objective

**Goal**: Allow users to design templates in Microsoft Word, embed Uniword syntax in comments, and programmatically fill them using Ruby data structures or Uniword classes.

**User Problem**:
- Template designers know Word, not programming
- Programmatic template creation is complex and error-prone
- Visual design in Word, logic in Ruby - best of both worlds
- Need mail-merge-like functionality but for complex documents (standards, reports)

**Need**: "Uniword template language" that Word users can embed in documents, developers can fill with data

## Core Concept

**Designer Workflow** (in Microsoft Word):
1. Create template document visually in Word
2. Insert Uniword syntax as **comments** in document
3. Mark repeating sections, conditional content, variables
4. Save as `.docx` template file

**Developer Workflow** (in Ruby):
```ruby
template = Uniword::Template.load('iso_standard_template.docx')

data = {
  title: "ISO 8601-2:2026",
  clauses: [
    { number: "5.1", title: "Basic concepts", content: "..." },
    { number: "5.2", title: "Representations", content: "..." }
  ],
  references: Reference.all  # ActiveRecord or custom objects
}

document = template.render(data)
document.save('generated_standard.docx')
```

## Uniword Template Syntax

### Embedded in Word Comments

**Syntax Design** (in Word comment bubbles):

```
{{variable_name}}                    # Simple variable
{{object.property}}                  # Nested property
{{@each clauses}}                    # Start repeating section
{{clause.number}} {{clause.title}}  # Variables in loop
{{@end}}                             # End repeating section
{{@if condition}}                    # Conditional content
{{@unless condition}}                # Negative conditional
```

**Example Template in Word**:

```
Document text with comment: {{title}}

Paragraph with comment: {{subtitle}}

[Heading 1 style] "Chapter {{chapter.number}}"
[Comment on heading]: {{@each chapters}}

[Body text] "{{chapter.content}}"

[Comment after content]: {{@end}}

[Table row with comment]: {{@each references}}
[Cell 1]: {{reference.author}}
[Cell 2]: {{reference.title}}
[Comment on row]: {{@end}}
```

## Architecture Design

### Principle: Separation of Template Definition and Data

```ruby
module Uniword
  module Template
    # Template Engine - render Word templates with data
    #
    # Responsibility: Process templates and fill with data
    # Single Responsibility: Template rendering only
    #
    # Architecture:
    # - Template: Template document with markers
    # - TemplateParser: Extract markers from comments
    # - TemplateRenderer: Fill template with data
    # - TemplateContext: Data context during rendering
    # - VariableResolver: Resolve variable expressions
    class Template
      attr_reader :document, :markers

      # Load template from .docx file
      def self.load(template_path)
        doc = Document.open(template_path)
        new(doc)
      end

      def initialize(document)
        @document = document
        @markers = extract_markers
      end

      # Render template with data
      #
      # @param data [Hash, Object] Data to fill template
      # @param context [Hash] Additional context
      # @return [Document] Rendered document
      def render(data, context: {})
        renderer = TemplateRenderer.new(self, data, context)
        renderer.render
      end

      # Preview template structure (for debugging)
      def preview
        {
          markers: @markers.count,
          variables: @markers.select { |m| m.type == :variable }.map(&:name),
          loops: @markers.select { |m| m.type == :loop }.map(&:collection),
          conditionals: @markers.select { |m| m.type == :conditional }.count
        }
      end

      private

      # Extract markers from document comments
      def extract_markers
        parser = TemplateParser.new(@document)
        parser.parse
      end
    end

    # Template Parser - extract markers from comments
    #
    # Responsibility: Parse template syntax from Word comments
    # Single Responsibility: Marker extraction only
    class TemplateParser
      def initialize(document)
        @document = document
        @markers = []
      end

      # Parse all markers from document
      def parse
        # Iterate through document elements
        parse_paragraphs(@document.paragraphs)
        parse_tables(@document.tables)

        # Sort markers by document order
        @markers.sort_by(&:position)
      end

      private

      def parse_paragraphs(paragraphs)
        paragraphs.each_with_index do |para, index|
          # Check paragraph's own comments
          para.comments.each do |comment|
            marker = parse_comment_text(comment.content, para, index)
            @markers << marker if marker
          end

          # Check run comments
          para.runs.each do |run|
            if run.respond_to?(:comments)
              run.comments.each do |comment|
                marker = parse_comment_text(comment.content, run, index)
                @markers << marker if marker
              end
            end
          end
        end
      end

      def parse_comment_text(text, element, position)
        # Parse Uniword syntax
        case text.strip
        when /^\{\{@each\s+(\w+)\}\}$/
          # Loop start: {{@each collection_name}}
          TemplateMarker.new(
            type: :loop_start,
            collection: $1,
            element: element,
            position: position
          )

        when /^\{\{@end\}\}$/
          # Loop end: {{@end}}
          TemplateMarker.new(
            type: :loop_end,
            element: element,
            position: position
          )

        when /^\{\{@if\s+(.+)\}\}$/
          # Conditional: {{@if condition}}
          TemplateMarker.new(
            type: :conditional_start,
            condition: $1,
            element: element,
            position: position
          )

        when /^\{\{([^@].+)\}\}$/
          # Variable: {{variable.name}}
          TemplateMarker.new(
            type: :variable,
            expression: $1,
            element: element,
            position: position
          )

        else
          nil  # Not a template marker
        end
      end
    end

    # Template Marker - represents one template instruction
    class TemplateMarker
      attr_reader :type, :collection, :condition, :expression,
                  :element, :position

      def initialize(attributes)
        @type = attributes[:type]
        @collection = attributes[:collection]
        @condition = attributes[:condition]
        @expression = attributes[:expression]
        @element = attributes[:element]
        @position = attributes[:position]
      end
    end

    # Template Renderer - fill template with data
    #
    # Responsibility: Render template using markers and data
    # Single Responsibility: Template rendering only
    class TemplateRenderer
      def initialize(template, data, context)
        @template = template
        @data = data
        @context = context
        @resolver = VariableResolver.new(data, context)
      end

      # Render template
      def render
        # Clone template document
        output = @template.document.dup

        # Process markers in reverse order (so indices don't shift)
        markers = @template.markers.reverse

        markers.each do |marker|
          process_marker(marker, output)
        end

        # Remove all comments (they contained template syntax)
        remove_template_comments(output)

        output
      end

      private

      def process_marker(marker, document)
        case marker.type
        when :variable
          # Replace with resolved value
          value = @resolver.resolve(marker.expression)
          replace_element_content(marker.element, value)

        when :loop_start
          # Find matching loop_end
          loop_end = find_matching_loop_end(marker)

          # Get elements between start and end
          template_elements = extract_loop_template(marker, loop_end)

          # Get collection data
          collection = @resolver.resolve(marker.collection)

          # Remove original template elements
          remove_elements(template_elements)

          # Render loop
          render_loop(template_elements, collection, marker.position)

        when :conditional_start
          # Evaluate condition
          condition_result = @resolver.evaluate(marker.condition)

          # Find elements in conditional block
          conditional_elements = extract_conditional_elements(marker)

          # Remove elements if condition false
          unless condition_result
            remove_elements(conditional_elements)
          end
        end
      end

      def replace_element_content(element, value)
        case element
        when Paragraph
          # Replace paragraph text
          element.runs.clear
          element.add_text(value.to_s)
        when Run
          # Replace run text
          element.text = value.to_s
        when TableCell
          # Replace cell content
          element.paragraphs.first.text = value.to_s if element.paragraphs.any?
        end
      end

      def render_loop(template_elements, collection, insert_position)
        # For each item in collection, clone template and fill
        Array(collection).each do |item|
          # Create scoped context for this iteration
          scoped_resolver = VariableResolver.new(item, @context)

          # Clone and fill template elements
          template_elements.each do |template_element|
            filled_element = clone_and_fill(template_element, scoped_resolver)
            insert_element_at(filled_element, insert_position)
          end
        end
      end

      def clone_and_fill(element, resolver)
        # Deep clone element
        cloned = element.dup

        # Find variables in cloned element
        find_variables_in_element(cloned).each do |var_expression|
          value = resolver.resolve(var_expression)
          replace_variable_in_element(cloned, var_expression, value)
        end

        cloned
      end
    end

    # Variable Resolver - resolve variable expressions
    #
    # Responsibility: Resolve variable expressions to values
    # Single Responsibility: Variable resolution only
    class VariableResolver
      def initialize(data, context = {})
        @data = data
        @context = context
      end

      # Resolve variable expression
      #
      # @param expression [String] Expression like "title" or "chapter.number"
      # @return [Object] Resolved value
      def resolve(expression)
        parts = expression.split('.')

        # Start with data or context
        value = @data.is_a?(Hash) ? @data[parts.first.to_sym] : @data

        # Navigate nested properties
        parts[1..].each do |part|
          if value.respond_to?(:[])
            value = value[part.to_sym] || value[part]
          elsif value.respond_to?(part.to_sym)
            value = value.send(part.to_sym)
          else
            return nil
          end
        end

        value
      end

      # Evaluate conditional expression
      #
      # @param condition [String] Condition like "has_annexes" or "chapter_count > 5"
      # @return [Boolean] Evaluation result
      def evaluate(condition)
        # Simple boolean check
        if condition.match?(/^\w+$/)
          # Simple variable existence/truthiness check
          value = resolve(condition)
          !!value
        elsif condition.match?(/(.+)\s*(==|!=|>|<|>=|<=)\s*(.+)/)
          # Comparison
          left = resolve($1.strip)
          operator = $2
          right = $3.strip

          # Try to parse right as number
          right = right.to_i if right.match?(/^\d+$/)

          case operator
          when '==' then left == right
          when '!=' then left != right
          when '>' then left.to_i > right.to_i
          when '<' then left.to_i < right.to_i
          when '>=' then left.to_i >= right.to_i
          when '<=' then left.to_i <= right.to_i
          end
        else
          false
        end
      end
    end
  end
end
```

## File Structure

```
lib/uniword/template/
  template.rb                        # NEW - Main template class
  template_parser.rb                 # NEW - Parse markers from comments
  template_renderer.rb               # NEW - Render with data
  template_marker.rb                 # NEW - Marker representation
  template_context.rb                # NEW - Rendering context
  variable_resolver.rb               # NEW - Resolve variables

  helpers/
    loop_helper.rb                   # NEW - Loop rendering
    conditional_helper.rb            # NEW - Conditional rendering
    variable_helper.rb               # NEW - Variable substitution

spec/uniword/template/
  template_spec.rb                   # NEW
  template_parser_spec.rb            # NEW
  template_renderer_spec.rb          # NEW
  template_marker_spec.rb            # NEW
  variable_resolver_spec.rb          # NEW

spec/fixtures/templates/
  simple_template.docx               # NEW - Test template
  loop_template.docx                 # NEW - With loops
  conditional_template.docx          # NEW - With conditionals
  complex_template.docx              # NEW - Complete example
```

## Template Examples

### Example 1: Simple Variable Substitution

**Template (Word document with comments)**:
```
[Paragraph 1]: "Title: " [Comment: {{title}}]
[Paragraph 2]: "Author: " [Comment: {{author}}]
[Paragraph 3]: "Date: " [Comment: {{date}}]
```

**Ruby Code**:
```ruby
template = Uniword::Template.load('simple_template.docx')

data = {
  title: "My Document",
  author: "John Doe",
  date: Date.today.to_s
}

doc = template.render(data)
# Result: Title: My Document
#         Author: John Doe
#         Date: 2025-10-30
```

### Example 2: Repeating Sections (Clauses)

**Template**:
```
[Comment before clause]: {{@each clauses}}

[Heading 1]: "Clause " [Comment: {{clause.number}}]
[Heading 1 title]: [Comment: {{clause.title}}]

[Body paragraph]: [Comment: {{clause.content}}]

[Comment after clause]: {{@end}}
```

**Ruby Code**:
```ruby
data = {
  clauses: [
    { number: "5.1", title: "Scope", content: "This clause defines..." },
    { number: "5.2", title: "Requirements", content: "The following requirements..." },
    { number: "5.3", title: "Examples", content: "Example usage..." }
  ]
}

doc = template.render(data)

# Result: 3 clauses generated, each with heading and body
```

### Example 3: Complex Object Mapping

**Template for Bibliography**:
```
[Comment]: {{@each references}}

[Paragraph with style "Reference"]:
"[" [Comment: {{reference.id}}] "] "
[Bold run]: [Comment: {{reference.author}}]
", "
[Italic run]: [Comment: {{reference.title}}]
", "
[Normal run]: [Comment: {{reference.publisher}}]
", "
[Normal run]: [Comment: {{reference.year}}]

[Comment]: {{@end}}
```

**Ruby Code with Custom Classes**:
```ruby
# Custom bibliographic class
class BibEntry
  attr_reader :id, :author, :title, :publisher, :year

  def initialize(id, author, title, publisher, year)
    @id = id
    @author = author
    @title = title
    @publisher = publisher
    @year = year
  end
end

# Or use Uniword classes directly
class BibEntryBuilder
  def self.build(id, author, title, publisher, year)
    para = Uniword::Paragraph.new
    para.add_text("[#{id}] ")
    para.add_text(author, bold: true)
    para.add_text(", ")
    para.add_text(title, italic: true)
    para.add_text(", #{publisher}, #{year}")
    para
  end
end

# Data
references = [
  BibEntry.new("ISO8601", "ISO", "ISO 8601-1:2019", "ISO", "2019"),
  BibEntry.new("RFC3339", "IETF", "RFC 3339", "IETF", "2002")
]

# Render
doc = template.render(references: references)

# Alternative: Provide Uniword objects directly
doc = template.render_with_objects(
  references: references.map { |r| BibEntryBuilder.build(r.id, r.author, r.title, r.publisher, r.year) }
)
```

### Example 4: Conditional Content

**Template**:
```
[Comment]: {{@if has_annexes}}

[Heading 1]: "Annexes"

[Body]: "This standard includes normative annexes."

[Comment]: {{@end}}
```

**Ruby Code**:
```ruby
data_with_annexes = { has_annexes: true, annexes: [...] }
doc1 = template.render(data_with_annexes)
# Annexes section included

data_without = { has_annexes: false }
doc2 = template.render(data_without)
# Annexes section omitted
```

## Advanced Features

### Nested Loops

```
[Comment]: {{@each chapters}}

[Heading 1]: "Chapter " {{chapter.number}}

  [Comment]: {{@each chapter.sections}}

  [Heading 2]: "Section " {{section.number}}
  [Body]: {{section.content}}

  [Comment]: {{@end}}

[Comment]: {{@end}}
```

### Filters and Formatters

```
[Comment]: {{date | format: '%Y-%m-%d'}}
[Comment]: {{price | currency: 'USD'}}
[Comment]: {{text | upcase}}
[Comment]: {{name | titleize}}
```

**Implementation**:
```ruby
class VariableResolver
  # Resolve with filter
  def resolve_with_filter(expression)
    parts = expression.split('|').map(&:strip)
    value = resolve(parts.first)

    # Apply filters
    parts[1..].each do |filter_spec|
      filter_name, *args = filter_spec.split(':').map(&:strip)
      value = apply_filter(value, filter_name, args)
    end

    value
  end

  private

  def apply_filter(value, filter_name, args)
    case filter_name
    when 'format'
      value.strftime(args.first) rescue value
    when 'currency'
      "#{args.first} #{value}"
    when 'upcase'
      value.to_s.upcase
    when 'titleize'
      value.to_s.split.map(&:capitalize).join(' ')
    else
      value
    end
  end
end
```

### Helper Functions

```
[Comment]: {{@date_today}}
[Comment]: {{@page_count}}
[Comment]: {{@word_count}}
[Comment]: {{@toc 3}}  # TOC with depth 3
```

## Integration with Uniword

### Document Enhancement

```ruby
# Document class gets template support
class Document
  # Render this document as template
  def render_template(data, context: {})
    template = Template.new(self)
    template.render(data, context: context)
  end

  # Check if document is a template
  def template?
    comments_part.comments.any? { |c| c.content.match?(/^\{\{.+\}\}$/) }
  end

  # Preview template structure
  def template_preview
    Template.new(self).preview if template?
  end
end
```

### Usage Patterns

**Pattern 1: Load and Render**
```ruby
template = Uniword::Template.load('template.docx')
doc = template.render(data)
```

**Pattern 2: Document as Template**
```ruby
doc = Uniword::Document.open('template.docx')
rendered = doc.render_template(data)
```

**Pattern 3: Programmatic Template Creation**
```ruby
# Create template programmatically (for testing)
template_doc = Uniword::Document.new

# Add paragraph with template marker
para = Uniword::Paragraph.new
para.add_text("Title will appear here")
comment = Uniword::Comment.new(
  content: "{{title}}",
  author: "Template"
)
para.add_comment(comment)
template_doc.add_paragraph(para)

# Use as template
template = Uniword::Template.new(template_doc)
rendered = template.render(title: "My Title")
```

## Error Handling

```ruby
# Template with validation
class Template
  def validate
    errors = []

    # Check for unclosed loops
    loop_depth = 0
    @markers.each do |marker|
      loop_depth += 1 if marker.type == :loop_start
      loop_depth -= 1 if marker.type == :loop_end

      if loop_depth < 0
        errors << "Unmatched {{@end}} without {{@each}}"
      end
    end

    if loop_depth > 0
      errors << "Unclosed loop: missing {{@end}}"
    end

    # Check for undefined variables (warnings)
    @markers.select { |m| m.type == :variable }.each do |marker|
      # Could validate against expected data schema
    end

    errors
  end

  def valid?
    validate.empty?
  end
end

# Usage with validation
template = Uniword::Template.load('template.docx')

unless template.valid?
  puts "Template has errors:"
  template.validate.each { |error| puts "  - #{error}" }
  exit 1
end

doc = template.render(data)
```

## File Structure for v6.0 Implementation

```
lib/uniword/template/
  template.rb                        # NEW - Main template class
  template_parser.rb                 # NEW - Extract markers
  template_renderer.rb               # NEW - Render with data
  template_marker.rb                 # NEW - Marker representation
  template_context.rb                # NEW - Rendering context
  variable_resolver.rb               # NEW - Resolve variables
  template_validator.rb              # NEW - Validate template structure

  helpers/
    loop_helper.rb                   # NEW - Loop processing
    conditional_helper.rb            # NEW - Conditional processing
    variable_helper.rb               # NEW - Variable substitution
    filter_helper.rb                 # NEW - Value filters

spec/uniword/template/
  template_spec.rb                   # NEW - 50+ tests
  template_parser_spec.rb            # NEW
  template_renderer_spec.rb          # NEW
  variable_resolver_spec.rb          # NEW

  integration/
    simple_template_spec.rb          # NEW
    loop_template_spec.rb            # NEW
    conditional_template_spec.rb     # NEW
    complex_template_spec.rb         # NEW

spec/fixtures/templates/
  simple.docx                        # NEW
  with_loops.docx                    # NEW
  with_conditionals.docx             # NEW
  iso_standard_template.docx         # NEW
```

## Success Criteria

- [ ] Template class loads .docx templates
- [ ] TemplateParser extracts markers from comments
- [ ] TemplateRenderer fills with data
- [ ] Variable resolution works (nested properties)
- [ ] Loops render correctly ({{@each}})
- [ ] Conditionals work ({{@if}}/{{@unless}})
- [ ] Filter support (| format:, | upcase, etc.)
- [ ] Template validation
- [ ] Each class has comprehensive spec file
- [ ] Integration tests with real templates
- [ ] 100% test coverage

## Timeline

**Total**: 3 weeks
- Week 1: Core (Template, Parser, Marker, Resolver)
- Week 2: Renderer, Loops, Conditionals
- Week 3: Filters, Validation, Integration tests

## Architecture Benefits

✅ **Separation**: Template design (Word) ≠ Logic (Ruby)
✅ **MECE**: Each marker type handled distinctly
✅ **Single Responsibility**: Parser parses, Renderer renders, Resolver resolves
✅ **Open/Closed**: Extend with new marker types via parser
✅ **External Content**: Templates are .docx files, not code
✅ **Type Safe**: Works with hashes or custom classes

This enables powerful template-based document generation where non-programmers can design templates in Word and developers fill them programmatically - the best of both worlds.
#!/usr/bin/env ruby
# frozen_string_literal: true

# Template System Example
#
# Demonstrates how to use Uniword's template system to create
# documents from Word templates with embedded template syntax.

require_relative '../lib/uniword'

puts "Uniword Template System Example"
puts "=" * 50

# Example 1: Simple Variable Substitution
puts "\n1. Simple Variable Substitution"
puts "-" * 50

# Create a simple template programmatically
template_doc = Uniword::Document.new

# Add paragraph with template marker in comment
para = Uniword::Paragraph.new
para.add_text("Title: ")
# In a real Word document, you would add this as a comment:
# Comment: {{title}}
template_doc.add_paragraph(para)

# Add another paragraph
para2 = Uniword::Paragraph.new
para2.add_text("Author: ")
# Comment: {{author}}
template_doc.add_paragraph(para2)

puts "Template created with variable markers for 'title' and 'author'"

# Render with data
data = {
  title: "Uniword Template System Documentation",
  author: "Development Team"
}

# Note: Full rendering requires Word comments with template syntax
# This is a conceptual demonstration
puts "Data: #{data.inspect}"

# Example 2: Loop Processing
puts "\n2. Loop Processing (Conceptual)"
puts "-" * 50

data_with_loop = {
  document_title: "ISO 8601 Standard",
  clauses: [
    { number: "5.1", title: "Scope", content: "This clause defines the scope..." },
    { number: "5.2", title: "Normative references", content: "The following documents..." },
    { number: "5.3", title: "Terms and definitions", content: "For the purposes..." }
  ]
}

puts "Template would contain:"
puts "  {{document_title}}"
puts "  {{@each clauses}}"
puts "    Clause {{clause.number}}: {{clause.title}}"
puts "    {{clause.content}}"
puts "  {{@end}}"
puts ""
puts "Data: #{data_with_loop[:clauses].count} clauses"

# Example 3: Conditional Content
puts "\n3. Conditional Content (Conceptual)"
puts "-" * 50

data_with_conditional = {
  title: "Technical Report",
  has_annexes: true,
  annexes_count: 3
}

puts "Template would contain:"
puts "  {{title}}"
puts "  {{@if has_annexes}}"
puts "    This document includes {{annexes_count}} annexes."
puts "  {{@end}}"
puts ""
puts "Data: #{data_with_conditional.inspect}"

# Example 4: Real Template Usage (requires actual .docx template)
puts "\n4. Real Template Usage"
puts "-" * 50
puts "To use templates in production:"
puts ""
puts "# 1. Create template in Microsoft Word with comments:"
puts "#    - Add {{variable_name}} in comments for variables"
puts "#    - Add {{@each collection}} for loops"
puts "#    - Add {{@if condition}} for conditionals"
puts ""
puts "# 2. Load and render template:"
puts "template = Uniword::Template::Template.load('template.docx')"
puts "data = { title: 'My Document', items: [...] }"
puts "document = template.render(data)"
puts "document.save('output.docx')"
puts ""
puts "# 3. Or use Document#render_template:"
puts "doc = Uniword::Document.open('template.docx')"
puts "filled = doc.render_template(data)"
puts "filled.save('output.docx')"

# Example 5: Template Validation
puts "\n5. Template Validation"
puts "-" * 50
puts "Before rendering, validate template structure:"
puts ""
puts "template = Uniword::Template::Template.load('template.docx')"
puts "if template.valid?"
puts "  puts 'Template is valid'"
puts "  document = template.render(data)"
puts "else"
puts "  puts 'Template errors:'"
puts "  template.validate.each { |error| puts \"  - \#{error}\" }"
puts "end"

# Example 6: Template Preview
puts "\n6. Template Preview"
puts "-" * 50
puts "Inspect template structure:"
puts ""
puts "preview = template.preview"
puts "puts \"Markers: \#{preview[:markers]}\""
puts "puts \"Variables: \#{preview[:variables].join(', ')}\""
puts "puts \"Loops: \#{preview[:loops].count}\""
puts "puts \"Conditionals: \#{preview[:conditionals].count}\""

puts "\n" + "=" * 50
puts "Template System Example Complete"
puts "See docs/v6.0/06_TEMPLATE_SYSTEM.md for full documentation"
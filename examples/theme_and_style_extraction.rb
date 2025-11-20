#!/usr/bin/env ruby
# frozen_string_literal: true

# Example: Theme and Style Extraction and Reuse
#
# This example demonstrates the new v1.1 features for extracting themes
# and styles from existing documents and reusing them in new documents.

require 'uniword'

puts "=== Theme and Style Extraction Examples ===\n\n"

# Example 1: Create a custom theme programmatically
puts "1. Creating a custom theme programmatically..."
doc = Uniword::Document.new

# Define a corporate theme
theme = Uniword::Theme.new(name: 'Corporate Blue')
theme.color_scheme.colors[:accent1] = '0066CC'  # Corporate blue
theme.color_scheme.colors[:accent2] = 'FF6600'  # Corporate orange
theme.font_scheme.major_font = 'Helvetica'
theme.font_scheme.minor_font = 'Arial'

doc.theme = theme
puts "   Created theme: #{doc.theme.name}"
puts "   Primary color: ##{doc.theme.color(:accent1)}"
puts "   Major font: #{doc.theme.major_font}\n\n"

# Example 2: Use theme colors in custom styles
puts "2. Creating styles using theme colors..."
doc.styles_configuration.create_paragraph_style(
  'CorporateHeading',
  'Corporate Heading',
  run_properties: Uniword::Properties::RunProperties.new(
    color: theme.color(:accent1),  # Use theme color
    font: theme.major_font,         # Use theme font
    bold: true,
    size: 32
  )
)

heading = Uniword::Paragraph.new(
  properties: Uniword::Properties::ParagraphProperties.new(style: 'CorporateHeading')
)
heading.add_text('Welcome to Our Company')
doc.add_element(heading)

body_para = Uniword::Paragraph.new
body_para.add_text('This document uses our corporate theme and styles.')
doc.add_element(body_para)

output_path = 'output/corporate_theme.docx'
doc.save(output_path)
puts "   Saved document with custom theme to: #{output_path}\n\n"

# Example 3: Extract theme from existing document
puts "3. Extracting theme from existing document..."
template = Uniword::Document.open(output_path)
extracted_theme = template.theme

puts "   Extracted theme: #{extracted_theme.name}"
puts "   Theme has #{extracted_theme.color_scheme.colors.count} colors"
puts "   Major font: #{extracted_theme.major_font}\n\n"

# Example 4: Apply theme to new document
puts "4. Applying extracted theme to new document..."
new_doc = Uniword::Document.new
new_doc.apply_theme_from(output_path)

para = Uniword::Paragraph.new
para.add_text('This document inherited the corporate theme')
new_doc.add_element(para)

new_output = 'output/inherited_theme.docx'
new_doc.save(new_output)
puts "   Saved new document with inherited theme to: #{new_output}\n\n"

# Example 5: Extract and reuse styles
puts "5. Extracting and reusing styles..."
source_doc = Uniword::Document.open(output_path)
custom_style = source_doc.styles_configuration.find_by_id('CorporateHeading')

if custom_style
  puts "   Found style: #{custom_style.name}"
  puts "   Style color: ##{custom_style.run_properties&.color}"
end

# Apply to new document
styled_doc = Uniword::Document.new
styled_doc.apply_styles_from(output_path, conflict_resolution: :keep_existing)

styled_heading = Uniword::Paragraph.new(
  properties: Uniword::Properties::ParagraphProperties.new(style: 'CorporateHeading')
)
styled_heading.add_text('Using Imported Style')
styled_doc.add_element(styled_heading)

styled_output = 'output/imported_styles.docx'
styled_doc.save(styled_output)
puts "   Saved document with imported styles to: #{styled_output}\n\n"

# Example 6: Apply complete template
puts "6. Applying complete template (theme + styles)..."
final_doc = Uniword::Document.new
final_doc.apply_template(output_path)

template_heading = Uniword::Paragraph.new(
  properties: Uniword::Properties::ParagraphProperties.new(style: 'CorporateHeading')
)
template_heading.add_text('Document from Template')
final_doc.add_element(template_heading)

content = Uniword::Paragraph.new
content.add_text('This document has both the theme and all styles from the template.')
final_doc.add_element(content)

final_output = 'output/from_template.docx'
final_doc.save(final_output)
puts "   Saved templated document to: #{final_output}\n\n"

# Example 7: Style conflict resolution
puts "7. Demonstrating style conflict resolution..."

# Create document with existing style
conflict_doc = Uniword::Document.new
conflict_doc.styles_configuration.create_paragraph_style(
  'CustomStyle',
  'Original Style'
)

# Import with different conflict resolutions
puts "   - keep_existing: Keeps original style"
test_doc1 = Uniword::Document.new
test_doc1.styles_configuration.create_paragraph_style('CustomStyle', 'Original')
test_doc1.apply_styles_from(output_path, conflict_resolution: :keep_existing)

puts "   - replace: Replaces with imported style"
test_doc2 = Uniword::Document.new
test_doc2.styles_configuration.create_paragraph_style('CustomStyle', 'Original')
test_doc2.apply_styles_from(output_path, conflict_resolution: :replace)

puts "   - rename: Keeps both, renames imported as 'style_imported'"
test_doc3 = Uniword::Document.new
test_doc3.styles_configuration.create_paragraph_style('CustomStyle', 'Original')
test_doc3.apply_styles_from(output_path, conflict_resolution: :rename)

puts "\n=== Examples Complete ===\n"
puts "All example files saved to output/ directory"
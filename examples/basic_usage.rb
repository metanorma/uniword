#!/usr/bin/env ruby
# frozen_string_literal: true

# Basic usage example for Uniword
# Demonstrates creating a simple document with text formatting

require 'bundler/setup'
require 'uniword'

puts 'Creating a basic document...'

# Create a new document
doc = Uniword::Document.new

# Add a title
title = Uniword::Paragraph.new
title.add_text('My First Document', bold: true, size: 48)
title.set_style('Heading1').align('center')
doc.add_element(title)

# Add a subtitle
subtitle = Uniword::Paragraph.new
subtitle.add_text('A demonstration of Uniword capabilities', italic: true, size: 24)
subtitle.align('center')
doc.add_element(subtitle)

# Add a blank line
blank = Uniword::Paragraph.new
blank.add_text('')
doc.add_element(blank)

# Add normal paragraph with mixed formatting
para = Uniword::Paragraph.new
para.add_text('This is a paragraph with ')
para.add_text('bold', bold: true)
para.add_text(' and ')
para.add_text('italic', italic: true)
para.add_text(' text. You can also use ')
para.add_text('different colors', color: '0000FF')
para.add_text(' and ')
para.add_text('different fonts', font: 'Courier New')
para.add_text('.')
doc.add_element(para)

# Add another paragraph using fluent interface
para2 = Uniword::Paragraph.new
                          .add_text('This paragraph demonstrates the fluent interface.')
                          .align('justify')
doc.add_element(para2)

# Save as DOCX
output_dir = File.join(__dir__, 'output')
FileUtils.mkdir_p(output_dir)

docx_path = File.join(output_dir, 'basic_usage.docx')
doc.save(docx_path)
puts "✓ Created #{docx_path}"

# Also demonstrate the Builder pattern
puts "\nUsing Builder pattern..."
doc2 = Uniword::Builder.new
                       .add_heading('Document Created with Builder', level: 1)
                       .add_blank_line
                       .add_paragraph('The builder provides a convenient fluent interface.')
                       .add_paragraph('You can chain multiple operations together.', bold: true)
                       .build

builder_path = File.join(output_dir, 'basic_usage_builder.docx')
doc2.save(builder_path)
puts "✓ Created #{builder_path}"

puts "\nBasic usage example complete!"
puts 'Check the examples/output directory for the generated files.'

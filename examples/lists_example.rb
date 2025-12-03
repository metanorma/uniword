#!/usr/bin/env ruby
# frozen_string_literal: true

# Lists example for Uniword
# Demonstrates creating numbered and bulleted lists

require 'bundler/setup'
require 'uniword'

puts 'Creating a document with lists...'

doc = Uniword::Builder.new
                      .add_heading('Lists Example', level: 1)
                      .add_paragraph('This document demonstrates numbered and bulleted lists.')
                      .add_blank_line
                      .build

# Add a heading for numbered list
heading = Uniword::Paragraph.new
heading.add_text('Numbered List', bold: true, size: 32)
heading.set_style('Heading2')
doc.add_element(heading)

# Create numbered list items
# Note: Numbering requires NumberingConfiguration setup
['First item', 'Second item', 'Third item'].each_with_index do |text, i|
  para = Uniword::Paragraph.new
  para.add_text("#{i + 1}. #{text}")
  # TODO: Use set_numbering(1, 0) when numbering is fully implemented
  doc.add_element(para)
end

# Add blank line
doc.add_element(Uniword::Paragraph.new.add_text(''))

# Add heading for bulleted list
heading2 = Uniword::Paragraph.new
heading2.add_text('Bulleted List', bold: true, size: 32)
heading2.set_style('Heading2')
doc.add_element(heading2)

# Create bulleted list items
%w[Apple Banana Cherry Date].each do |text|
  para = Uniword::Paragraph.new
  para.add_text("• #{text}")
  # TODO: Use set_numbering(2, 0) when bulleted lists are fully implemented
  doc.add_element(para)
end

# Add nested list example
doc.add_element(Uniword::Paragraph.new.add_text(''))

heading3 = Uniword::Paragraph.new
heading3.add_text('Nested List', bold: true, size: 32)
heading3.set_style('Heading2')
doc.add_element(heading3)

# Parent items
para1 = Uniword::Paragraph.new
para1.add_text('1. Parent Item 1')
doc.add_element(para1)

# Child items (indented)
para1a = Uniword::Paragraph.new
para1a.add_text('   a. Child Item 1a')
doc.add_element(para1a)

para1b = Uniword::Paragraph.new
para1b.add_text('   b. Child Item 1b')
doc.add_element(para1b)

# Another parent
para2 = Uniword::Paragraph.new
para2.add_text('2. Parent Item 2')
doc.add_element(para2)

# Save the document
output_dir = File.join(__dir__, 'output')
FileUtils.mkdir_p(output_dir)

output_path = File.join(output_dir, 'lists_example.docx')
doc.save(output_path)

puts "✓ Created #{output_path}"
puts "\nLists example complete!"
puts 'Note: Full numbering support will be enhanced in future versions.'

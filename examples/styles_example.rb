#!/usr/bin/env ruby
# frozen_string_literal: true

# Styles example for Uniword
# Demonstrates using built-in styles and custom formatting

require 'bundler/setup'
require 'uniword'

puts 'Creating a document with various styles...'

doc = Uniword::Builder.new
                      .add_heading('Styles Example', level: 1)
                      .add_paragraph('This document demonstrates various text styles and formatting.')
                      .add_blank_line
                      .build

# Different heading levels
(1..3).each do |level|
  heading = Uniword::Paragraph.new
  heading.add_text("Heading Level #{level}", bold: true, size: 48 - (level * 8))
  heading.set_style("Heading#{level}")
  doc.add_element(heading)

  para = Uniword::Paragraph.new
  para.add_text("This is sample text under heading level #{level}.")
  doc.add_element(para)

  doc.add_element(Uniword::Paragraph.new.add_text(''))
end

# Text formatting examples
heading = Uniword::Paragraph.new
heading.add_text('Text Formatting', bold: true, size: 32)
heading.set_style('Heading2')
doc.add_element(heading)

# Bold text
para = Uniword::Paragraph.new
para.add_text('Bold text example: ')
para.add_text('This text is bold', bold: true)
doc.add_element(para)

# Italic text
para = Uniword::Paragraph.new
para.add_text('Italic text example: ')
para.add_text('This text is italic', italic: true)
doc.add_element(para)

# Underline text
para = Uniword::Paragraph.new
para.add_text('Underline text example: ')
para.add_text('This text is underlined', underline: 'single')
doc.add_element(para)

# Combined formatting
para = Uniword::Paragraph.new
para.add_text('Combined formatting: ')
para.add_text('Bold and Italic', bold: true, italic: true)
doc.add_element(para)

# Different fonts
doc.add_element(Uniword::Paragraph.new.add_text(''))
heading = Uniword::Paragraph.new
heading.add_text('Font Examples', bold: true, size: 32)
heading.set_style('Heading2')
doc.add_element(heading)

fonts = ['Arial', 'Times New Roman', 'Courier New', 'Georgia']
fonts.each do |font|
  para = Uniword::Paragraph.new
  para.add_text("This text is in #{font}", font: font)
  doc.add_element(para)
end

# Different sizes
doc.add_element(Uniword::Paragraph.new.add_text(''))
heading = Uniword::Paragraph.new
heading.add_text('Size Examples', bold: true, size: 32)
heading.set_style('Heading2')
doc.add_element(heading)

[16, 24, 32, 40].each do |size|
  para = Uniword::Paragraph.new
  para.add_text("This text is #{size / 2} points", size: size)
  doc.add_element(para)
end

# Alignments
doc.add_element(Uniword::Paragraph.new.add_text(''))
heading = Uniword::Paragraph.new
heading.add_text('Alignment Examples', bold: true, size: 32)
heading.set_style('Heading2')
doc.add_element(heading)

%w[left center right justify].each do |alignment|
  para = Uniword::Paragraph.new
  para.add_text("This paragraph is aligned to the #{alignment}")
  para.align(alignment)
  doc.add_element(para)
end

# Save the document
output_dir = File.join(__dir__, 'output')
FileUtils.mkdir_p(output_dir)

output_path = File.join(output_dir, 'styles_example.docx')
doc.save(output_path)

puts "✓ Created #{output_path}"
puts "  Paragraphs: #{doc.paragraphs.count}"
puts "\nStyles example complete!"

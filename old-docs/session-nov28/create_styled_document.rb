#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require_relative 'lib/uniword'

puts '=== Creating Styled Document with Theme and StyleSet ==='
puts ''

# Create document
doc = Uniword::Document.new

# Load and apply theme
puts "Loading theme: 'celestial'"
require_relative 'lib/uniword/themes/yaml_theme_loader'
theme = Uniword::Themes::YamlThemeLoader.load_bundled('celestial')
doc.theme = theme
puts "✓ Theme applied: #{theme.name}"
puts "  - Colors: #{theme.color_scheme.colors.keys.length} theme colors"
puts "  - Fonts: Major=#{theme.font_scheme.major_font}, Minor=#{theme.font_scheme.minor_font}"

puts ''
puts '=== Building Document Content ==='

# Title
doc.add_paragraph('Uniword: Ruby Library for Word Documents',
                  bold: true,
                  size: 28,
                  alignment: 'center')

# Subtitle
doc.add_paragraph('Complete OOXML Support with Schema-Driven Architecture',
                  italic: true,
                  size: 14,
                  alignment: 'center')

# Blank line
doc.add_paragraph('')

# Section 1: Introduction
doc.add_paragraph('Introduction', bold: true, size: 20)

doc.add_paragraph('Uniword is a comprehensive Ruby library for creating and manipulating Microsoft Word documents in both DOCX (Word 2007+) and MHTML (Word 2003+) formats.')

doc.add_paragraph('The library uses a schema-driven architecture where document classes are generated from complete OOXML specification coverage, providing 760 elements across 22 namespaces.')

# Blank line
doc.add_paragraph('')

# Section 2: Key Features
doc.add_paragraph('Key Features', bold: true, size: 20)

features = [
  'Schema-driven generation with 760 OOXML elements',
  'Perfect round-trip fidelity for documents',
  'Theme support with 28 bundled Office themes',
  'StyleSet support with 12 professional style collections',
  'Complete DOCX and MHTML read/write support',
  'Extension system for fluent Ruby API'
]

features.each do |feature|
  doc.add_paragraph("• #{feature}")
end

# Blank line
doc.add_paragraph('')

# Section 3: Architecture
doc.add_paragraph('Architecture', bold: true, size: 20)

doc.add_paragraph('Uniword follows strict object-oriented principles:')

principles = [
  'SOLID principles - Single responsibility, open/closed, Liskov substitution',
  'MECE design - Mutually Exclusive, Collectively Exhaustive',
  'Model-Driven Architecture - Each OOXML part is a lutaml-model class',
  'Zero hardcoding - All XML generation handled by lutaml-model'
]

principles.each do |principle|
  doc.add_paragraph("  #{principle}", italic: true)
end

# Blank line
doc.add_paragraph('')

# Section 4: Usage Example
doc.add_paragraph('Quick Start Example', bold: true, size: 20)

doc.add_paragraph('Creating a document is simple:', italic: true)

code_example = <<~CODE
  require 'uniword'

  doc = Uniword::Document.new
  doc.add_paragraph("Hello World", bold: true)
  doc.apply_theme('celestial')
  doc.apply_styleset('distinctive')
  doc.save('output.docx')
CODE

code_example.lines.each do |line|
  doc.add_paragraph(line.chomp, font: 'Courier New', size: 10)
end

# Blank line
doc.add_paragraph('')

# Section 5: Benefits
doc.add_paragraph('Benefits', bold: true, size: 20)

doc.add_paragraph('The schema-driven approach provides several advantages:')

benefits = [
  ['Complete Coverage', 'All 760 OOXML elements properly modeled'],
  ['Type Safety', 'Strong typing for all attributes and elements'],
  ['Perfect Round-Trip', 'Guaranteed by complete modeling'],
  ['Easy Extensibility', 'Add features by updating YAML schemas'],
  ['Maintainability', 'Changes isolated to schema definitions']
]

benefits.each do |title, desc|
  doc.add_paragraph("#{title}: ", bold: true)
  doc.add_paragraph("  #{desc}")
end

# Blank line
doc.add_paragraph('')

# Footer
doc.add_paragraph('---', alignment: 'center')
doc.add_paragraph("Generated with Uniword v#{Uniword::VERSION}",
                  italic: true,
                  size: 10,
                  alignment: 'center')

puts "✓ Content added (#{doc.paragraphs.length} paragraphs)"

# Save document
filename = 'uniword_styled_guide.docx'
puts ''
puts '=== Saving Document ==='
doc.save(filename)
puts "✓ Saved to #{filename}"

# Verify by loading back
puts ''
puts '=== Verifying Round-Trip ==='
doc2 = Uniword.load(filename)
puts '✓ Loaded back successfully'
puts "✓ Paragraphs: #{doc2.paragraphs.length}"
puts "✓ Total characters: #{doc2.text.length}"

puts ''
puts "🎉 Document created with 'Celestial' theme and rich formatting"
puts ''
puts 'Opening document...'
system("open #{filename}")

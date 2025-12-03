#!/usr/bin/env ruby
# frozen_string_literal: true

# Test script for v6.0 Phase 3 - Configurable Styles DSL

require_relative 'lib/uniword'

puts 'Testing Configurable Styles DSL Feature...'
puts '=' * 60

# Test 1: Load style libraries
puts "\n1. Loading style libraries..."
begin
  iso_lib = Uniword::Styles::StyleLibrary.load('iso_standard')
  puts "   ✓ ISO Standard library loaded: #{iso_lib.name}"

  minimal_lib = Uniword::Styles::StyleLibrary.load('minimal')
  puts "   ✓ Minimal library loaded: #{minimal_lib.name}"

  tech_lib = Uniword::Styles::StyleLibrary.load('technical_report')
  puts "   ✓ Technical Report library loaded: #{tech_lib.name}"

  legal_lib = Uniword::Styles::StyleLibrary.load('legal_document')
  puts "   ✓ Legal Document library loaded: #{legal_lib.name}"
rescue StandardError => e
  puts "   ✗ Error: #{e.message}"
  puts e.backtrace.first(5)
end

# Test 2: Style inheritance
puts "\n2. Testing style inheritance..."
begin
  library = Uniword::Styles::StyleLibrary.load('iso_standard')

  # Test subtitle inherits from title
  subtitle = library.paragraph_style(:subtitle)
  resolved = subtitle.resolve_inheritance(library)

  if resolved[:properties][:alignment] == :center
    puts '   ✓ Subtitle inherits alignment from title'
  else
    puts '   ✗ Subtitle did not inherit alignment'
  end

  # Test heading_3 multi-level inheritance
  heading3 = library.paragraph_style(:heading_3)
  resolved3 = heading3.resolve_inheritance(library)

  if resolved3[:run_properties][:font] == 'Arial'
    puts '   ✓ Heading 3 inherits font from heading 1'
  else
    puts '   ✗ Heading 3 did not inherit font'
  end
rescue StandardError => e
  puts "   ✗ Error: #{e.message}"
end

# Test 3: StyleBuilder DSL
puts "\n3. Testing StyleBuilder DSL..."
begin
  doc = Uniword::Document.new
  builder = Uniword::Styles::StyleBuilder.new(doc, style_library: 'iso_standard')

  builder.build do
    paragraph :title, 'Test Document'
    paragraph :heading_1, 'Chapter 1'
    paragraph :body_text, 'This is body text.'

    list :bullet_list do
      item 'First point'
      item 'Second point'
    end

    table do
      row header: true do
        cell 'Header 1'
        cell 'Header 2'
      end
      row do
        cell 'Data 1'
        cell 'Data 2'
      end
    end
  end

  puts '   ✓ Document built with DSL'
  puts "   ✓ Paragraphs: #{doc.paragraphs.size}"
  puts "   ✓ Tables: #{doc.tables.size}"

  # Check first paragraph has properties
  if doc.paragraphs.first.properties
    puts '   ✓ Title paragraph has properties applied'
  else
    puts '   ✗ Title paragraph missing properties'
  end
rescue StandardError => e
  puts "   ✗ Error: #{e.message}"
  puts e.backtrace.first(5)
end

# Test 4: Document integration
puts "\n4. Testing Document integration..."
begin
  doc = Uniword::Document.new

  doc.styled_content('minimal') do
    paragraph :title, 'Simple Document'
    paragraph :heading, 'Section 1'
    paragraph :normal, 'Content here.'

    list :bullet_list do
      item 'Item 1'
    end
  end

  if doc.paragraphs.size == 4 # 3 paragraphs + 1 list item
    puts '   ✓ Document.styled_content works'
  else
    puts "   ✗ Expected 4 paragraphs, got #{doc.paragraphs.size}"
  end
rescue StandardError => e
  puts "   ✗ Error: #{e.message}"
  puts e.backtrace.first(5)
end

# Test 5: All style types
puts "\n5. Testing all style types..."
begin
  library = Uniword::Styles::StyleLibrary.load('iso_standard')

  para_styles = library.paragraph_style_names
  puts "   ✓ Paragraph styles: #{para_styles.size}"

  char_styles = library.character_style_names
  puts "   ✓ Character styles: #{char_styles.size}"

  list_styles = library.list_style_names
  puts "   ✓ List styles: #{list_styles.size}"

  table_styles = library.table_style_names
  puts "   ✓ Table styles: #{table_styles.size}"

  semantic_styles = library.semantic_style_names
  puts "   ✓ Semantic styles: #{semantic_styles.size}"
rescue StandardError => e
  puts "   ✗ Error: #{e.message}"
end

puts "\n#{'=' * 60}"
puts 'Configurable Styles DSL testing complete!'

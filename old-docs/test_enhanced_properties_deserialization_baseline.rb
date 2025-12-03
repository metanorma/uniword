#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/uniword'

puts "\n=== Enhanced Properties Deserialization Baseline Test ===\n\n"

# Test 1: Create a document with enhanced properties and save it
puts 'Step 1: Creating document with enhanced properties...'
doc = Uniword::Document.new

# Add paragraph with borders, shading, and tab stops
para1 = doc.add_paragraph('Paragraph with borders and shading')
para1.set_borders(top: '000000', bottom: 'FF0000', left: '0000FF')
para1.set_shading(fill: 'FFFF00', pattern: 'solid')
para1.add_tab_stop(position: 1440, alignment: 'center', leader: 'dot')
para1.add_tab_stop(position: 2880, alignment: 'right')

# Add paragraph with run effects
para2 = doc.add_paragraph('Run with enhanced properties: ')
run = para2.runs.first
run.character_spacing = 20
run.kerning = 24
run.position = 5
run.text_expansion = 120
run.emphasis_mark = 'dot'
run.language = 'en-US'
run.outline = true
run.shadow = true
run.set_shading(fill: 'FFFF00', pattern: 'solid')

output_path = 'test_output/enhanced_props_baseline.docx'
doc.save(output_path)
puts "✅ Document created and saved to #{output_path}"

# Test 2: Load the document back and check if properties are preserved
puts "\nStep 2: Loading document and checking deserialization..."
loaded_doc = Uniword::Document.open(output_path)

# Check basic structure first
puts "\n📋 Document Structure:"
puts "  Body exists: #{!loaded_doc.body.nil?}"
puts "  Body class: #{loaded_doc.body.class}"
puts "  Body paragraphs: #{loaded_doc.body.paragraphs.inspect}"
puts "  Paragraph count: #{begin
  loaded_doc.body.paragraphs.size
rescue StandardError
  'ERROR'
end}"

# Check paragraph 1 properties
if loaded_doc.body.paragraphs.empty?
  puts "\n❌ ERROR: No paragraphs found in loaded document!"
  puts 'This suggests deserialization is not working properly.'
  exit 1
end

loaded_para1 = loaded_doc.body.paragraphs[0]
puts "\n📋 Paragraph 1 Properties:"
puts "  Para class: #{loaded_para1.class}"
puts "  Text: #{begin
  loaded_para1.text
rescue StandardError
  'NO TEXT METHOD'
end}"
puts "  Borders: #{loaded_para1.properties.borders.inspect}"
if loaded_para1.properties.borders
  puts "    - Top: #{loaded_para1.properties.borders.top.inspect}"
  puts "    - Bottom: #{loaded_para1.properties.borders.bottom.inspect}"
  puts "    - Left: #{loaded_para1.properties.borders.left.inspect}"
end
puts "  Shading: #{loaded_para1.properties.shading.inspect}"
if loaded_para1.properties.shading
  puts "    - Fill: #{loaded_para1.properties.shading.fill}"
  puts "    - Pattern: #{loaded_para1.properties.shading.shading_type}"
end
puts "  Tab Stops: #{loaded_para1.properties.tab_stops.inspect}"
if loaded_para1.properties.tab_stops
  puts "    - Count: #{loaded_para1.properties.tab_stops.tab_stops.size}"
  loaded_para1.properties.tab_stops.tab_stops.each_with_index do |tab, i|
    puts "    - Tab #{i + 1}: pos=#{tab.position}, align=#{tab.alignment}, leader=#{tab.leader}"
  end
end

# Check paragraph 2 run properties
loaded_para2 = loaded_doc.body.paragraphs[1]
loaded_run = loaded_para2.runs.first
puts "\n📋 Paragraph 2 Run Properties:"
puts "  Text: '#{loaded_run.text}'"
puts "  Character Spacing: #{loaded_run.properties.character_spacing.inspect}"
if loaded_run.properties.character_spacing
  puts "    - Value: #{loaded_run.properties.character_spacing.val}"
end
puts "  Kerning: #{loaded_run.properties.kerning.inspect}"
puts "    - Value: #{loaded_run.properties.kerning.val}" if loaded_run.properties.kerning
puts "  Position: #{loaded_run.properties.position.inspect}"
puts "    - Value: #{loaded_run.properties.position.val}" if loaded_run.properties.position
puts "  Text Expansion: #{loaded_run.properties.text_expansion.inspect}"
if loaded_run.properties.text_expansion
  puts "    - Value: #{loaded_run.properties.text_expansion.val}"
end
puts "  Emphasis Mark: #{loaded_run.properties.emphasis_mark.inspect}"
if loaded_run.properties.emphasis_mark
  puts "    - Value: #{loaded_run.properties.emphasis_mark.val}"
end
puts "  Language: #{loaded_run.properties.language.inspect}"
puts "    - Value: #{loaded_run.properties.language.val}" if loaded_run.properties.language
puts "  Outline: #{loaded_run.properties.outline}"
puts "  Shadow: #{loaded_run.properties.shadow}"
puts "  Shading: #{loaded_run.properties.shading.inspect}"
if loaded_run.properties.shading
  puts "    - Fill: #{loaded_run.properties.shading.fill}"
  puts "    - Pattern: #{loaded_run.properties.shading.shading_type}"
end

# Test 3: Verify values match
puts "\n=== Verification Results ===\n"

errors = []

# Verify paragraph borders
if loaded_para1.properties.borders.nil?
  errors << '❌ Paragraph borders not deserialized'
elsif !loaded_para1.properties.borders.top
  errors << '❌ Top border not preserved'
elsif loaded_para1.properties.borders.top.color != '000000'
  errors << "❌ Top border color mismatch: expected 000000, got #{loaded_para1.properties.borders.top.color}"
else
  puts '✅ Paragraph borders preserved correctly'
end

# Verify paragraph shading
if loaded_para1.properties.shading.nil?
  errors << '❌ Paragraph shading not deserialized'
elsif loaded_para1.properties.shading.fill != 'FFFF00'
  errors << "❌ Shading fill mismatch: expected FFFF00, got #{loaded_para1.properties.shading.fill}"
else
  puts '✅ Paragraph shading preserved correctly'
end

# Verify tab stops
if loaded_para1.properties.tab_stops.nil?
  errors << '❌ Tab stops not deserialized'
elsif loaded_para1.properties.tab_stops.tab_stops.size != 2
  errors << "❌ Tab stop count mismatch: expected 2, got #{loaded_para1.properties.tab_stops.tab_stops.size}"
else
  puts '✅ Tab stops preserved correctly'
end

# Verify run character spacing
if loaded_run.properties.character_spacing.nil?
  errors << '❌ Character spacing not deserialized'
elsif loaded_run.properties.character_spacing.val != 20
  errors << "❌ Character spacing mismatch: expected 20, got #{loaded_run.properties.character_spacing.val}"
else
  puts '✅ Character spacing preserved correctly'
end

# Verify run kerning
if loaded_run.properties.kerning.nil?
  errors << '❌ Kerning not deserialized'
elsif loaded_run.properties.kerning.val != 24
  errors << "❌ Kerning mismatch: expected 24, got #{loaded_run.properties.kerning.val}"
else
  puts '✅ Kerning preserved correctly'
end

# Verify run position
if loaded_run.properties.position.nil?
  errors << '❌ Position not deserialized'
elsif loaded_run.properties.position.val != 5
  errors << "❌ Position mismatch: expected 5, got #{loaded_run.properties.position.val}"
else
  puts '✅ Position preserved correctly'
end

# Verify text expansion
if loaded_run.properties.text_expansion.nil?
  errors << '❌ Text expansion not deserialized'
elsif loaded_run.properties.text_expansion.val != 120
  errors << "❌ Text expansion mismatch: expected 120, got #{loaded_run.properties.text_expansion.val}"
else
  puts '✅ Text expansion preserved correctly'
end

# Verify emphasis mark
if loaded_run.properties.emphasis_mark.nil?
  errors << '❌ Emphasis mark not deserialized'
elsif loaded_run.properties.emphasis_mark.val != 'dot'
  errors << "❌ Emphasis mark mismatch: expected 'dot', got #{loaded_run.properties.emphasis_mark.val}"
else
  puts '✅ Emphasis mark preserved correctly'
end

# Verify language
if loaded_run.properties.language.nil?
  errors << '❌ Language not deserialized'
elsif loaded_run.properties.language.val != 'en-US'
  errors << "❌ Language mismatch: expected 'en-US', got #{loaded_run.properties.language.val}"
else
  puts '✅ Language preserved correctly'
end

# Verify text effects (boolean properties)
if loaded_run.properties.outline
  puts '✅ Outline preserved correctly'
else
  errors << '❌ Outline not preserved'
end

if loaded_run.properties.shadow
  puts '✅ Shadow preserved correctly'
else
  errors << '❌ Shadow not preserved'
end

# Verify run shading
if loaded_run.properties.shading.nil?
  errors << '❌ Run shading not deserialized'
elsif loaded_run.properties.shading.fill != 'FFFF00'
  errors << "❌ Run shading fill mismatch: expected FFFF00, got #{loaded_run.properties.shading.fill}"
else
  puts '✅ Run shading preserved correctly'
end

# Summary
puts "\n=== Summary ===\n"
if errors.empty?
  puts '🎉 SUCCESS! All enhanced properties are being deserialized correctly!'
  puts "✅ Deserialization is working through lutaml-model's automatic handling"
  exit 0
else
  puts "⚠️  Found #{errors.size} issue(s):"
  errors.each { |err| puts "  #{err}" }
  puts "\n💡 These issues need to be investigated and fixed."
  exit 1
end

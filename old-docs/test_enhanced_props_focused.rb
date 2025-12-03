#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/uniword'

puts "\n=== Enhanced Properties Focused Round-Trip Test ===\n\n"

# Create document with ONLY enhanced properties (no styles)
doc = Uniword::Document.new

# Paragraph with borders
para1 = doc.add_paragraph('Text with paragraph borders')
para1.set_borders(top: 'FF0000', bottom: '0000FF')

# Paragraph with shading
para2 = doc.add_paragraph('Text with paragraph shading')
para2.set_shading(fill: 'FFFF00', pattern: 'solid')

# Paragraph with tab stops
para3 = doc.add_paragraph('Text with tab stops')
para3.add_tab_stop(position: 1440, alignment: 'center', leader: 'dot')

# Run with character spacing
para4 = doc.add_paragraph('Text with run properties')
run = para4.runs.first
run.character_spacing = 20
run.kerning = 24
run.position = 5
run.text_expansion = 120
run.emphasis_mark = 'dot'
run.language = 'en-US'

# Run with text effects
para5 = doc.add_paragraph('Text with outline and shadow')
run5 = para5.runs.first
run5.outline = true
run5.shadow = true
run5.emboss = true

# Save
output_path = 'test_output/enhanced_props_focused.docx'
doc.save(output_path)
puts "✅ Document saved to #{output_path}"

# Load back
loaded_doc = Uniword::Document.open(output_path)
puts '✅ Document loaded'

# Check each property
errors = []

# Check paragraph 1 - borders
loaded_para1 = loaded_doc.body.paragraphs[0]
if loaded_para1.nil?
  errors << '❌ Paragraph 1 not found'
elsif loaded_para1.properties.borders.nil?
  errors << '❌ Paragraph 1: borders not deserialized'
elsif loaded_para1.properties.borders.top.nil?
  errors << '❌ Paragraph 1: top border not deserialized'
elsif loaded_para1.properties.borders.top.color != 'FF0000'
  errors << "❌ Paragraph 1: top border color mismatch (got #{loaded_para1.properties.borders.top.color})"
else
  puts '✅ Paragraph borders preserved'
end

# Check paragraph 2 - shading
loaded_para2 = loaded_doc.body.paragraphs[1]
if loaded_para2.nil?
  errors << '❌ Paragraph 2 not found'
elsif loaded_para2.properties.shading.nil?
  errors << '❌ Paragraph 2: shading not deserialized'
elsif loaded_para2.properties.shading.fill != 'FFFF00'
  errors << "❌ Paragraph 2: shading fill mismatch (got #{loaded_para2.properties.shading.fill})"
else
  puts '✅ Paragraph shading preserved'
end

# Check paragraph 3 - tab stops
loaded_para3 = loaded_doc.body.paragraphs[2]
if loaded_para3.nil?
  errors << '❌ Paragraph 3 not found'
elsif loaded_para3.properties.tab_stops.nil?
  errors << '❌ Paragraph 3: tab stops not deserialized'
elsif !loaded_para3.properties.tab_stops.any_tabs?
  errors << '❌ Paragraph 3: tab stops collection empty'
elsif loaded_para3.properties.tab_stops.tabs.first.position != 1440
  errors << '❌ Paragraph 3: tab stop position mismatch'
else
  puts '✅ Tab stops preserved'
end

# Check paragraph 4 - run properties
loaded_para4 = loaded_doc.body.paragraphs[3]
if loaded_para4.nil?
  errors << '❌ Paragraph 4 not found'
else
  loaded_run = loaded_para4.runs.first
  if loaded_run.nil?
    errors << '❌ Paragraph 4: run not found'
  else
    # Character spacing
    if loaded_run.properties.character_spacing.nil?
      errors << '❌ Run: character_spacing not deserialized'
    elsif loaded_run.properties.character_spacing.val != 20
      errors << "❌ Run: character_spacing value mismatch (got #{loaded_run.properties.character_spacing.val})"
    else
      puts '✅ Character spacing preserved'
    end

    # Kerning
    if loaded_run.properties.kerning.nil?
      errors << '❌ Run: kerning not deserialized'
    elsif loaded_run.properties.kerning.val != 24
      errors << "❌ Run: kerning value mismatch (got #{loaded_run.properties.kerning.val})"
    else
      puts '✅ Kerning preserved'
    end

    # Position
    if loaded_run.properties.position.nil?
      errors << '❌ Run: position not deserialized'
    elsif loaded_run.properties.position.val != 5
      errors << "❌ Run: position value mismatch (got #{loaded_run.properties.position.val})"
    else
      puts '✅ Position preserved'
    end

    # Text expansion
    if loaded_run.properties.text_expansion.nil?
      errors << '❌ Run: text_expansion not deserialized'
    elsif loaded_run.properties.text_expansion.val != 120
      errors << "❌ Run: text_expansion value mismatch (got #{loaded_run.properties.text_expansion.val})"
    else
      puts '✅ Text expansion preserved'
    end

    # Emphasis mark
    if loaded_run.properties.emphasis_mark.nil?
      errors << '❌ Run: emphasis_mark not deserialized'
    elsif loaded_run.properties.emphasis_mark.val != 'dot'
      errors << "❌ Run: emphasis_mark value mismatch (got #{loaded_run.properties.emphasis_mark.val})"
    else
      puts '✅ Emphasis mark preserved'
    end

    # Language
    if loaded_run.properties.language.nil?
      errors << '❌ Run: language not deserialized'
    elsif loaded_run.properties.language.val != 'en-US'
      errors << "❌ Run: language value mismatch (got #{loaded_run.properties.language.val})"
    else
      puts '✅ Language preserved'
    end
  end
end

# Check paragraph 5 - text effects (booleans)
loaded_para5 = loaded_doc.body.paragraphs[4]
if loaded_para5.nil?
  errors << '❌ Paragraph 5 not found'
else
  loaded_run5 = loaded_para5.runs.first
  if loaded_run5.nil?
    errors << '❌ Paragraph 5: run not found'
  else
    if loaded_run5.properties.outline
      puts '✅ Outline preserved'
    else
      errors << '❌ Run: outline not preserved'
    end

    if loaded_run5.properties.shadow
      puts '✅ Shadow preserved'
    else
      errors << '❌ Run: shadow not preserved'
    end

    if loaded_run5.properties.emboss
      puts '✅ Emboss preserved'
    else
      errors << '❌ Run: emboss not preserved'
    end
  end
end

# Summary
puts "\n=== Summary ===\n"
if errors.empty?
  puts '🎉 SUCCESS! All enhanced properties round-trip correctly!'
  exit 0
else
  puts "⚠️  Found #{errors.size} issue(s):"
  errors.each { |err| puts "  #{err}" }
  exit 1
end

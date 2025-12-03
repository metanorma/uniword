# frozen_string_literal: true

require_relative 'lib/uniword'

puts 'Testing Paragraph#numbering= setter...'
doc = Uniword::Document.new
para = doc.add_paragraph('Test item')
para.numbering = { reference: 'test-ref', level: 0 }
puts "✓ Paragraph numbering setter works: #{para.numbering.inspect}"

puts "\nTesting Run properties lazy initialization..."
run = Uniword::Run.new(text: 'Test')
run.bold = true
run.italic = true
run.color = 'FF0000'
puts "✓ Run properties work: bold=#{run.bold}, italic=#{run.italic}, color=#{run.color}"

puts "\nTesting Section#page_margins= setter..."
section = Uniword::Section.new
section.page_margins = { top: 1440, bottom: 1440, left: 1800, right: 1800 }
puts "✓ Section page_margins setter works: top=#{section.properties.margin_top}, left=#{section.properties.margin_left}"

puts "\nAll fixes verified successfully!"

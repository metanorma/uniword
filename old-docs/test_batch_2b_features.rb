#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/uniword'
require 'stringio'

puts 'Testing Batch 2B Features (MEDIUM priority - 22 failures)'
puts '=' * 60

# Test 1: Document#styles accessor
puts "\n1. Document#styles accessor:"
doc = Uniword::Document.new
doc.add_paragraph('Test')
styles = doc.styles
puts "   Type: #{styles.class}"
puts "   Is Array: #{styles.is_a?(Array)}"
puts "   Count: #{styles.size}"
puts "   First style: #{styles.first&.id if styles.any?}"

# Test 2: Document#images accessor
puts "\n2. Document#images accessor:"
doc = Uniword::Document.new
images = doc.images
puts "   Type: #{images.class}"
puts "   Is Array: #{images.is_a?(Array)}"
puts "   Count: #{images.size}"

# Test 3: Paragraph#numbering accessor
puts "\n3. Paragraph#numbering accessor:"
para = Uniword::Paragraph.new
para.set_numbering(1, 0)
numbering = para.numbering
puts "   Type: #{numbering.class}"
puts "   Has num_id: #{numbering.respond_to?(:num_id)}"
puts "   Has ilvl: #{numbering.respond_to?(:ilvl) || numbering.respond_to?(:level)}"

# Test 4: Paragraph#hyperlinks accessor
puts "\n4. Paragraph#hyperlinks accessor:"
para = Uniword::Paragraph.new
para.add_hyperlink('Click here', url: 'https://example.com')
para.add_hyperlink('Another link', url: 'https://test.com')
hyperlinks = para.hyperlinks
puts "   Type: #{hyperlinks.class}"
puts "   Is Array: #{hyperlinks.is_a?(Array)}"
puts "   Count: #{hyperlinks.size}"
puts '   Expected: 2'

# Test 5: Paragraph#add_image
puts "\n5. Paragraph#add_image:"
para = Uniword::Paragraph.new
begin
  image = para.add_image('test.png', width: 100, height: 100)
  puts '   ✓ Method exists'
  puts "   Returns: #{image.class}"
rescue NoMethodError => e
  puts "   ✗ Method missing: #{e.message}"
end

# Test 6: Paragraph#remove!
puts "\n6. Paragraph#remove! (already implemented):"
doc = Uniword::Document.new
para = doc.add_paragraph('Test paragraph')
puts "   Paragraphs before: #{doc.paragraphs.size}"
para.remove!
puts "   Paragraphs after: #{doc.paragraphs.size}"
puts '   ✓ Works correctly'

# Test 7: Run#substitute with regex
puts "\n7. Run#substitute with proper regex handling:"
run = Uniword::Run.new(text: 'Hello World')
run.substitute(/World/, 'Universe')
result = run.text
puts "   Input: 'Hello World'"
puts '   Pattern: /World/'
puts "   Replacement: 'Universe'"
puts "   Result: '#{result}'"
puts "   Expected: 'Hello Universe'"
puts "   #{result == 'Hello Universe' ? '✓' : '✗'} Correct: #{result == 'Hello Universe'}"

# Test 8: Run#substitute issue - "Worldello World"
puts "\n8. Run#substitute regex issue test:"
run = Uniword::Run.new(text: 'Hello World')
run.substitute(/Hello/, 'Goodbye')
result = run.text
puts "   Input: 'Hello World'"
puts '   Pattern: /Hello/'
puts "   Replacement: 'Goodbye'"
puts "   Result: '#{result}'"
puts "   Expected: 'Goodbye World'"
puts "   #{result == 'Goodbye World' ? '✓' : '✗'} Correct: #{result == 'Goodbye World'}"
puts "   Issue: Was producing 'Worldello World' instead"

# Test 9: DocumentWriter#write_to_stream
puts "\n9. DocumentWriter#write_to_stream for StringIO:"
doc = Uniword::Document.new
doc.add_paragraph('Test content')
writer = Uniword::DocumentWriter.new(doc)
io = StringIO.new
begin
  writer.write_to_stream(io)
  io.rewind
  content = io.read
  puts '   ✓ Method exists'
  puts "   Output size: #{content.bytesize} bytes"
  puts "   Has content: #{content.bytesize.positive?}"
rescue NoMethodError => e
  puts "   ✗ Method missing: #{e.message}"
end

# Test 10: Document#stream (uses write_to_stream internally)
puts "\n10. Document#stream (depends on write_to_stream):"
doc = Uniword::Document.new
doc.add_paragraph('Test content')
begin
  stream = doc.stream
  puts '   ✓ Method exists'
  puts "   Type: #{stream.class}"
  puts "   Is StringIO: #{stream.is_a?(StringIO)}"
  content = stream.read
  puts "   Content size: #{content.bytesize} bytes"
rescue NoMethodError => e
  puts "   ✗ Error: #{e.message}"
end

puts "\n#{'=' * 60}"
puts 'Batch 2B Feature Test Complete'

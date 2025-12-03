# frozen_string_literal: true

require_relative 'lib/uniword'

puts '=== Debug Document Body Serialization ==='
puts

# Create document
doc = Uniword::Document.new
puts '1. Document created'
puts "   body present: #{!doc.body.nil?}"
puts "   body class: #{doc.body.class}"
puts "   body paragraphs: #{doc.body.paragraphs.size}"
puts

# Add paragraphs
para1 = Uniword::Paragraph.new
para1.add_text('Test paragraph')
doc.add_element(para1)

puts '2. After adding paragraph:'
puts "   body paragraphs: #{doc.body.paragraphs.size}"
puts "   paragraph text: #{doc.body.paragraphs.first.text}"
puts

# Try serializing just the body
puts '3. Serialize body directly:'
body_xml = doc.body.to_xml
puts body_xml
puts

# Try serializing document
puts '4. Serialize document:'
doc_xml = doc.to_xml
puts doc_xml
puts

# Check attributes hash
puts '5. Document attributes:'
puts "   respond_to?(:attributes): #{doc.respond_to?(:attributes)}"
puts "   attributes: #{doc.attributes.inspect}" if doc.respond_to?(:attributes)

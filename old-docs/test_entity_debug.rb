# frozen_string_literal: true

require 'bundler/setup'
require 'uniword'

# Create document with entities
doc = Uniword::Document.new
para = Uniword::Paragraph.new
para.add_text('&nbsp; &copy; &reg; &trade;')
doc.add_element(para)

# Save to MHTML
output_path = 'spec/tmp/entity_test.doc'
doc.save(output_path, format: :mhtml)

# Read the raw file
content = File.read(output_path)
puts '=== RAW MHTML CONTENT ==='
puts content[0..2000]
puts "\n=== END ==="

# Load it back
doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)
puts "\n=== LOADED TEXT ==="
puts doc2.text.inspect
puts "\n=== END ==="

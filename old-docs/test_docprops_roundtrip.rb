# frozen_string_literal: true

require 'bundler/setup'
require 'canon'
require_relative 'lib/uniword'

# Load original document
puts 'Loading original document...'
doc = Uniword::Document.open('examples/demo_formal_integral_proper.docx')

# Save to new location
output_path = 'test_output/demo_roundtrip.docx'
puts "Saving to #{output_path}..."
doc.save(output_path)

# Extract and compare docProps files
require 'zip'

def extract_file(docx_path, file_path)
  Zip::File.open(docx_path) do |zip|
    entry = zip.find_entry(file_path)
    return entry&.get_input_stream&.read
  end
end

puts "\n=== Testing docProps/core.xml ==="
original_core = extract_file('examples/demo_formal_integral_proper.docx', 'docProps/core.xml')
roundtrip_core = extract_file(output_path, 'docProps/core.xml')

if Canon::Xml.equivalent?(original_core, roundtrip_core)
  puts '✅ core.xml MATCHES (semantically equivalent)'
else
  puts '❌ core.xml DIFFERS'
  puts "\nOriginal:"
  puts original_core
  puts "\nRound-trip:"
  puts roundtrip_core
end

puts "\n=== Testing docProps/app.xml ==="
original_app = extract_file('examples/demo_formal_integral_proper.docx', 'docProps/app.xml')
roundtrip_app = extract_file(output_path, 'docProps/app.xml')

if Canon::Xml.equivalent?(original_app, roundtrip_app)
  puts '✅ app.xml MATCHES (semantically equivalent)'
else
  puts '❌ app.xml DIFFERS'
  puts "\nOriginal:"
  puts original_app
  puts "\nRound-trip:"
  puts roundtrip_app
end

puts "\n=== Summary ==="
core_match = Canon::Xml.equivalent?(original_core, roundtrip_core)
app_match = Canon::Xml.equivalent?(original_app, roundtrip_app)

if core_match && app_match
  puts '✅✅ BOTH docProps files pass Canon tests!'
else
  puts '❌ Some docProps files failed'
  puts "  core.xml: #{core_match ? '✅' : '❌'}"
  puts "  app.xml: #{app_match ? '✅' : '❌'}"
end

# frozen_string_literal: true

require 'bundler/setup'
require 'canon'
require 'zip'
require_relative 'lib/uniword/ooxml/docx_package'
require_relative 'spec/support/xml_normalizers'

def extract(path, file)
  Zip::File.open(path) { |z| z.find_entry(file)&.get_input_stream&.read }
end

# Load and save with DocxPackage
package = Uniword::Ooxml::DocxPackage.from_file('examples/demo_formal_integral_proper.docx')
package.to_file('test_output/docx_pkgrt.docx')

# Test all 13 files
files = [
  '[Content_Types].xml',
  '_rels/.rels',
  'docProps/core.xml',
  'docProps/app.xml',
  'word/document.xml',
  'word/styles.xml',
  'word/fontTable.xml',
  'word/settings.xml',
  'word/webSettings.xml',
  'word/numbering.xml',
  'word/_rels/document.xml.rels',
  'word/theme/theme1.xml',
  'word/theme/_rels/theme1.xml.rels'
]

passed = 0
failed = 0

files.each do |file|
  orig = extract('examples/demo_formal_integral_proper.docx', file)
  rt = extract('test_output/docx_pkgrt.docx', file)

  next unless orig && rt # Skip if file doesn't exist

  orig_norm = XmlNormalizers.normalize_for_roundtrip(orig)
  rt_norm = XmlNormalizers.normalize_for_roundtrip(rt)

  begin
    match = Canon::Comparison.equivalent?(orig_norm, rt_norm)
    if match
      puts "✅ #{file}"
      passed += 1
    else
      puts "❌ #{file}"
      failed += 1
    end
  rescue StandardError => e
    puts "❌ #{file} - #{e.class}"
    failed += 1
  end
end

puts "\n=== DocxPackage Round-Trip ==="
puts "Passed: #{passed}/13"
puts "Failed: #{failed}/13"
puts "Success Rate: #{(passed * 100.0 / 13).round}%"

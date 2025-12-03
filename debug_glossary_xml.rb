#!/usr/bin/env ruby
# Debug script to compare glossary XML input vs output directly

require 'bundler/setup'
require 'uniword'
require 'fileutils'

input_file = 'references/word-resources/document-elements/Equations.dotx'
output_dir = '/tmp/equations_compare'

# Clean and create output directory
FileUtils.rm_rf(output_dir)
FileUtils.mkdir_p(output_dir)

# Extract original
system("unzip -q -o '#{input_file}' -d #{output_dir}/original")

# Read original glossary XML
original_xml = File.read("#{output_dir}/original/word/glossary/document.xml")

# Parse with Uniword
puts "Loading GlossaryDocument..."
glossary_doc = Uniword::Glossary::GlossaryDocument.from_xml(original_xml)

# Serialize back
puts "Serializing to XML..."
roundtrip_xml = glossary_doc.to_xml

# Write both for comparison
File.write("#{output_dir}/original.xml", original_xml)
File.write("#{output_dir}/roundtrip.xml", roundtrip_xml)

puts "\n" + "=" * 80
puts "XML FILES WRITTEN TO: #{output_dir}"
puts "=" * 80
puts "  - original.xml  (input)"
puts "  - roundtrip.xml (output)"
puts "=" * 80

# Show first oMathPara section
puts "\nFIRST oMathPara in ORIGINAL:"
puts "=" * 80
if original_xml =~ /(<m:oMathPara>.*?<\/m:oMathPara>)/m
  puts $1[0, 1000]
end

puts "\n\nFIRST oMathPara in ROUNDTRIP:"
puts "=" * 80
if roundtrip_xml =~ /(<m:oMathPara>.*?<\/m:oMathPara>)/m
  puts $1[0, 1000]
else
  puts "NOT FOUND!"
end

puts "\n" + "=" * 80
puts "Use: diff #{output_dir}/original.xml #{output_dir}/roundtrip.xml"
puts "=" * 80
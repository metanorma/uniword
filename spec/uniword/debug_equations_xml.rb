# frozen_string_literal: true

# Debug script to compare input vs output XML directly
require "bundler/setup"
require "uniword"
require "fileutils"

input_file = "references/word-resources/document-elements/Equations.dotx"
output_dir = "/tmp/equations_debug"

# Clean and create output directory
FileUtils.rm_rf(output_dir)
FileUtils.mkdir_p(output_dir)

# Extract original
system("unzip -q -o '#{input_file}' -d #{output_dir}/original")

# Load and save through Uniword
doc_package = Uniword::Docx::Package.from_file(input_file)
temp_output = "#{output_dir}/roundtrip.dotx"
doc_package.save(temp_output)

# Extract roundtrip
system("unzip -q -o '#{temp_output}' -d #{output_dir}/roundtrip")

# Compare glossary document XML
original_xml = File.read("#{output_dir}/original/word/glossary/document.xml")
roundtrip_xml = File.read("#{output_dir}/roundtrip/word/glossary/document.xml")

# Write for comparison
File.write("#{output_dir}/original_glossary.xml", original_xml)
File.write("#{output_dir}/roundtrip_glossary.xml", roundtrip_xml)

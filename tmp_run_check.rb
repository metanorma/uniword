# frozen_string_literal: true

require_relative "lib/uniword"
require "nokogiri"

dotx_path = "references/word-resources/document-elements/Cover Pages.dotx"
xml = nil
Zip::File.open(dotx_path) do |zip|
  xml = zip.find_entry("word/glossary/document.xml").get_input_stream.read
end

glossary = Uniword::Glossary::GlossaryDocument.from_xml(xml)

ns = {
  "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
  "mc" => "http://schemas.openxmlformats.org/markup-compatibility/2006"
}

# DocPart[0] - the paragraph has an AlternateContent inside a run
# Let's check: does the Paragraph model have AlternateContent?
dp0 = glossary.doc_parts.doc_part[0]
p0 = dp0.doc_part_body.paragraphs[0]

# Check what's in the paragraph's run
puts "=== Paragraph[0] runs ==="
r0 = p0.runs[0]
puts "Run[0] class: #{r0.class}"
puts "Run[0] attributes: #{r0.class.attributes.keys.sort.join(', ')}"

# Check if run has AlternateContent
r0_attrs = r0.class.attributes.keys
puts "\nRun has alternate_content? #{r0_attrs.include?(:alternate_content)}"
puts "Run has alternate_contents? #{r0_attrs.include?(:alternate_contents)}"
puts "Run has drawing? #{r0_attrs.include?(:drawing)}"
puts "Run has drawings? #{r0_attrs.include?(:drawings)}"

# Let's check ALL attributes
puts "\nAll run attributes:"
r0_attrs.each { |a| puts "  #{a}" }

# Now check if the AlternateContent is being deserialized into the run
# Serialize just the run
r0_xml = r0.to_xml
r0_doc = Nokogiri::XML(r0_xml)
puts "\nRun[0] serialized AC count: #{r0_doc.xpath('//mc:AlternateContent', ns).count}"
puts "Run[0] serialized drawing count: #{r0_doc.xpath('//w:drawing', ns).count}"

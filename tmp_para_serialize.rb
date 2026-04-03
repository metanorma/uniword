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

# Serialize DocPart[1] paragraph[0]
dp1 = glossary.doc_parts.doc_part[1]
p0 = dp1.doc_part_body.paragraphs[0]

p0_xml = p0.to_xml
p0_doc = Nokogiri::XML(p0_xml)

puts "Serialized paragraph AC count: #{p0_doc.xpath('//mc:AlternateContent', ns).count}"

# Original paragraph
orig_doc = Nokogiri::XML(xml)
orig_dp1 = orig_doc.xpath('//w:docPart', ns)[1]
orig_p0 = orig_dp1.xpath('.//w:docPartBody/w:p', ns)[0]

puts "Original paragraph AC count: #{orig_p0.xpath('.//mc:AlternateContent', ns).count}"

# The difference should be the nested AC inside anchors
puts "\nDifference: #{orig_p0.xpath('.//mc:AlternateContent', ns).count - p0_doc.xpath('//mc:AlternateContent', ns).count}"

# Check: are the nested AC inside wp:anchor being lost?
# The anchor's positionH/positionV should have AC wrappers
puts "\n=== Checking anchor positioning ==="

# In original: anchor has AC > Choice > positionH and AC > Fallback > positionH
# In serialized: anchor has no positionH/positionV at all

# Check serialized anchor for positionH
puts "Serialized positionH: #{p0_doc.xpath('//wp:positionH', ns).count}"
puts "Serialized positionV: #{p0_doc.xpath('//wp:positionV', ns).count}"

orig_anchor = orig_p0.xpath('.//wp:anchor', ns)[0]
puts "\nOriginal positionH: #{orig_anchor.xpath('.//wp:positionH', ns).count}"
puts "Original positionV: #{orig_anchor.xpath('.//wp:positionV', ns).count}"

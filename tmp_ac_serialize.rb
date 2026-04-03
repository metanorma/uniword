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

# Check DocPart[0] paragraph[0] in detail - it has 1 AC in deserialized model
dp0 = glossary.doc_parts.doc_part[0]
p0 = dp0.doc_part_body.paragraphs[0]

# Serialize just this paragraph
p0_xml = p0.to_xml
puts "=== DocPart[0] p[0] serialized ==="
puts p0_xml

# Count AC in serialized
p0_doc = Nokogiri::XML(p0_xml)
puts "\nSerialized AC count: #{p0_doc.xpath('//mc:AlternateContent', ns).count}"
puts "Serialized drawing count: #{p0_doc.xpath('//w:drawing', ns).count}"
puts "Serialized txbxContent count: #{p0_doc.xpath('//w:txbxContent', ns).count}"

# Now check the original for DocPart[0]
orig_doc = Nokogiri::XML(xml)
dp0_orig = orig_doc.xpath('//w:docPart', ns)[0]
p0_orig = dp0_orig.xpath('.//w:p', ns)[0]

puts "\n=== Original DocPart[0] p[0] ==="
puts p0_orig.to_xml[0..3000]

puts "\nOriginal AC count: #{p0_orig.xpath('.//mc:AlternateContent', ns).count}"
puts "Original drawing count: #{p0_orig.xpath('.//w:drawing', ns).count}"
puts "Original txbxContent count: #{p0_orig.xpath('.//w:txbxContent', ns).count}"

# The key question: does the paragraph model have AlternateContent objects?
# Let's check what attributes the Paragraph class has
puts "\n=== Paragraph class attributes ==="
p_attrs = Uniword::Wordprocessingml::Paragraph.attribute_names
puts p_attrs.sort.join(', ')

# Check if there's an alternate_content or similar attribute
if p_attrs.include?(:alternate_contents)
  puts "Has alternate_contents attribute"
  acs = p0.alternate_contents
  puts "alternate_contents count: #{acs&.count || 0}"
elsif p_attrs.include?(:alternate_content)
  puts "Has alternate_content attribute"
else
  puts "NO alternate_content attribute found!"
  puts "Looking for AC-related attributes:"
  p_attrs.each { |a| puts "  #{a}" if a.to_s.include?('alt') || a.to_s.include?('choice') }
end

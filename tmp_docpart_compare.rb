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

# Full roundtrip
roundtrip = glossary.to_xml
rdoc = Nokogiri::XML(roundtrip)
orig_doc = Nokogiri::XML(xml)

# Compare each docPart individually
glossary.doc_parts.doc_part.each_with_index do |dp, i|
  body = dp.doc_part_body
  next unless body

  # Serialize just this docPart's body
  body_xml = body.to_xml
  body_doc = Nokogiri::XML(body_xml)

  # Get original docPart body
  orig_dp = orig_doc.xpath('//w:docPart', ns)[i]
  orig_body = orig_dp&.xpath('.//w:docPartBody', ns)&.first

  orig_ac = orig_body&.xpath('.//mc:AlternateContent', ns)&.count || 0
  ser_ac = body_doc.xpath('.//mc:AlternateContent', ns).count

  orig_texts = orig_body&.xpath('.//w:t', ns)&.map(&:text) || []
  ser_texts = body_doc.xpath('.//w:t', ns).map(&:text)

  if orig_ac != ser_ac
    puts "DocPart[#{i}]: AC orig=#{orig_ac} ser=#{ser_ac} DIFF!"
    missing = orig_texts.dup
    ser_texts.each { |t| idx = missing.index(t); missing.delete_at(idx) if idx }
    if missing.any?
      puts "  Missing texts: #{missing.map(&:inspect).join(', ')}"
    end
  end
end

# Now let's focus on DocPart[0] - count txbxContent in original vs serialized
puts "\n=== DocPart[0] detailed ==="
dp0 = glossary.doc_parts.doc_part[0]
body0 = dp0.doc_part_body
body0_xml = body0.to_xml
body0_doc = Nokogiri::XML(body0_xml)

orig_dp0 = orig_doc.xpath('//w:docPart', ns)[0]
orig_body0 = orig_dp0.xpath('.//w:docPartBody', ns).first

puts "Original txbxContent: #{orig_body0.xpath('.//w:txbxContent', ns).count}"
puts "Serialized txbxContent: #{body0_doc.xpath('.//w:txbxContent', ns).count}"

# Find which txbxContent is missing
orig_texts = orig_body0.xpath('.//w:txbxContent//w:t', ns).map(&:text)
ser_texts = body0_doc.xpath('.//w:txbxContent//w:t', ns).map(&:text)
puts "Original txbx texts: #{orig_texts.map(&:inspect).join(', ')}"
puts "Serialized txbx texts: #{ser_texts.map(&:inspect).join(', ')}"

missing = orig_texts.dup
ser_texts.each { |t| idx = missing.index(t); missing.delete_at(idx) if idx }
puts "Missing from txbxContent: #{missing.map(&:inspect).join(', ')}"

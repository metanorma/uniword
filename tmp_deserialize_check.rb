# frozen_string_literal: true

require_relative "lib/uniword"
require "nokogiri"

dotx_path = "references/word-resources/document-elements/Cover Pages.dotx"
xml = nil
Zip::File.open(dotx_path) do |zip|
  xml = zip.find_entry("word/glossary/document.xml").get_input_stream.read
end

glossary = Uniword::Glossary::GlossaryDocument.from_xml(xml)

# Count AlternateContent elements in the model
ac_count = 0
drawing_count = 0
txbx_count = 0

ns = {
  "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
  "mc" => "http://schemas.openxmlformats.org/markup-compatibility/2006"
}

# Check each docPart
glossary.doc_parts&.doc_part&.each_with_index do |dp, i|
  body = dp.doc_part_body
  next unless body

  puts "\nDocPart[#{i}]:"
  puts "  paragraphs: #{body.paragraphs&.count || 0}"
  puts "  tables: #{body.tables&.count || 0}"
  puts "  sdts: #{body.sdts&.count || 0}"

  # Check paragraphs for AlternateContent
  (body.paragraphs || []).each_with_index do |para, pi|
    # Check paragraph content for AlternateContent
    # Paragraph has runs, but also other content
    # Let's serialize each paragraph back and compare
    para_xml = para.to_xml
    para_doc = Nokogiri::XML(para_xml)
    para_ac = para_doc.xpath("//mc:AlternateContent", ns).count
    para_drawings = para_doc.xpath("//w:drawing", ns).count
    para_txbx = para_doc.xpath("//w:txbxContent", ns).count
    if para_ac > 0 || para_drawings > 0
      puts "  p[#{pi}]: AC=#{para_ac} drawings=#{para_drawings} txbx=#{para_txbx}"
    end
  end

  # Check SDTs for AlternateContent
  (body.sdts || []).each_with_index do |sdt, si|
    sdt_xml = sdt.to_xml
    sdt_doc = Nokogiri::XML(sdt_xml)
    sdt_ac = sdt_doc.xpath("//mc:AlternateContent", ns).count
    sdt_drawings = sdt_doc.xpath("//w:drawing", ns).count
    sdt_txbx = sdt_doc.xpath("//w:txbxContent", ns).count
    if sdt_ac > 0 || sdt_drawings > 0
      puts "  sdt[#{si}]: AC=#{sdt_ac} drawings=#{sdt_drawings} txbx=#{sdt_txbx}"
    end
  end
end

# Now do a full roundtrip and count
puts "\n=== Full roundtrip comparison ==="
roundtrip = glossary.to_xml
rdoc = Nokogiri::XML(roundtrip)

orig_doc = Nokogiri::XML(xml)
puts "Original AC: #{orig_doc.xpath('//mc:AlternateContent', ns).count}"
puts "Roundtrip AC: #{rdoc.xpath('//mc:AlternateContent', ns).count}"
puts "Original drawing: #{orig_doc.xpath('//w:drawing', ns).count}"
puts "Roundtrip drawing: #{rdoc.xpath('//w:drawing', ns).count}"
puts "Original txbxContent: #{orig_doc.xpath('//w:txbxContent', ns).count}"
puts "Roundtrip txbxContent: #{rdoc.xpath('//w:txbxContent', ns).count}"

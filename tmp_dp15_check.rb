# frozen_string_literal: true

require_relative "lib/uniword"
require "nokogiri"

dotx_path = "references/word-resources/document-elements/Cover Pages.dotx"
xml = nil
Zip::File.open(dotx_path) do |zip|
  xml = zip.find_entry("word/glossary/document.xml").get_input_stream.read
end

orig_doc = Nokogiri::XML(xml)
glossary = Uniword::Glossary::GlossaryDocument.from_xml(xml)

ns = {
  "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
  "mc" => "http://schemas.openxmlformats.org/markup-compatibility/2006"
}

# DocPart[15] - original has 0 AC, serialized has 3
[15, 16].each do |idx|
  puts "\n=== DocPart[#{idx}] ==="
  orig_dp = orig_doc.xpath('//w:docPart', ns)[idx]
  orig_body = orig_dp.xpath('.//w:docPartBody', ns).first

  puts "Original children:"
  orig_body.element_children.each_with_index do |child, ci|
    pfx = child.namespace&.prefix || "none"
    puts "  [#{ci}] #{pfx}:#{child.name}"
  end

  # Check if there are v:shape elements with textboxes
  vml_shapes = orig_body.xpath('.//v:shape', 'v' => 'urn:schemas-microsoft-com:vml')
  puts "v:shape count: #{vml_shapes.count}"

  # Serialize
  dp = glossary.doc_parts.doc_part[idx]
  body = dp.doc_part_body
  puts "\nDeserialized:"
  puts "  paragraphs: #{body.paragraphs&.count || 0}"
  puts "  sdts: #{body.sdts&.count || 0}"
  puts "  tables: #{body.tables&.count || 0}"

  # Check paragraph content
  if body.paragraphs&.any?
    body.paragraphs.each_with_index do |para, pi|
      puts "  p[#{pi}] runs: #{para.runs&.count || 0}"
      para.runs&.each_with_index do |r, ri|
        r_xml = r.to_xml
        r_doc = Nokogiri::XML(r_xml)
        ac = r_doc.xpath('//mc:AlternateContent', ns).count
        puts "    r[#{ri}]: AC=#{ac} text=#{r.text&.text_content&.inspect}" if ac > 0 || r.text
      end
    end
  end
end

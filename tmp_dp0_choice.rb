# frozen_string_literal: true

require_relative "lib/uniword"
require "nokogiri"

dotx_path = "references/word-resources/document-elements/Cover Pages.dotx"
xml = nil
Zip::File.open(dotx_path) do |zip|
  xml = zip.find_entry("word/glossary/document.xml").get_input_stream.read
end

glossary = Uniword::Glossary::GlossaryDocument.from_xml(xml)

dp0 = glossary.doc_parts.doc_part[0]
r0 = dp0.doc_part_body.paragraphs[0].runs[0]
ac = r0.alternate_content

# Choice: wordprocessing_group shapes
choice = ac.choice
wpg = choice.drawing.anchor.graphic.graphic_data.wordprocessing_group
puts "=== Choice wpg shapes ==="
puts "Shapes count: #{wpg.shapes.count}"
wpg.shapes.each_with_index do |s, i|
  puts "  Shape[#{i}]: #{s.class}"
  if s.txbx
    tc = s.txbx.txbx_content
    if tc
      puts "    txbx_content class: #{tc.class}"
      puts "    txbx_content paragraphs: #{tc.paragraphs&.count || 0}"
      puts "    txbx_content sdts: #{tc.sdts&.count || 0}"
      tc.paragraphs&.each_with_index do |tp, tpi|
        tp.runs&.each do |tr|
          puts "    p[#{tpi}] text: #{tr.text.to_s.inspect}" if tr.text
        end
      end
      tc.sdts&.each_with_index do |sdt, si|
        sdt.content&.paragraphs&.each do |sp|
          sp.runs&.each do |sr|
            puts "    sdt[#{si}] text: #{sr.text.to_s.inspect}" if sr.text
          end
        end
      end
    end
  end
end

# Fallback: pict shapes - check what's actually there
fallback = ac.fallback
pict = fallback.pict
puts "\n=== Fallback pict ==="
puts "Pict shapes: #{pict.shapes&.count || 0}"
puts "Pict groups: #{pict.groups&.count || 0}"
puts "Pict rects: #{pict.rects&.count || 0}"

# Check the original Fallback
orig_doc = Nokogiri::XML(xml)
ns = {
  "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
  "mc" => "http://schemas.openxmlformats.org/markup-compatibility/2006"
}
orig_dp0 = orig_doc.xpath('//w:docPart', ns)[0]
orig_r0 = orig_dp0.xpath('.//w:docPartBody/w:p/w:r', ns)[0]
orig_ac = orig_r0.xpath('./mc:AlternateContent', ns)[0]
orig_fb = orig_ac.xpath('./mc:Fallback', ns)[0]

puts "\n=== Original Fallback children ==="
orig_fb.element_children.each do |child|
  pfx = child.namespace&.prefix || "none"
  puts "#{pfx}:#{child.name}"
  child.element_children.each do |gc|
    gcp = gc.namespace&.prefix || "none"
    puts "  #{gcp}:#{gc.name}"
  end
end

# Serialize the pict to see what we get
pict_xml = pict.to_xml
puts "\nPict serialized:"
puts pict_xml[0..2000]

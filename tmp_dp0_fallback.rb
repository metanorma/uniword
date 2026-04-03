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
puts "Shapes type: #{wpg.shapes.class}"
puts "Shapes count: #{wpg.shapes.count}"
wpg.shapes.each_with_index do |s, i|
  puts "  Shape[#{i}]: #{s.class}"
  if s.respond_to?(:txbx) && s.txbx
    puts "    txbx content: #{s.txbx.content.class}"
    puts "    txbx paragraphs: #{s.txbx.content.paragraphs&.count || 0}"
    puts "    txbx sdts: #{s.txbx.content.sdts&.count || 0}"
  end
end

# Fallback: pict shapes
fallback = ac.fallback
pict = fallback.pict
puts "\n=== Fallback pict ==="
puts "Pict class: #{pict.class}"
puts "Pict shapes: #{pict.shapes.class} count=#{pict.shapes&.count || 0}"
puts "Pict groups: #{pict.groups.class} count=#{pict.groups&.count || 0}"

# Check what the original Fallback looks like
orig_doc = Nokogiri::XML(xml)
ns = {
  "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
  "mc" => "http://schemas.openxmlformats.org/markup-compatibility/2006"
}
orig_dp0 = orig_doc.xpath('//w:docPart', ns)[0]
orig_p0 = orig_dp0.xpath('.//w:docPartBody/w:p', ns)[0]
orig_r0 = orig_p0.xpath('./w:r', ns)[0]
orig_ac = orig_r0.xpath('./mc:AlternateContent', ns)[0]
orig_fallback = orig_ac.xpath('./mc:Fallback', ns)[0]

puts "\n=== Original Fallback content ==="
orig_fallback.element_children.each do |child|
  pfx = child.namespace&.prefix || "none"
  puts "#{pfx}:#{child.name}"
  child.element_children.each do |gc|
    gcp = gc.namespace&.prefix || "none"
    puts "  #{gcp}:#{gc.name}"
    if gc.name == "group"
      gc.element_children.each do |ggc|
        ggcp = ggc.namespace&.prefix || "none"
        puts "    #{ggcp}:#{ggc.name}"
        if ggc.name == "shape"
          ggc.element_children.each do |gggc|
            gggcp = gggc.namespace&.prefix || "none"
            puts "      #{gggcp}:#{gggc.name}"
          end
        end
      end
    end
  end
end

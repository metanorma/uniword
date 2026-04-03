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

# DP[0] - check the model's alternate_content structure
dp0 = glossary.doc_parts.doc_part[0]
p0 = dp0.doc_part_body.paragraphs[0]
r0 = p0.runs[0]

ac = r0.alternate_content
puts "=== DP[0] p[0] r[0] alternate_content ==="
choice = ac.choice
fallback = ac.fallback

puts "Choice requires: #{choice.requires}"
puts "Choice drawing: #{choice.drawing.class}"

if choice.drawing
  anchor = choice.drawing.anchor
  if anchor
    gd = anchor.graphic.graphic_data if anchor.graphic
    if gd
      puts "Choice graphic_data uri: #{gd.uri}"
      wsp = gd.wordprocessing_shape
      if wsp
        puts "Choice wsp class: #{wsp.class}"
        txbx = wsp.txbx
        if txbx
          puts "Choice txbx content class: #{txbx.content.class}"
          puts "Choice txbx content paragraphs: #{txbx.content.paragraphs&.count || 0}"
          puts "Choice txbx content sdts: #{txbx.content.sdts&.count || 0}"
          # Get texts
          txbx.content.paragraphs&.each_with_index do |tp, tpi|
            tp.runs&.each do |tr|
              puts "Choice txbx p[#{tpi}] text: #{tr.text&.text_content&.inspect}" if tr.text
            end
          end
          txbx.content.sdts&.each_with_index do |sdt, si|
            sdt.content&.paragraphs&.each do |sp|
              sp.runs&.each do |sr|
                puts "Choice txbx sdt[#{si}] text: #{sr.text&.text_content&.inspect}" if sr.text
              end
            end
          end
        end
      end

      # Check for wordprocessing_group
      wpg = gd.wordprocessing_group
      if wpg
        puts "\nChoice wordprocessing_group: #{wpg.class}"
        # Check shapes
        wpg.class.attributes.keys.each do |attr|
          val = wpg.send(attr)
          if val
            puts "  #{attr}: #{val.class}"
          end
        end
      end
    end
  end
end

puts "\n=== Fallback ==="
if fallback
  puts "Fallback class: #{fallback.class}"
  puts "Fallback pict: #{fallback.pict.class}" if fallback.pict
  if fallback.pict
    puts "Fallback pict shapes: #{fallback.pict.shapes&.count || 0}"
    fallback.pict.shapes&.each_with_index do |shape, si|
      puts "Shape[#{si}] class: #{shape.class}"
      if shape.textbox
        puts "Shape[#{si}] textbox: #{shape.textbox.class}"
        content = shape.textbox.content
        if content
          puts "Shape[#{si}] textbox content paragraphs: #{content.paragraphs&.count || 0}"
          puts "Shape[#{si}] textbox content sdts: #{content.sdts&.count || 0}"
          content.paragraphs&.each_with_index do |tp, tpi|
            tp.runs&.each do |tr|
              puts "Shape[#{si}] txbx p[#{tpi}] text: #{tr.text&.text_content&.inspect}" if tr.text
            end
          end
          content.sdts&.each_with_index do |sdt, si2|
            sdt.content&.paragraphs&.each do |sp|
              sp.runs&.each do |sr|
                puts "Shape[#{si}] txbx sdt[#{si2}] text: #{sr.text&.text_content&.inspect}" if sr.text
              end
            end
          end
        end
      end
    end
  end
end

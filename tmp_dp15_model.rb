# frozen_string_literal: true

require_relative "lib/uniword"
require "nokogiri"

dotx_path = "references/word-resources/document-elements/Cover Pages.dotx"
xml = nil
Zip::File.open(dotx_path) do |zip|
  xml = zip.find_entry("word/glossary/document.xml").get_input_stream.read
end

glossary = Uniword::Glossary::GlossaryDocument.from_xml(xml)

dp15 = glossary.doc_parts.doc_part[15]
body = dp15.doc_part_body

puts "=== DocPart[15] deserialized ==="
puts "paragraphs: #{body.paragraphs&.count || 0}"

body.paragraphs.each_with_index do |para, pi|
  puts "\np[#{pi}]:"
  puts "  runs: #{para.runs&.count || 0}"
  para.runs&.each_with_index do |r, ri|
    puts "  r[#{ri}]: class=#{r.class}"
    puts "    text: #{r.text&.text_content&.inspect}" if r.text
    ac = r.alternate_content
    if ac
      choice = ac.choice
      fallback = ac.fallback
      puts "    alternate_content: choice=#{choice.class} fallback=#{fallback.class}"
      if choice&.drawing
        anchor = choice.drawing.anchor
        if anchor
          puts "      anchor graphic: #{anchor.graphic.class}"
          gd = anchor.graphic.graphic_data if anchor.graphic
          if gd
            puts "      graphic_data uri: #{gd.uri}"
          end
        end
      end
    end
  end
end

# Serialize and check
ser_xml = body.to_xml
puts "\n=== Serialized ==="
puts ser_xml[0..2000]

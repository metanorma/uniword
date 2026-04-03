# frozen_string_literal: true

require_relative "lib/uniword"
require "nokogiri"

dotx_path = "references/word-resources/document-elements/Cover Pages.dotx"
xml = nil
Zip::File.open(dotx_path) do |zip|
  xml = zip.find_entry("word/glossary/document.xml").get_input_stream.read
end

glossary = Uniword::Glossary::GlossaryDocument.from_xml(xml)

dp1 = glossary.doc_parts.doc_part[1]
p0 = dp1.doc_part_body.paragraphs[0]
r0 = p0.runs[0]

ac = r0.alternate_content
choice = ac.choice
drawing = choice.drawing

# Check what's inside the graphic
graphic = drawing.anchor.graphic
puts "Graphic class: #{graphic.class}"
puts "Graphic attributes: #{graphic.class.attributes.keys.sort.join(', ')}"

# Check graphic_data
graphic_data = graphic.graphic_data
puts "\nGraphicData class: #{graphic_data.class}"
puts "GraphicData attributes: #{graphic_data.class.attributes.keys.sort.join(', ')}"

if graphic_data
  puts "GraphicData uri: #{graphic_data.uri}"
  # Check what content it has
  graphic_data.class.attributes.keys.each do |attr|
    val = graphic_data.send(attr)
    if val
      puts "  #{attr}: #{val.class} = #{val.inspect[0..200]}"
    end
  end
end

# Serialize graphic_data to see what we get
if graphic_data
  gd_xml = graphic_data.to_xml
  puts "\nGraphicData serialized:"
  puts gd_xml[0..1000]
end

# frozen_string_literal: true

require_relative "lib/uniword"
require "nokogiri"

dotx_path = "references/word-resources/document-elements/Cover Pages.dotx"
xml = nil
Zip::File.open(dotx_path) do |zip|
  xml = zip.find_entry("word/glossary/document.xml").get_input_stream.read
end

glossary = Uniword::Glossary::GlossaryDocument.from_xml(xml)

# Get DocPart[1], paragraph[0], run[0]'s alternate_content
dp1 = glossary.doc_parts.doc_part[1]
p0 = dp1.doc_part_body.paragraphs[0]
r0 = p0.runs[0]

ac = r0.alternate_content
puts "=== Run[0] alternate_content ==="
puts "Class: #{ac.class}"

# Check Choice and Fallback
choice = ac.choice
fallback = ac.fallback
puts "Choice class: #{choice.class}"
puts "Choice requires: #{choice.requires}" if choice
puts "Choice drawing: #{choice.drawing.class}" if choice && choice.drawing

if choice&.drawing
  anchor = choice.drawing.anchor
  if anchor
    puts "\nAnchor:"
    puts "  position_h: #{anchor.position_h.class}" if anchor.position_h
    puts "  position_v: #{anchor.position_v.class}" if anchor.position_v
    puts "  graphic: #{anchor.graphic.class}" if anchor.graphic

    # Serialize anchor to see what we get
    anchor_xml = anchor.to_xml
    puts "\nAnchor serialized:"
    puts anchor_xml[0..1500]
  end
end

# Check fallback
puts "\nFallback: #{fallback.class}" if fallback
if fallback
  puts "Fallback pict: #{fallback.pict.class}" if fallback.pict
  if fallback.pict
    puts "Fallback pict shapes: #{fallback.pict.shapes&.count || 0}"
    if fallback.pict.shapes&.any?
      shape = fallback.pict.shapes[0]
      puts "Shape[0] textbox: #{shape.textbox.class}" if shape.textbox
    end
  end
end

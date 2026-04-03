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
  "mc" => "http://schemas.openxmlformats.org/markup-compatibility/2006",
  "wp" => "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
}

# For each docPart, count:
# 1. AC inside runs (direct) - these should survive
# 2. AC inside wp:anchor (nested) - these are lost
# 3. AC as direct children of docPartBody (not inside p/sdt)
puts "DocPart | Orig AC | Direct-in-run | In-anchor | Body-direct | Ser AC | Lost"
puts "-" * 80

orig_doc.xpath('//w:docPart', ns).each_with_index do |orig_dp, i|
  orig_body = orig_dp.xpath('.//w:docPartBody', ns).first
  next unless orig_body

  orig_ac_total = orig_body.xpath('.//mc:AlternateContent', ns).count
  ac_in_runs = orig_body.xpath('.//w:r/mc:AlternateContent', ns).count
  ac_in_anchor = orig_body.xpath('.//wp:anchor/mc:AlternateContent', ns).count
  ac_body_direct = orig_body.xpath('./mc:AlternateContent', ns).count +
                   orig_body.xpath('./w:p/mc:AlternateContent', ns).count +
                   orig_body.xpath('./w:sdt/mc:AlternateContent', ns).count

  # Serialize and count
  dp = glossary.doc_parts.doc_part[i]
  body = dp.doc_part_body
  ser_xml = body.to_xml
  ser_doc = Nokogiri::XML(ser_xml)
  ser_ac = ser_doc.xpath('.//mc:AlternateContent', ns).count

  lost = orig_ac_total - ser_ac
  next if lost == 0

  printf "DP[%2d]  | %7d | %13d | %9d | %11d | %6d | %d\n",
    i, orig_ac_total, ac_in_runs, ac_in_anchor, ac_body_direct, ser_ac, lost
end

# Now check: are there AC elements that are NOT inside runs or anchors?
puts "\n=== AC location breakdown (total across all docParts) ==="
total_ac = orig_doc.xpath('//mc:AlternateContent', ns).count
ac_in_runs = orig_doc.xpath('//w:r/mc:AlternateContent', ns).count
ac_in_anchor = orig_doc.xpath('//wp:anchor/mc:AlternateContent', ns).count
ac_in_txbx = orig_doc.xpath('//w:txbxContent//mc:AlternateContent', ns).count
ac_other = total_ac - ac_in_runs - ac_in_anchor

puts "Total AC: #{total_ac}"
puts "AC inside w:r: #{ac_in_runs}"
puts "AC inside wp:anchor: #{ac_in_anchor}"
puts "AC inside txbxContent: #{ac_in_txbx}"
puts "AC other (body/p/sdt direct): #{ac_other}"

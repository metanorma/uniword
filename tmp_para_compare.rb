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
  "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
}

# Compare original paragraph count vs deserialized for each docPart
puts "DocPart | Orig p | Deser p | Orig r | Deser r"
puts "-" * 50
orig_doc.xpath('//w:docPart', ns).each_with_index do |orig_dp, i|
  orig_body = orig_dp.xpath('.//w:docPartBody', ns).first
  orig_p = orig_body&.xpath('./w:p', ns)&.count || 0
  orig_r = orig_body&.xpath('.//w:r', ns)&.count || 0

  dp = glossary.doc_parts.doc_part[i]
  body = dp&.doc_part_body
  deser_p = body&.paragraphs&.count || 0
  deser_r = 0
  body&.paragraphs&.each { |p| deser_r += p.runs&.count || 0 }

  flag = orig_p != deser_p ? " <-- MISMATCH" : ""
  printf "DP[%2d]  | %6d | %7d | %6d | %7d%s\n", i, orig_p, deser_p, orig_r, deser_r, flag
end

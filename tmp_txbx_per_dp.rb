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

# Full roundtrip
roundtrip_xml = glossary.to_xml
rdoc = Nokogiri::XML(roundtrip_xml)
orig_doc = Nokogiri::XML(xml)

# For each docPart, compare txbxContent text
puts "DocPart | Orig txbx texts | RT txbx texts | Missing"
puts "-" * 60
orig_doc.xpath('//w:docPart', ns).each_with_index do |orig_dp, i|
  orig_body = orig_dp.xpath('.//w:docPartBody', ns).first
  next unless orig_body

  orig_texts = orig_body.xpath('.//w:txbxContent//w:t', ns).map(&:text)

  # Get the corresponding docPart from roundtrip
  rt_dp = rdoc.xpath('//w:docPart', ns)[i]
  next unless rt_dp
  rt_body = rt_dp.xpath('.//w:docPartBody', ns).first
  rt_texts = rt_body&.xpath('.//w:txbxContent//w:t', ns)&.map(&:text) || []

  next if orig_texts.empty? && rt_texts.empty?
  next if orig_texts.sort == rt_texts.sort

  missing = orig_texts.dup
  rt_texts.each { |t| idx = missing.index(t); missing.delete_at(idx) if idx }

  printf "DP[%2d]  | %15d | %13d | %d missing\n",
    i, orig_texts.count, rt_texts.count, missing.count

  if missing.any?
    puts "  Missing: #{missing.uniq.map(&:inspect).join(', ')}"
  end
end

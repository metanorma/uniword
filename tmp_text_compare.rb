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

# Count txbxContent texts
orig_texts = orig_doc.xpath('//w:txbxContent//w:t', ns).map(&:text)
rt_texts = rdoc.xpath('//w:txbxContent//w:t', ns).map(&:text)

puts "Original txbxContent texts: #{orig_texts.count}"
puts "Roundtrip txbxContent texts: #{rt_texts.count}"

missing = orig_texts.dup
rt_texts.each { |t| idx = missing.index(t); missing.delete_at(idx) if idx }
puts "\nMissing texts from txbxContent: #{missing.count}"
missing.uniq.each { |t| puts "  #{t.inspect} (appears #{orig_texts.count(t)}x)" }

# Also check total w:t texts
orig_all = orig_doc.xpath('//w:t', ns).map(&:text)
rt_all = rdoc.xpath('//w:t', ns).map(&:text)
puts "\nTotal original w:t: #{orig_all.count}"
puts "Total roundtrip w:t: #{rt_all.count}"

missing_all = orig_all.dup
rt_all.each { |t| idx = missing_all.index(t); missing_all.delete_at(idx) if idx }
puts "Missing total: #{missing_all.count}"
missing_all.uniq.each { |t| puts "  #{t.inspect} (appears #{orig_all.count(t)}x)" }

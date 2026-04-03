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

# DP[0] detailed comparison
orig_dp0 = orig_doc.xpath('//w:docPart', ns)[0]
orig_body0 = orig_dp0.xpath('.//w:docPartBody', ns).first
rt_dp0 = rdoc.xpath('//w:docPart', ns)[0]
rt_body0 = rt_dp0.xpath('.//w:docPartBody', ns).first

orig_texts = orig_body0.xpath('.//w:txbxContent//w:t', ns).map(&:text)
rt_texts = rt_body0.xpath('.//w:txbxContent//w:t', ns).map(&:text)

puts "=== DP[0] txbxContent texts ==="
puts "Original: #{orig_texts.inspect}"
puts "Roundtrip: #{rt_texts.inspect}"

missing = orig_texts.dup
rt_texts.each { |t| idx = missing.index(t); missing.delete_at(idx) if idx }
puts "Missing: #{missing.inspect}"

# Find where the missing texts live in the original
missing.uniq.each do |mt|
  puts "\n=== #{mt.inspect} ==="
  orig_body0.xpath(".//w:txbxContent//w:t[contains(., #{mt.inspect})]", ns).each do |t|
    # Walk up to show the path
    path = []
    node = t
    while node.parent && node.parent.is_a?(Nokogiri::XML::Element)
      node = node.parent
      pfx = node.namespace&.prefix || "none"
      path << "#{pfx}:#{node.name}"
      break if node.name == "docPartBody"
    end
    puts "  Path: #{path.join(' > ')}"
  end
end

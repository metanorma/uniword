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

roundtrip_xml = glossary.to_xml
rdoc = Nokogiri::XML(roundtrip_xml)
orig_doc = Nokogiri::XML(xml)

# DP[17] detailed comparison
orig_dp = orig_doc.xpath('//w:docPart', ns)[17]
orig_body = orig_dp.xpath('.//w:docPartBody', ns).first
rt_dp = rdoc.xpath('//w:docPart', ns)[17]
rt_body = rt_dp.xpath('.//w:docPartBody', ns).first

orig_texts = orig_body.xpath('.//w:txbxContent//w:t', ns).map(&:text)
rt_texts = rt_body.xpath('.//w:txbxContent//w:t', ns).map(&:text)

puts "=== DP[17] txbxContent texts ==="
puts "Original: #{orig_texts.inspect}"
puts "Roundtrip: #{rt_texts.inspect}"

missing = orig_texts.dup
rt_texts.each { |t| idx = missing.index(t); missing.delete_at(idx) if idx }
puts "Missing: #{missing.inspect}"

# Check what VML elements are in DP[17]
vml_ns = 'urn:schemas-microsoft-com:vml'
groups = orig_body.xpath('.//v:group', 'v' => vml_ns)
groups.each_with_index do |group, gi|
  puts "\nGroup[#{gi}] children:"
  group.element_children.each_with_index do |child, ci|
    pfx = child.namespace&.prefix || "none"
    has_txbx = child.xpath('.//w:txbxContent', ns).any?
    texts = child.xpath('.//w:t', ns).map(&:text)
    puts "  [#{ci}] #{pfx}:#{child.name} txbx=#{has_txbx} texts=#{texts.map(&:inspect).join(', ')}"
  end
end

# Also check for v:rect directly (not inside group)
rects = orig_body.xpath('.//v:rect', 'v' => vml_ns)
puts "\nv:rect count: #{rects.count}"
rects.each_with_index do |rect, i|
  texts = rect.xpath('.//w:t', ns).map(&:text)
  puts "  rect[#{i}] texts: #{texts.map(&:inspect).join(', ')}"
end

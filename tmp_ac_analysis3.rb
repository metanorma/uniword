# frozen_string_literal: true

require_relative "lib/uniword"
require "nokogiri"

dotx_path = "references/word-resources/document-elements/Cover Pages.dotx"
xml = nil
Zip::File.open(dotx_path) do |zip|
  xml = zip.find_entry("word/glossary/document.xml").get_input_stream.read
end

doc = Nokogiri::XML(xml)
ns = {
  "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
  "mc" => "http://schemas.openxmlformats.org/markup-compatibility/2006"
}

# Parse and roundtrip
glossary = Uniword::Glossary::GlossaryDocument.from_xml(xml)
roundtrip = glossary.to_xml
rdoc = Nokogiri::XML(roundtrip)

# Find the missing texts in original
orig_texts = doc.xpath("//w:t", ns).map(&:text)
rt_texts = rdoc.xpath("//w:t", ns).map(&:text)

missing = orig_texts.dup
rt_texts.each { |t| idx = missing.index(t); missing.delete_at(idx) if idx }

# For each missing text, find its location in original XML
missing.uniq.each do |missing_text|
  puts "\n=== Missing: #{missing_text.inspect} ==="
  doc.xpath("//w:t[contains(., #{missing_text.inspect})]", ns).each do |t|
    # Walk up and show the full chain
    chain = []
    node = t.parent
    while node.is_a?(Nokogiri::XML::Element)
      pfx = node.namespace&.prefix || "none"
      attrs = node.attributes.map { |k, v| "#{k}=#{v.value.inspect}" }.join(" ")
      label = "#{pfx}:#{node.name}"
      label += "[#{attrs}]" unless attrs.empty?
      chain << label
      node = node.parent
      break if node.name == "glossaryDocument"
    end
    puts "  Chain: #{chain.join(' <- ')}"
  end
end

# Now check: what does txbxContent look like in original vs roundtrip?
puts "\n=== txbxContent comparison ==="
orig_txbx = doc.xpath("//w:txbxContent", ns)
rt_txbx = rdoc.xpath("//w:txbxContent", ns)
puts "Original txbxContent count: #{orig_txbx.count}"
puts "Roundtrip txbxContent count: #{rt_txbx.count}"

# Show structure of each txbxContent
orig_txbx.each_with_index do |tc, i|
  children = tc.element_children.map { |c|
    pfx = c.namespace&.prefix || "none"
    "#{pfx}:#{c.name}"
  }
  texts = tc.xpath(".//w:t", ns).map(&:text)
  puts "  Original txbxContent[#{i}]: children=#{children.join(', ')}, texts=#{texts.map(&:inspect).join(', ')}"
end

rt_txbx.each_with_index do |tc, i|
  children = tc.element_children.map { |c|
    pfx = c.namespace&.prefix || "none"
    "#{pfx}:#{c.name}"
  }
  texts = tc.xpath(".//w:t", ns).map(&:text)
  puts "  Roundtrip txbxContent[#{i}]: children=#{children.join(', ')}, texts=#{texts.map(&:inspect).join(', ')}"
end

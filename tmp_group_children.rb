# frozen_string_literal: true

require_relative "lib/uniword"
require "nokogiri"

dotx_path = "references/word-resources/document-elements/Cover Pages.dotx"
xml = nil
Zip::File.open(dotx_path) do |zip|
  xml = zip.find_entry("word/glossary/document.xml").get_input_stream.read
end

orig_doc = Nokogiri::XML(xml)
ns = {
  "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
  "mc" => "http://schemas.openxmlformats.org/markup-compatibility/2006"
}

# Get DP[0] Fallback v:group children
orig_dp0 = orig_doc.xpath('//w:docPart', ns)[0]
orig_r0 = orig_dp0.xpath('.//w:docPartBody/w:p/w:r', ns)[0]
orig_ac = orig_r0.xpath('./mc:AlternateContent', ns)[0]
orig_fb = orig_ac.xpath('./mc:Fallback', ns)[0]
orig_pict = orig_fb.xpath('./w:pict', ns).first
orig_group = orig_pict.xpath('./v:group', 'v' => 'urn:schemas-microsoft-com:vml').first

puts "=== Original Fallback v:group children ==="
orig_group.element_children.each_with_index do |child, i|
  pfx = child.namespace&.prefix || "none"
  has_txbx = child.xpath('.//w:txbxContent', ns).any?
  texts = child.xpath('.//w:t', ns).map(&:text)
  puts "  [#{i}] #{pfx}:#{child.name} txbx=#{has_txbx} texts=#{texts.map(&:inspect).join(', ')}"
end

# Check if v:group has rect children
rects = orig_group.xpath('./v:rect', 'v' => 'urn:schemas-microsoft-com:vml')
puts "\nv:rect children: #{rects.count}"
rects.each_with_index do |rect, i|
  texts = rect.xpath('.//w:t', ns).map(&:text)
  puts "  rect[#{i}] texts: #{texts.map(&:inspect).join(', ')}"
end

# Check v:shape children
shapes = orig_group.xpath('./v:shape', 'v' => 'urn:schemas-microsoft-com:vml')
puts "\nv:shape children: #{shapes.count}"
shapes.each_with_index do |shape, i|
  texts = shape.xpath('.//w:t', ns).map(&:text)
  puts "  shape[#{i}] texts: #{texts.map(&:inspect).join(', ')}"
end

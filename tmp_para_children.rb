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

dp1 = orig_doc.xpath('//w:docPart', ns)[1]
body1 = dp1.xpath('.//w:docPartBody', ns).first

# Check each paragraph's direct children
body1.xpath('./w:p', ns).each_with_index do |para, pi|
  puts "\n=== Paragraph[#{pi}] ==="
  puts "Direct children:"
  para.element_children.each_with_index do |child, ci|
    pfx = child.namespace&.prefix || "none"
    if child.name == "AlternateContent"
      texts = child.xpath('.//w:t', ns).map(&:text)
      puts "  [#{ci}] #{pfx}:#{child.name} (texts: #{texts.map(&:inspect).join(', ')})"
    elsif child.name == "r"
      texts = child.xpath('.//w:t', ns).map(&:text)
      puts "  [#{ci}] #{pfx}:#{child.name} (text: #{texts.map(&:inspect).join(', ')})"
    else
      puts "  [#{ci}] #{pfx}:#{child.name}"
    end
  end

  ac_count = para.xpath('./mc:AlternateContent', ns).count
  r_count = para.xpath('./w:r', ns).count
  puts "Direct AC children: #{ac_count}"
  puts "Direct r children: #{r_count}"
end

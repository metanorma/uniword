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

# Find DocPart[1] which has the biggest loss (16 -> 6)
dp1 = orig_doc.xpath('//w:docPart', ns)[1]
body1 = dp1.xpath('.//w:docPartBody', ns).first

puts "=== DocPart[1] structure ==="
body1.element_children.each_with_index do |child, i|
  pfx = child.namespace&.prefix || "none"
  if child.name == "AlternateContent"
    puts "  [#{i}] #{pfx}:#{child.name}"
    child.element_children.each do |c|
      puts "    #{c.name}"
      c.element_children.each do |gc|
        gcp = gc.namespace&.prefix || "none"
        puts "      #{gcp}:#{gc.name}"
      end
    end
  else
    puts "  [#{i}] #{pfx}:#{child.name}"
  end
end

# How many AC are direct children of docPartBody?
puts "\nDirect AC children of docPartBody: #{body1.xpath('./mc:AlternateContent', ns).count}"

# How many AC are inside paragraphs?
puts "AC inside paragraphs: #{body1.xpath('.//w:p//mc:AlternateContent', ns).count}"

# Check: are there AC elements that are siblings of paragraphs?
puts "AC siblings of p: #{body1.xpath('./mc:AlternateContent[preceding-sibling::w:p or following-sibling::w:p]', ns).count}"

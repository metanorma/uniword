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
p0 = body1.xpath('./w:p', ns)[0]

# Look at run[0] AC structure in detail
r0 = p0.xpath('./w:r', ns)[0]
ac0 = r0.xpath('./mc:AlternateContent', ns)[0]

puts "=== Run[0] top-level AC ==="
puts ac0.to_xml[0..2000]

puts "\n=== Nested AC inside wp:anchor ==="
ac0.xpath('.//mc:AlternateContent', ns).each_with_index do |nested_ac, i|
  puts "\nNested AC[#{i}]:"
  puts "  Parent: #{nested_ac.parent.namespace&.prefix}:#{nested_ac.parent.name}"
  nested_ac.element_children.each do |child|
    puts "  #{child.name}:"
    child.element_children.each do |gc|
      gcp = gc.namespace&.prefix || "none"
      puts "    #{gcp}:#{gc.name}"
    end
  end
end

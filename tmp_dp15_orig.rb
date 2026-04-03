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

# DocPart[15] full XML
orig_dp = orig_doc.xpath('//w:docPart', ns)[15]
orig_body = orig_dp.xpath('.//w:docPartBody', ns).first
puts "=== DocPart[15] original ==="
puts orig_body.to_xml

puts "\n\n=== DocPart[16] original ==="
orig_dp16 = orig_doc.xpath('//w:docPart', ns)[16]
orig_body16 = orig_dp16.xpath('.//w:docPartBody', ns).first
puts orig_body16.to_xml

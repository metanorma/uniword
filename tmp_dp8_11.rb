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

[8, 11].each do |dp_idx|
  puts "\n=== DP[#{dp_idx}] ==="
  orig_dp = orig_doc.xpath('//w:docPart', ns)[dp_idx]
  orig_body = orig_dp.xpath('.//w:docPartBody', ns).first

  orig_texts = orig_body.xpath('.//w:txbxContent//w:t', ns).map(&:text)
  puts "Original txbxContent texts: #{orig_texts.map(&:inspect).join(', ')}"

  # Find the Fallback paths
  orig_body.xpath('.//mc:Fallback', ns).each_with_index do |fb, fi|
    fb_texts = fb.xpath('.//w:t', ns).map(&:text)
    puts "  Fallback[#{fi}] texts: #{fb_texts.map(&:inspect).join(', ')}"

    # Check what VML elements are in this Fallback
    fb.element_children.each do |child|
      pfx = child.namespace&.prefix || "none"
      puts "    #{pfx}:#{child.name}"
      child.element_children.each do |gc|
        gcp = gc.namespace&.prefix || "none"
        gc_texts = gc.xpath('.//w:t', ns).map(&:text)
        puts "      #{gcp}:#{gc.name} texts=#{gc_texts.map(&:inspect).join(', ')}"
      end
    end
  end
end

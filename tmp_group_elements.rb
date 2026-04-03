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

vml_ns = 'urn:schemas-microsoft-com:vml'

[0, 8, 11].each do |dp_idx|
  puts "\n=== DP[#{dp_idx}] v:group children ==="
  orig_dp = orig_doc.xpath('//w:docPart', ns)[dp_idx]
  orig_body = orig_dp.xpath('.//w:docPartBody', ns).first

  groups = orig_body.xpath('.//v:group', 'v' => vml_ns)
  groups.each_with_index do |group, gi|
    puts "  Group[#{gi}]:"
    group.element_children.each_with_index do |child, ci|
      pfx = child.namespace&.prefix || "none"
      has_txbx = child.xpath('.//w:txbxContent', ns).any?
      texts = child.xpath('.//w:t', ns).map(&:text)
      puts "    [#{ci}] #{pfx}:#{child.name} txbx=#{has_txbx} texts=#{texts.map(&:inspect).join(', ')}"
    end
  end
end

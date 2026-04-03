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

# For each run, count direct AC and nested AC
p0.xpath('./w:r', ns).each_with_index do |r, ri|
  direct_ac = r.xpath('./mc:AlternateContent', ns).count
  nested_ac = r.xpath('.//mc:AlternateContent', ns).count
  if nested_ac > direct_ac
    puts "Run[#{ri}]: direct AC=#{direct_ac}, nested AC=#{nested_ac} (#{nested_ac - direct_ac} nested)"
    # Show where the nested ones are
    r.xpath('.//mc:AlternateContent', ns).each_with_index do |ac, ai|
      ancestors = ac.ancestors.select { |a| a.is_a?(Nokogiri::XML::Element) }.map { |a| "#{a.namespace&.prefix}:#{a.name}" }
      # Only show if not directly under run
      if ac.parent != r
        puts "  AC[#{ai}]: parent=#{ac.parent.namespace&.prefix}:#{ac.parent.name}"
      end
    end
  else
    puts "Run[#{ri}]: direct AC=#{direct_ac}, nested AC=#{nested_ac}"
  end
end

# Total breakdown
puts "\nTotal AC in paragraph: #{p0.xpath('.//mc:AlternateContent', ns).count}"
puts "Direct AC under paragraph: #{p0.xpath('./mc:AlternateContent', ns).count}"
puts "AC directly under runs: #{p0.xpath('./w:r/mc:AlternateContent', ns).count}"
puts "AC nested deeper in runs: #{p0.xpath('./w:r//mc:AlternateContent[not(parent::w:r)]', ns).count}"

# Check if any AC are inside txbxContent (nested drawings)
puts "\nAC inside txbxContent: #{p0.xpath('.//w:txbxContent//mc:AlternateContent', ns).count}"

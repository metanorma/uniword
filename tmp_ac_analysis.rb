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

# Count parent types
parent_counts = Hash.new(0)
doc.xpath("//mc:AlternateContent", ns).each do |ac|
  parent = ac.parent
  pfx = parent.namespace&.prefix || "none"
  parent_counts["#{pfx}:#{parent.name}"] += 1
end
puts "=== AlternateContent parent distribution ==="
parent_counts.sort_by { |_, v| -v }.each { |k, v| puts "  #{k}: #{v}" }

# Check if any AC are inside sdtContent
ac_in_sdt = doc.xpath(".//w:sdtContent//mc:AlternateContent", ns).count
puts "\nAC inside sdtContent: #{ac_in_sdt}"

# Check AC inside txbxContent
ac_in_txbx = doc.xpath(".//w:txbxContent//mc:AlternateContent", ns).count
puts "AC inside txbxContent: #{ac_in_txbx}"

# Check AC inside docPartBody directly
ac_in_body = doc.xpath(".//w:docPartBody/mc:AlternateContent", ns).count
puts "AC direct child of docPartBody: #{ac_in_body}"

# Find paragraphs that contain AC (at any depth)
para_with_ac = doc.xpath(".//w:p[.//mc:AlternateContent]", ns).count
puts "Paragraphs containing AC: #{para_with_ac}"

# Look at the structure of a specific missing text
puts "\n=== Looking for [Author name] patterns ==="
doc.xpath("//w:t[contains(., 'Author')]", ns).each_with_index do |t, i|
  ancestors = t.ancestors.map { |a|
    pfx = a.namespace&.prefix || "none"
    "#{pfx}:#{a.name}"
  }
  puts "Text #{i}: #{t.text.inspect}"
  puts "  Chain: #{ancestors.join(' > ')}"
end

# Check: are there AC elements inside paragraphs as siblings of runs?
puts "\n=== Paragraph children analysis ==="
sample_para = doc.xpath("//w:p[.//mc:AlternateContent]", ns).first
if sample_para
  sample_para.element_children.each do |child|
    pfx = child.namespace&.prefix || "none"
    puts "  #{pfx}:#{child.name}"
    if child.name == "AlternateContent"
      choice = child.element_children.find { |c| c.name == "Choice" }
      fallback = child.element_children.find { |c| c.name == "Fallback" }
      if choice
        choice.element_children.each { |c| puts "    Choice > #{c.namespace&.prefix}:#{c.name}"
        }
      end
      if fallback
        fallback.element_children.each { |c| puts "    Fallback > #{c.namespace&.prefix}:#{c.name}" }
      end
    end
  end
end

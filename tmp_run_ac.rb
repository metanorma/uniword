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

# Check run[0] - has [Author name] texts
p0 = body1.xpath('./w:p', ns)[0]
r0 = p0.xpath('./w:r', ns)[0]

puts "=== DocPart[1] p[0] r[0] children ==="
r0.element_children.each_with_index do |child, ci|
  pfx = child.namespace&.prefix || "none"
  puts "  [#{ci}] #{pfx}:#{child.name}"
  if child.name == "AlternateContent"
    child.element_children.each do |c|
      puts "    #{c.name}"
      c.element_children.each do |gc|
        gcp = gc.namespace&.prefix || "none"
        puts "      #{gcp}:#{gc.name}"
        if gc.name == "drawing"
          gc.element_children.each do |ggc|
            ggcp = ggc.namespace&.prefix || "none"
            puts "        #{ggcp}:#{ggc.name}"
          end
        end
      end
    end
  end
end

# Count AC inside each run
puts "\n=== AC count per run ==="
p0.xpath('./w:r', ns).each_with_index do |r, ri|
  ac_count = r.xpath('./mc:AlternateContent', ns).count
  texts = r.xpath('.//w:t', ns).map(&:text).uniq
  puts "  Run[#{ri}]: AC=#{ac_count} texts=#{texts.map(&:inspect).join(', ')}"
end

# Total AC count
puts "\nTotal AC in paragraph[0]: #{p0.xpath('.//mc:AlternateContent', ns).count}"

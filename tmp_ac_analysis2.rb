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

# Show the full parent chain for each AC whose direct parent is wp:anchor
doc.xpath("//mc:AlternateContent", ns).each_with_index do |ac, i|
  parent = ac.parent
  next unless parent.name == "anchor"

  # Show full ancestor chain
  chain = []
  node = ac
  while node.parent && node.parent.is_a?(Nokogiri::XML::Element)
    node = node.parent
    pfx = node.namespace&.prefix || "none"
    chain << "#{pfx}:#{node.name}"
  end
  puts "AC[#{i}] under wp:anchor:"
  puts "  Chain: #{chain.join(' > ')}"

  # Show the Choice and Fallback content
  ac.element_children.each do |child|
    puts "  Child: #{child.name}"
    child.element_children.each do |gc|
      gc_pfx = gc.namespace&.prefix || "none"
      puts "    #{gc_pfx}:#{gc.name}"
      # Show deeper
      gc.element_children.each do |ggc|
        ggc_pfx = ggc.namespace&.prefix || "none"
        puts "      #{ggc_pfx}:#{ggc.name}"
      end
    end
  end

  # Get texts inside this AC
  texts = ac.xpath(".//w:t", ns).map(&:text)
  puts "  Texts: #{texts.map(&:inspect).join(', ')}" if texts.any?
  puts
end

# Now look at a sample paragraph that has AC
puts "\n=== Sample paragraphs with AC ==="
doc.xpath(".//w:p[.//mc:AlternateContent]", ns).first(3).each_with_index do |para, i|
  puts "\nParagraph #{i}:"
  para.element_children.each do |child|
    pfx = child.namespace&.prefix || "none"
    if child.name == "AlternateContent"
      texts = child.xpath(".//w:t", ns).map(&:text)
      puts "  #{pfx}:#{child.name} (texts: #{texts.map(&:inspect).join(', ')})"
    else
      puts "  #{pfx}:#{child.name}"
    end
  end
end

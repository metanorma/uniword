# frozen_string_literal: true

require_relative 'lib/uniword'
require 'nokogiri'

para = Uniword::Paragraph.new
para.add_tab_stop(position: 1440, alignment: 'center', leader: 'dot')

puts '=== Paragraph XML ==='
xml = para.to_xml
puts xml
puts ''

doc = Nokogiri::XML(xml)
tabs = doc.at_xpath('//w:tabs', 'w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')
puts "tabs element found: #{!tabs.nil?}"

if tabs
  puts 'tabs XML:'
  puts tabs.to_xml

  tab_elements = doc.xpath('//w:tab', 'w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')
  puts "Number of tab elements: #{tab_elements.size}"

  tab_elements.each_with_index do |tab, i|
    puts "\nTab #{i}:"
    tab.attributes.each do |name, attr|
      puts "  #{name} = #{attr.value}"
    end
  end
end

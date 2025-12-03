# frozen_string_literal: true

require_relative 'lib/uniword'

# Test Run with character spacing
run = Uniword::Run.new(text: 'Test')
run.character_spacing = 20

xml = run.to_xml
puts '=== Run XML Output ==='
puts xml
puts ''

# Parse and check attribute
require 'nokogiri'
doc = Nokogiri::XML(xml)
spacing = doc.at_xpath('//w:spacing', 'w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')
puts "=== Spacing element found: #{!spacing.nil?}"
if spacing
  puts 'Attributes:'
  spacing.attributes.each do |name, attr|
    puts "  #{name} = #{attr.value} (namespace: #{attr.namespace&.prefix})"
  end
  puts ''
  puts "Access with 'val': #{spacing['val']}"
  puts "Access with 'w:val': #{spacing['w:val']}"
end

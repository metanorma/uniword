#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'lutaml/model'

# Test Pattern 1: Single attribute element (like <w:jc w:val="center"/>)
class TestAlignment1 < Lutaml::Model::Serializable
  attribute :value, :string

  xml do
    element 'jc'
    namespace Ooxml::Namespaces::WordProcessingML
    map_attribute 'val', to: :value
  end
end

# Test Pattern 2: Try with different naming
class TestAlignment2 < Lutaml::Model::Serializable
  attribute :val, :string

  xml do
    element 'jc'
    namespace Ooxml::Namespaces::WordProcessingML
    map_attribute 'val', to: :val
  end
end

# Test Pattern 3: Font size (integer value)
class TestFontSize < Lutaml::Model::Serializable
  attribute :value, :integer

  xml do
    element 'sz'
    namespace Ooxml::Namespaces::WordProcessingML
    map_attribute 'val', to: :value
  end
end

# Test Pattern 4: Color (string value)
class TestColor < Lutaml::Model::Serializable
  attribute :value, :string

  xml do
    element 'color'
    namespace Ooxml::Namespaces::WordProcessingML
    map_attribute 'val', to: :value
  end
end

puts 'Testing Simple Element Serialization Patterns'
puts '=' * 60

# Test 1: Alignment
obj1 = TestAlignment1.new(value: 'center')
xml1 = obj1.to_xml
puts "\nPattern 1 (attribute: :value):"
puts "Object: #{obj1.inspect}"
puts 'XML Output:'
puts xml1
puts "Contains 'w:val': #{xml1.include?('w:val')}"
puts "Contains 'center': #{xml1.include?('center')}"

# Test 2: Alignment with val attribute name
obj2 = TestAlignment2.new(val: 'center')
xml2 = obj2.to_xml
puts "\nPattern 2 (attribute: :val):"
puts "Object: #{obj2.inspect}"
puts 'XML Output:'
puts xml2
puts "Contains 'w:val': #{xml2.include?('w:val')}"
puts "Contains 'center': #{xml2.include?('center')}"

# Test 3: Font Size
obj3 = TestFontSize.new(value: 32)
xml3 = obj3.to_xml
puts "\nPattern 3 (Font Size):"
puts "Object: #{obj3.inspect}"
puts 'XML Output:'
puts xml3
puts "Contains 'w:val': #{xml3.include?('w:val')}"
puts "Contains '32': #{xml3.include?('32')}"

# Test 4: Color
obj4 = TestColor.new(value: 'FF0000')
xml4 = obj4.to_xml
puts "\nPattern 4 (Color):"
puts "Object: #{obj4.inspect}"
puts 'XML Output:'
puts xml4
puts "Contains 'w:val': #{xml4.include?('w:val')}"
puts "Contains 'FF0000': #{xml4.include?('FF0000')}"

# Test round-trip
puts "\n#{'=' * 60}"
puts 'Testing Round-Trip'
puts '=' * 60

xml_input = '<w:jc w:val="center" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"/>'
puts "\nInput XML: #{xml_input}"
reparsed = TestAlignment1.from_xml(xml_input)
puts "Reparsed value: #{reparsed.value}"
puts "Re-serialized: #{reparsed.to_xml}"

puts "\n#{'=' * 60}"
puts 'SUMMARY'
puts '=' * 60
puts 'If all tests show proper w:val attributes and values, the pattern works!'

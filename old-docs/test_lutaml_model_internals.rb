# frozen_string_literal: true

require_relative 'lib/uniword'

puts '=== Lutaml-Model Internals Debug ==='
puts

doc = Uniword::Document.new
para = Uniword::Paragraph.new
para.add_text('Test')
doc.add_element(para)

puts '1. Document class info:'
puts "   Ancestors: #{Uniword::Document.ancestors.take(5).join(', ')}"
puts "   Has _mappings?: #{Uniword::Document.respond_to?(:_mappings)}"
if Uniword::Document.respond_to?(:_mappings)
  puts "   Mappings: #{Uniword::Document._mappings.inspect}"
end
puts

puts '2. Document instance info:'
puts "   Instance variables: #{doc.instance_variables.sort}"
puts "   @body present: #{doc.instance_variable_defined?(:@body)}"
puts "   @body value: #{doc.instance_variable_get(:@body).inspect}"
puts "   body method: #{doc.body.inspect}"
puts "   body class: #{doc.body.class}"
puts "   body paragraphs: #{doc.body.paragraphs.size}"
puts

puts '3. Check if body is in serializable attributes:'
if doc.class.respond_to?(:attributes_declaration)
  puts "   attributes_declaration: #{doc.class.attributes_declaration.inspect}"
end

puts "   xml_mapping: #{doc.class.xml_mapping.inspect}" if doc.class.respond_to?(:xml_mapping)

if doc.class.respond_to?(:model_attributes)
  puts "   model_attributes: #{doc.class.model_attributes.inspect}"
end
puts

puts '4. Trying to serialize:'
xml = doc.to_xml
puts xml

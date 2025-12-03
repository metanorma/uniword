# frozen_string_literal: true

require 'lutaml/model'

class Inner < Lutaml::Model::Serializable
  xml do
    element 'inner'
    map_attribute 'value', to: :value
  end

  attribute :value, :string
end

class Outer < Lutaml::Model::Serializable
  xml do
    element 'outer'
    map_element 'inner', to: :inner_obj
  end

  attribute :inner_obj, Inner
end

# Test
outer = Outer.new(inner_obj: Inner.new(value: 'test'))
puts 'Object structure:'
puts "  outer.inner_obj = #{outer.inner_obj.inspect}"
puts "  outer.inner_obj.value = #{outer.inner_obj.value}"

puts "\nGenerated XML:"
puts outer.to_xml

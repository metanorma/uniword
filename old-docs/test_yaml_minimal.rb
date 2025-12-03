#!/usr/bin/env ruby
# frozen_string_literal: true

require 'lutaml/model'
require 'yaml'
require_relative 'lib/uniword/style'
require_relative 'lib/uniword/styleset'

# Create a simple StyleSet
styleset = Uniword::StyleSet.new(name: 'Test')
styleset.styles = [
  Uniword::Style.new(id: 'Normal', type: 'paragraph', name: 'Normal'),
  Uniword::Style.new(id: 'Heading1', type: 'paragraph', name: 'Heading 1')
]

# Test YAML serialization
yaml_str = styleset.to_yaml
File.write('/tmp/styleset_test.yml', yaml_str)
puts 'Wrote YAML to /tmp/styleset_test.yml'
puts "Size: #{yaml_str.bytesize} bytes"
puts
puts 'Content:'
puts yaml_str

# Test YAML deserialization
loaded = Uniword::StyleSet.from_yaml(yaml_str)
puts
puts 'Loaded StyleSet:'
puts "  Name: #{loaded.name}"
puts "  Styles: #{loaded.styles.count}"
loaded.styles.each { |s| puts "    - #{s.id} (#{s.type})" }

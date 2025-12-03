#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'lutaml/model'
require_relative 'lib/uniword/ooxml/namespaces'
require_relative 'lib/uniword/text_element'
require_relative 'lib/uniword/properties/run_properties'
require_relative 'lib/uniword/properties/paragraph_properties'
require_relative 'lib/uniword/properties/border'
require_relative 'lib/uniword/properties/shading'
require_relative 'lib/uniword/element'
require_relative 'lib/uniword/run'
require_relative 'lib/uniword/paragraph'

puts 'Testing basic property serialization...'
puts '=' * 60

# Test 1: Run with character spacing
puts "\n1. Run with character spacing:"
run = Uniword::Run.new(text: 'Test')
run.properties = Uniword::Properties::RunProperties.new(character_spacing: 20)
xml = run.to_xml
puts "XML: #{xml}"
puts "Contains <w:spacing>20</w:spacing>: #{xml.include?('<w:spacing>20</w:spacing>')}"

# Test 2: Properties serialize correctly
puts "\n2. Properties in isolation:"
props = Uniword::Properties::RunProperties.new(character_spacing: 20, bold: true)
props_xml = props.to_xml
puts "Properties XML: #{props_xml}"
puts "Contains spacing: #{props_xml.include?('spacing')}"

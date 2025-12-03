#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require_relative 'lib/uniword/ooxml/app_properties'

props = Uniword::Ooxml::AppProperties.new(
  template: 'Normal.dotm',
  application: 'Microsoft Office Word',
  company: ''
)

xml = props.to_xml(prefix: false)
puts '=== AppProperties XML ==='
puts xml

puts "\n=== Namespace Checks ==="
puts "Has xmlns:vt: #{xml.include?('xmlns:vt')}"
puts "Default xmlns: #{xml.include?('<Properties xmlns=')}"
puts "No prefix: #{xml.include?('<Template>')}"

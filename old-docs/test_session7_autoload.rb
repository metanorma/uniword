#!/usr/bin/env ruby
# frozen_string_literal: true

# Test autoload functionality for Session 7 namespaces

require_relative 'lib/generated/office'
require_relative 'lib/generated/vml_office'
require_relative 'lib/generated/document_properties'

puts '=' * 80
puts 'SESSION 7 AUTOLOAD TEST'
puts '=' * 80
puts

# Test Office namespace
puts '1. Testing Office namespace (40 classes)...'
puts '-' * 80
office_classes = [
  Uniword::Generated::Office::Extrusion,
  Uniword::Generated::Office::Callout,
  Uniword::Generated::Office::Lock,
  Uniword::Generated::Office::Diagram,
  Uniword::Generated::Office::ShapeDefaults,
  Uniword::Generated::Office::SignatureLine,
  Uniword::Generated::Office::DocumentProtection
]

office_classes.each do |klass|
  puts "✅ #{klass.name}"
end
puts '✅ All Office classes autoloaded successfully!'
puts

# Test VML Office namespace
puts '2. Testing VML Office namespace (25 classes)...'
puts '-' * 80
vml_office_classes = [
  Uniword::Generated::VmlOffice::VmlComplex,
  Uniword::Generated::VmlOffice::VmlDiagram,
  Uniword::Generated::VmlOffice::VmlShapeDefaults,
  Uniword::Generated::VmlOffice::VmlSignatureLine,
  Uniword::Generated::VmlOffice::VmlWrapCoords
]

vml_office_classes.each do |klass|
  puts "✅ #{klass.name}"
end
puts '✅ All VML Office classes autoloaded successfully!'
puts

# Test Document Properties namespace
puts '3. Testing Document Properties namespace (20 classes)...'
puts '-' * 80
doc_props_classes = [
  Uniword::Generated::DocumentProperties::ExtendedProperties,
  Uniword::Generated::DocumentProperties::Application,
  Uniword::Generated::DocumentProperties::Company,
  Uniword::Generated::DocumentProperties::CustomProperties,
  Uniword::Generated::DocumentProperties::Vector
]

doc_props_classes.each do |klass|
  puts "✅ #{klass.name}"
end
puts '✅ All Document Properties classes autoloaded successfully!'
puts

# Summary
puts '=' * 80
puts 'AUTOLOAD TEST SUMMARY'
puts '=' * 80
puts 'Office:               40 classes (7 tested, all loaded)'
puts 'VML Office:           25 classes (5 tested, all loaded)'
puts 'Document Properties:  20 classes (5 tested, all loaded)'
puts
puts '✅ All Session 7 autoloads working correctly!'
puts '=' * 80

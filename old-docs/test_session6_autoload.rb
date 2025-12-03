#!/usr/bin/env ruby
# frozen_string_literal: true

puts '=' * 80
puts 'SESSION 6: Testing Autoload for WP Drawing, Content Types, and VML'
puts '=' * 80
puts

# Load autoload indices
require_relative 'lib/generated/wp_drawing'
require_relative 'lib/generated/content_types'
require_relative 'lib/generated/vml'

test_results = {
  wp_drawing: { passed: 0, failed: 0, errors: [] },
  content_types: { passed: 0, failed: 0, errors: [] },
  vml: { passed: 0, failed: 0, errors: [] }
}

# Test WP Drawing classes
puts '1. Testing WP Drawing namespace autoload...'
puts '-' * 80
wp_classes = %i[
  Anchor Inline Extent EffectExtent DocPr CNvGraphicFramePr
  SimplePos PositionH PositionV Align PosOffset
  SizeRelH SizeRelV WrapSquare WrapTight WrapThrough
  WrapTopAndBottom WrapNone WrapPolygon Start LineTo
  RelativeHeight BehindDoc Locked LayoutInCell AllowOverlap Hidden
]

wp_classes.each do |class_name|
  klass = Uniword::Generated::WpDrawing.const_get(class_name)
  if klass.is_a?(Class)
    test_results[:wp_drawing][:passed] += 1
    puts "  ✅ #{class_name} loaded successfully"
  else
    test_results[:wp_drawing][:failed] += 1
    test_results[:wp_drawing][:errors] << "#{class_name} is not a class"
    puts "  ❌ #{class_name} is not a class"
  end
rescue StandardError => e
  test_results[:wp_drawing][:failed] += 1
  test_results[:wp_drawing][:errors] << "#{class_name}: #{e.message}"
  puts "  ❌ #{class_name} failed: #{e.message}"
end
puts

# Test Content Types classes
puts '2. Testing Content Types namespace autoload...'
puts '-' * 80
ct_classes = %i[Types Default Override]

ct_classes.each do |class_name|
  klass = Uniword::Generated::ContentTypes.const_get(class_name)
  if klass.is_a?(Class)
    test_results[:content_types][:passed] += 1
    puts "  ✅ #{class_name} loaded successfully"
  else
    test_results[:content_types][:failed] += 1
    test_results[:content_types][:errors] << "#{class_name} is not a class"
    puts "  ❌ #{class_name} is not a class"
  end
rescue StandardError => e
  test_results[:content_types][:failed] += 1
  test_results[:content_types][:errors] << "#{class_name}: #{e.message}"
  puts "  ❌ #{class_name} failed: #{e.message}"
end
puts

# Test VML classes
puts '3. Testing VML namespace autoload...'
puts '-' * 80
vml_classes = %i[
  Shape Rect Oval Line Polyline Curve
  Fill Stroke Path Textbox Imagedata
  Group Shapetype Formulas Handles
]

vml_classes.each do |class_name|
  klass = Uniword::Generated::Vml.const_get(class_name)
  if klass.is_a?(Class)
    test_results[:vml][:passed] += 1
    puts "  ✅ #{class_name} loaded successfully"
  else
    test_results[:vml][:failed] += 1
    test_results[:vml][:errors] << "#{class_name} is not a class"
    puts "  ❌ #{class_name} is not a class"
  end
rescue StandardError => e
  test_results[:vml][:failed] += 1
  test_results[:vml][:errors] << "#{class_name}: #{e.message}"
  puts "  ❌ #{class_name} failed: #{e.message}"
end
puts

# Test instantiation
puts '4. Testing class instantiation (sample classes)...'
puts '-' * 80
test_instantiations = [
  ['WP Drawing Anchor', -> { Uniword::Generated::WpDrawing::Anchor.new }],
  ['WP Drawing Extent', -> { Uniword::Generated::WpDrawing::Extent.new }],
  ['Content Types Types', -> { Uniword::Generated::ContentTypes::Types.new }],
  ['Content Types Default', -> { Uniword::Generated::ContentTypes::Default.new }],
  ['VML Shape', -> { Uniword::Generated::Vml::Shape.new }],
  ['VML Fill', -> { Uniword::Generated::Vml::Fill.new }]
]

instantiation_passed = 0
instantiation_failed = 0

test_instantiations.each do |name, block|
  block.call
  instantiation_passed += 1
  puts "  ✅ #{name} instantiated successfully"
rescue StandardError => e
  instantiation_failed += 1
  puts "  ❌ #{name} failed: #{e.message}"
end
puts

# Summary
puts '=' * 80
puts 'TEST SUMMARY'
puts '=' * 80
puts
puts 'WP Drawing:'
puts "  Passed: #{test_results[:wp_drawing][:passed]}/#{wp_classes.size}"
puts "  Failed: #{test_results[:wp_drawing][:failed]}/#{wp_classes.size}"
if test_results[:wp_drawing][:errors].any?
  puts '  Errors:'
  test_results[:wp_drawing][:errors].each { |e| puts "    - #{e}" }
end
puts

puts 'Content Types:'
puts "  Passed: #{test_results[:content_types][:passed]}/#{ct_classes.size}"
puts "  Failed: #{test_results[:content_types][:failed]}/#{ct_classes.size}"
if test_results[:content_types][:errors].any?
  puts '  Errors:'
  test_results[:content_types][:errors].each { |e| puts "    - #{e}" }
end
puts

puts 'VML:'
puts "  Passed: #{test_results[:vml][:passed]}/#{vml_classes.size}"
puts "  Failed: #{test_results[:vml][:failed]}/#{vml_classes.size}"
if test_results[:vml][:errors].any?
  puts '  Errors:'
  test_results[:vml][:errors].each { |e| puts "    - #{e}" }
end
puts

puts 'Instantiation Tests:'
puts "  Passed: #{instantiation_passed}/#{test_instantiations.size}"
puts "  Failed: #{instantiation_failed}/#{test_instantiations.size}"
puts

total_passed = test_results[:wp_drawing][:passed] +
               test_results[:content_types][:passed] +
               test_results[:vml][:passed] +
               instantiation_passed

total_tests = wp_classes.size + ct_classes.size + vml_classes.size + test_instantiations.size
total_failed = test_results[:wp_drawing][:failed] +
               test_results[:content_types][:failed] +
               test_results[:vml][:failed] +
               instantiation_failed

puts 'OVERALL:'
puts "  Total Passed: #{total_passed}/#{total_tests}"
puts "  Total Failed: #{total_failed}/#{total_tests}"
puts "  Success Rate: #{(total_passed.to_f / total_tests * 100).round(2)}%"
puts '=' * 80

exit(total_failed.positive? ? 1 : 0)

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/generated/spreadsheetml'

puts '=' * 80
puts 'Session 9: SpreadsheetML Autoload Test'
puts '=' * 80
puts

# Test sample SpreadsheetML classes
puts 'Testing SpreadsheetML namespace (xls:)...'
puts

sample_classes = [
  ['Workbook', 'Workbook root element'],
  ['Worksheet', 'Worksheet root element'],
  ['Cell', 'Individual cell'],
  ['Row', 'Spreadsheet row'],
  ['SharedStringTable', 'Shared string table'],
  ['CellFormats', 'Cell formats collection'],
  ['Font', 'Font definition'],
  ['Border', 'Border definition'],
  ['Table', 'Table definition'],
  ['DataValidation', 'Data validation rule'],
  ['ConditionalFormatting', 'Conditional formatting'],
  ['AutoFilter', 'Auto filter settings'],
  ['Hyperlink', 'Hyperlink definition'],
  ['Comment', 'Cell comment'],
  ['PivotTable', 'Pivot table reference']
]

success_count = 0
sample_classes.each do |class_name, description|
  Uniword::Generated::Spreadsheetml.const_get(class_name)
  puts "✅ #{class_name.ljust(25)} - #{description}"
  success_count += 1
rescue NameError => e
  puts "❌ #{class_name.ljust(25)} - FAILED: #{e.message}"
end

puts
puts '=' * 80
puts 'Test Results:'
puts "  Tested: #{sample_classes.size} classes"
puts "  Passed: #{success_count}/#{sample_classes.size}"
puts "  Success rate: #{(success_count * 100.0 / sample_classes.size).round(1)}%"
puts '=' * 80
puts

if success_count == sample_classes.size
  puts '🎉 All tests passed! SpreadsheetML namespace is working correctly.'
  exit 0
else
  puts '⚠️  Some tests failed. Please check the errors above.'
  exit 1
end

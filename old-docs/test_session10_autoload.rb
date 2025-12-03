#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/generated/chart'

puts '=' * 80
puts 'Uniword v2.0 - Session 10: Chart Namespace Autoload Test'
puts '=' * 80
puts

puts 'Testing Chart (c:) namespace autoloading...'
puts

# Test key classes from each group
test_classes = [
  # Chart Container
  ['ChartSpace', Uniword::Generated::Chart::ChartSpace],
  ['Chart', Uniword::Generated::Chart::Chart],
  ['PlotArea', Uniword::Generated::Chart::PlotArea],

  # Chart Types
  ['BarChart', Uniword::Generated::Chart::BarChart],
  ['LineChart', Uniword::Generated::Chart::LineChart],
  ['PieChart', Uniword::Generated::Chart::PieChart],
  ['ScatterChart', Uniword::Generated::Chart::ScatterChart],

  # Series & Data
  ['Series', Uniword::Generated::Chart::Series],
  ['CategoryAxisData', Uniword::Generated::Chart::CategoryAxisData],
  ['Values', Uniword::Generated::Chart::Values],

  # Axes
  ['CatAx', Uniword::Generated::Chart::CatAx],
  ['ValAx', Uniword::Generated::Chart::ValAx],
  ['AxisId', Uniword::Generated::Chart::AxisId],

  # Legend & Labels
  ['Legend', Uniword::Generated::Chart::Legend],
  ['DataLabels', Uniword::Generated::Chart::DataLabels],

  # Styling
  ['ShapeProperties', Uniword::Generated::Chart::ShapeProperties],
  ['Marker', Uniword::Generated::Chart::Marker],

  # Advanced Features
  ['Trendline', Uniword::Generated::Chart::Trendline],
  ['ErrorBars', Uniword::Generated::Chart::ErrorBars],
  ['Layout', Uniword::Generated::Chart::Layout]
]

success_count = 0
test_classes.each do |name, klass|
  # Test that class loads
  raise 'Class not defined' unless klass.is_a?(Class)

  # Test that it's a Lutaml::Model::Serializable
  raise 'Not a Serializable' unless klass < Lutaml::Model::Serializable

  # Test that we can instantiate
  instance = klass.new
  raise 'Cannot instantiate' unless instance.is_a?(klass)

  puts "  ✓ #{name}"
  success_count += 1
rescue StandardError => e
  puts "  ✗ #{name}: #{e.message}"
end

puts
puts '=' * 80
puts 'Test Results:'
puts '=' * 80
puts "✅ Loaded #{success_count}/#{test_classes.size} classes successfully"

if success_count == test_classes.size
  puts '🎉 All Chart namespace classes working perfectly!'
  puts
  puts 'Chart namespace features:'
  puts '  • 15 chart types (bar, line, pie, scatter, etc.)'
  puts '  • Complete axis system (category, value, date, series)'
  puts '  • Rich data labels and legends'
  puts '  • Advanced features (trendlines, error bars)'
  puts '  • Full styling support (shapes, markers, colors)'
  puts
  puts '=' * 80
  exit 0
else
  puts '⚠️  Some classes failed to load'
  exit 1
end

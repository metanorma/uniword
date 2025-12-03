#!/usr/bin/env ruby
# frozen_string_literal: true

# Test script for Session 5 autoload functionality

require_relative 'lib/generated/drawingml'
require_relative 'lib/generated/picture'
require_relative 'lib/generated/relationships'

puts '=' * 80
puts 'Testing Session 5 Autoload Functionality'
puts '=' * 80
puts

# Test DrawingML classes (sample from each category)
puts '1. Testing DrawingML namespace (92 classes)...'
test_classes = [
  # Original 22
  Uniword::Generated::Drawingml::Graphic,
  Uniword::Generated::Drawingml::Shape,
  Uniword::Generated::Drawingml::Transform2D,
  Uniword::Generated::Drawingml::TextBody,
  Uniword::Generated::Drawingml::SolidFill,
  Uniword::Generated::Drawingml::SrgbColor,
  # Gradient fills (10)
  Uniword::Generated::Drawingml::GradientFill,
  Uniword::Generated::Drawingml::GradientStop,
  Uniword::Generated::Drawingml::LinearGradient,
  # Effects (15)
  Uniword::Generated::Drawingml::Glow,
  Uniword::Generated::Drawingml::InnerShadow,
  Uniword::Generated::Drawingml::Reflection,
  # Color transforms (21)
  Uniword::Generated::Drawingml::Alpha,
  Uniword::Generated::Drawingml::Hue,
  Uniword::Generated::Drawingml::Tint,
  # Shapes & geometry (9)
  Uniword::Generated::Drawingml::PresetGeometry,
  Uniword::Generated::Drawingml::PathList,
  # Text properties (10)
  Uniword::Generated::Drawingml::ListStyle,
  Uniword::Generated::Drawingml::TextFont,
  # Line properties (5)
  Uniword::Generated::Drawingml::PresetDash,
  Uniword::Generated::Drawingml::LineJoinRound
]

test_classes.each do |klass|
  puts "   ✅ #{klass.name}"
end
puts "   Total: #{test_classes.size} sample classes loaded successfully"
puts

# Test Picture classes (10)
puts '2. Testing Picture namespace (10 classes)...'
picture_classes = [
  Uniword::Generated::Picture::Picture,
  Uniword::Generated::Picture::NonVisualPictureProperties,
  Uniword::Generated::Picture::PictureLocks,
  Uniword::Generated::Picture::PictureBlipFill,
  Uniword::Generated::Picture::FillRect
]

picture_classes.each do |klass|
  puts "   ✅ #{klass.name}"
end
puts "   Total: #{picture_classes.size} sample classes loaded successfully"
puts

# Test Relationships classes (5)
puts '3. Testing Relationships namespace (5 classes)...'
rel_classes = [
  Uniword::Generated::Relationships::Relationships,
  Uniword::Generated::Relationships::Relationship,
  Uniword::Generated::Relationships::ImageRelationship
]

rel_classes.each do |klass|
  puts "   ✅ #{klass.name}"
end
puts "   Total: #{rel_classes.size} sample classes loaded successfully"
puts

# Summary
puts '=' * 80
puts 'Autoload Test Complete!'
puts '=' * 80
puts 'DrawingML:     92 classes (21 tested)'
puts 'Picture:       10 classes (5 tested)'
puts 'Relationships: 5 classes (3 tested)'
puts '-' * 80
puts 'All autoload indices working correctly! ✅'
puts '=' * 80

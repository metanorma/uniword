#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/generated/presentationml'

puts '=' * 80
puts 'Session 11: Testing PresentationML Autoload'
puts '=' * 80
puts

# Test sample classes from different categories
test_classes = [
  # Presentation Structure
  { name: 'Presentation', class: Uniword::Generated::Presentationml::Presentation },
  { name: 'SlideSize', class: Uniword::Generated::Presentationml::SlideSize },
  { name: 'NotesSize', class: Uniword::Generated::Presentationml::NotesSize },
  { name: 'ColorMap', class: Uniword::Generated::Presentationml::ColorMap },

  # Slide Elements
  { name: 'Slide', class: Uniword::Generated::Presentationml::Slide },
  { name: 'SlideLayout', class: Uniword::Generated::Presentationml::SlideLayout },
  { name: 'SlideMaster', class: Uniword::Generated::Presentationml::SlideMaster },
  { name: 'CommonSlideData', class: Uniword::Generated::Presentationml::CommonSlideData },
  { name: 'ShapeTree', class: Uniword::Generated::Presentationml::ShapeTree },
  { name: 'Shape', class: Uniword::Generated::Presentationml::Shape },

  # Text & Formatting
  { name: 'TextBody', class: Uniword::Generated::Presentationml::TextBody },
  { name: 'BodyProperties', class: Uniword::Generated::Presentationml::BodyProperties },
  { name: 'Paragraph', class: Uniword::Generated::Presentationml::Paragraph },
  { name: 'Run', class: Uniword::Generated::Presentationml::Run },
  { name: 'RunProperties', class: Uniword::Generated::Presentationml::RunProperties },

  # Animations & Transitions
  { name: 'Timing', class: Uniword::Generated::Presentationml::Timing },
  { name: 'TimeNodeList', class: Uniword::Generated::Presentationml::TimeNodeList },
  { name: 'ParallelTimeNode', class: Uniword::Generated::Presentationml::ParallelTimeNode },
  { name: 'CommonTimeNode', class: Uniword::Generated::Presentationml::CommonTimeNode },
  { name: 'Transition', class: Uniword::Generated::Presentationml::Transition },

  # Media & Content
  { name: 'Picture', class: Uniword::Generated::Presentationml::Picture },
  { name: 'Video', class: Uniword::Generated::Presentationml::Video },
  { name: 'Audio', class: Uniword::Generated::Presentationml::Audio },
  { name: 'OleObject', class: Uniword::Generated::Presentationml::OleObject }
]

success_count = 0
failure_count = 0

test_classes.each do |test|
  klass = test[:class]

  # Verify it's a Lutaml::Model::Serializable
  unless klass.ancestors.include?(Lutaml::Model::Serializable)
    puts "❌ #{test[:name]} - Not a Lutaml::Model::Serializable"
    failure_count += 1
    next
  end

  # Verify it can instantiate
  klass.new

  puts "✅ #{test[:name]}"
  success_count += 1
rescue StandardError => e
  puts "❌ #{test[:name]} - #{e.message}"
  failure_count += 1
end

puts
puts '=' * 80
puts 'Test Results'
puts '=' * 80
puts "✅ Passed: #{success_count}/#{test_classes.size}"
puts "❌ Failed: #{failure_count}/#{test_classes.size}"

puts
if failure_count.zero?
  puts '🎉 All PresentationML classes loaded successfully!'
  puts '   Ready for Session 11 completion.'
  exit 0
else
  puts '⚠️  Some issues detected. Please review failures above.'
  exit 1
end

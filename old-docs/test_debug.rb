# frozen_string_literal: true

require_relative 'lib/uniword'

doc = Uniword::Document.open('spec/fixtures/docx_gem/editing.docx')
para = doc.paragraphs.first

puts "Initial paragraph text: #{para.text.inspect}"
puts "Number of runs: #{para.runs.size}"
para.runs.each_with_index do |run, i|
  puts "  Run #{i}: #{run.text.inspect}"
end

puts "\n--- Setting first run's text to 'the real test' ---"
para.runs.first.text = 'the real test'

puts "\nAfter modification:"
puts "Paragraph text: #{para.text.inspect}"
puts "Number of runs: #{para.runs.size}"
para.runs.each_with_index do |run, i|
  puts "  Run #{i}: #{run.text.inspect}"
end

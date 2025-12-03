# frozen_string_literal: true

require_relative 'lib/uniword'

para = Uniword::Paragraph.new
para.add_text('Test')

puts '=== Paragraph XML ==='
puts para.to_xml

# frozen_string_literal: true

require_relative 'lib/uniword'

# Test CharacterSpacing alone
cs = Uniword::Properties::CharacterSpacing.new(val: 20)
puts 'CharacterSpacing object:'
puts "  val = #{cs.val}"
puts "\nGenerated XML:"
puts cs.to_xml

# frozen_string_literal: true

require_relative 'lib/uniword'

para = Uniword::Paragraph.new
puts 'Before adding tab stop:'
puts "properties.tab_stops: #{para.properties.tab_stops.inspect}"

para.add_tab_stop(position: 1440, alignment: 'center', leader: 'dot')

puts "\nAfter adding tab stop:"
puts "properties.tab_stops: #{para.properties.tab_stops.inspect}"
if para.properties.tab_stops
  puts "tab_stops.tabs: #{para.properties.tab_stops.tabs.inspect}"
  puts "tab_stops.tabs.size: #{para.properties.tab_stops.tabs.size}"
end

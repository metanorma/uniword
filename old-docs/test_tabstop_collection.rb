# frozen_string_literal: true

require_relative 'lib/uniword'

# Test TabStopCollection directly
collection = Uniword::Properties::TabStopCollection.new
collection.add_tab(1440, 'center', 'dot')

puts '=== TabStopCollection XML ==='
puts collection.to_xml
puts ''

# Test with tabs array
tab = Uniword::Properties::TabStop.new(position: 1440, alignment: 'center', leader: 'dot')
collection2 = Uniword::Properties::TabStopCollection.new(tabs: [tab])
puts '=== TabStopCollection with tabs array ==='
puts collection2.to_xml

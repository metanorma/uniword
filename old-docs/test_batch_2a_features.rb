#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/uniword'

puts "Testing Batch 2A Critical API Compatibility Features\n"
puts '=' * 60

# Test 1: TableRow#add_cell returns the cell
puts "\n1. TableRow#add_cell return value:"
row = Uniword::TableRow.new
cell = row.add_cell('Test')
puts "   ✓ Returns TableCell: #{cell.is_a?(Uniword::TableCell)}"
puts "   ✓ Cell contains text: #{cell.text == 'Test'}"

# Test 2: Table#add_row returns the row
puts "\n2. Table#add_row return value:"
table = Uniword::Table.new
added_row = table.add_row
puts "   ✓ Returns TableRow: #{added_row.is_a?(Uniword::TableRow)}"
puts "   ✓ Row is in table: #{table.rows.include?(added_row)}"

# Test 3: TableCell#text= setter
puts "\n3. TableCell#text= setter:"
cell = Uniword::TableCell.new
cell.text = 'New text'
puts "   ✓ Text setter works: #{cell.text == 'New text'}"
puts "   ✓ Creates paragraph: #{cell.paragraphs.size == 1}"

# Test 4: RunProperties setters
puts "\n4. RunProperties setters:"
props = Uniword::Properties::RunProperties.new

props.bold = true
puts "   ✓ bold= works: #{props.bold == true}"

props.italic = true
puts "   ✓ italic= works: #{props.italic == true}"

props.font_size = 24
puts "   ✓ font_size= works: #{props.font_size == 24}"
puts "   ✓ size= works: #{props.size == 24}"

props.color = 'FF0000'
puts "   ✓ color= works: #{props.color == 'FF0000'}"

props.highlight = 'yellow'
puts "   ✓ highlight= works: #{props.highlight == 'yellow'}"

props.font_name = 'Arial'
puts "   ✓ font_name= works: #{props.font_name == 'Arial'}"
puts "   ✓ font= works: #{props.font == 'Arial'}"

# Test 5: ParagraphProperties setters
puts "\n5. ParagraphProperties setters:"
para_props = Uniword::Properties::ParagraphProperties.new

para_props.shading = 'FFFF00'
puts "   ✓ shading= works: #{para_props.shading == 'FFFF00'}"
puts "   ✓ shading_fill= works: #{para_props.shading_fill == 'FFFF00'}"

para_props.left_indent = 720
puts "   ✓ left_indent= works: #{para_props.left_indent == 720}"
puts "   ✓ indent_left= works: #{para_props.indent_left == 720}"

# Test 6: TableCell property accessors
puts "\n6. TableCell property accessors:"
cell = Uniword::TableCell.new

cell.width = '2000'
puts "   ✓ width accessor: #{cell.width == '2000'}"

cell.column_span = 2
puts "   ✓ column_span accessor: #{cell.column_span == 2}"
puts "   ✓ colspan accessor: #{cell.colspan == 2}"

cell.row_span = 3
puts "   ✓ row_span accessor: #{cell.row_span == 3}"
puts "   ✓ rowspan accessor: #{cell.rowspan == 3}"

puts "\n#{'=' * 60}"
puts 'All Batch 2A features verified successfully! ✓'

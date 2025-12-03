#!/usr/bin/env ruby
# frozen_string_literal: true

# Tables example for Uniword
# Demonstrates creating tables with formatting

require 'bundler/setup'
require 'uniword'

puts 'Creating a document with tables...'

# Method 1: Using Builder pattern
doc = Uniword::Builder.new
                      .add_heading('Tables Example', level: 1)
                      .add_paragraph('This document demonstrates table creation in Uniword.')
                      .add_blank_line
                      .add_heading('Simple Table', level: 2)
                      .add_table do
  row do
    cell 'Name', bold: true
    cell 'Age', bold: true
    cell 'City', bold: true
  end
  row do
    cell 'Alice'
    cell '30'
    cell 'New York'
  end
  row do
    cell 'Bob'
    cell '25'
    cell 'San Francisco'
  end
  row do
    cell 'Charlie'
    cell '35'
    cell 'Seattle'
  end
end
  .build

# Method 2: Manual table creation
puts 'Adding a manually created table...'

# Add another heading
heading = Uniword::Paragraph.new
heading.add_text('Manual Table', bold: true, size: 32)
heading.set_style('Heading2')
doc.add_element(heading)

# Create table manually
table = Uniword::Table.new

# Header row
header_row = Uniword::TableRow.new(header: true)
%w[Product Price Quantity Total].each do |header|
  cell = Uniword::TableCell.new
  para = Uniword::Paragraph.new
  para.add_text(header, bold: true)
  cell.add_paragraph(para)
  header_row.add_cell(cell)
end
table.add_row(header_row)

# Data rows
products = [
  ['Laptop', '$999', '2', '$1,998'],
  ['Mouse', '$25', '5', '$125'],
  ['Keyboard', '$75', '3', '$225']
]

products.each do |product_data|
  row = Uniword::TableRow.new
  product_data.each do |value|
    cell = Uniword::TableCell.new
    para = Uniword::Paragraph.new
    para.add_text(value)
    cell.add_paragraph(para)
    row.add_cell(cell)
  end
  table.add_row(row)
end

# Add total row
total_row = Uniword::TableRow.new
['Total', '', '', '$2,348'].each_with_index do |value, i|
  cell = Uniword::TableCell.new
  para = Uniword::Paragraph.new
  if i == 3
    para.add_text(value, bold: true)
  else
    para.add_text(value, bold: i.zero?)
  end
  cell.add_paragraph(para)
  total_row.add_cell(cell)
end
table.add_row(total_row)

doc.add_element(table)

# Save the document
output_dir = File.join(__dir__, 'output')
FileUtils.mkdir_p(output_dir)

output_path = File.join(output_dir, 'tables_example.docx')
doc.save(output_path)

puts "✓ Created #{output_path}"
puts "  Table 1: #{doc.tables[0].row_count} rows × #{doc.tables[0].column_count} columns"
puts "  Table 2: #{doc.tables[1].row_count} rows × #{doc.tables[1].column_count} columns"
puts "\nTables example complete!"

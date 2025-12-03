# frozen_string_literal: true

require_relative 'lib/uniword'
  <?xml version="1.0"?>
  <document xmlns="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
    <pBdr>
      <top w:val="single" w:color="FF0000" w:sz="4"/>
    </pBdr>
  </document>
XML

# Try to parse just the border
border_xml = <<~XML
  <top xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" w:val="single" w:color="FF0000" w:sz="4"/>
XML

border = Uniword::Properties::Border.from_xml(border_xml)
puts 'Border parsed:'
puts "  style: #{border.style.inspect}"
puts "  color: #{border.color.inspect}"
puts "  size: #{border.size.inspect}"

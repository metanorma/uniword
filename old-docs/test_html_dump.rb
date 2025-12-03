#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require_relative 'lib/uniword'
require 'uniword/infrastructure/mime_parser'

file_path = '/Users/mulgogi/src/mn/mn-samples-iso/_site/documents/international-standard/rice-2016/document-en.doc'

parser = Uniword::Infrastructure::MimeParser.new
parts = parser.parse(file_path)

html = parts['html'] || ''

# Save the extracted HTML to a file for inspection
File.write('extracted_html.html', html)

puts "Extracted HTML length: #{html.length}"
puts 'Saved to extracted_html.html'
puts "\nFirst 2000 characters:"
puts html[0..2000]

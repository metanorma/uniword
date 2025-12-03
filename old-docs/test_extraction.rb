#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require_relative 'lib/uniword'

file_path = '/Users/mulgogi/src/mn/mn-samples-iso/_site/documents/international-standard/rice-2016/document-en.doc'

puts "Testing extraction from: #{File.basename(file_path)}"
puts "File size: #{(File.size(file_path) / 1024.0 / 1024.0).round(2)} MB"
puts

doc = Uniword::Document.open(file_path)

puts 'Results:'
puts "  Paragraphs: #{doc.paragraphs.count}"
puts "  Tables: #{doc.tables.count}"
puts "  Text length: #{doc.text.length} chars"
puts

puts 'First 5 paragraphs:'
doc.paragraphs.first(5).each_with_index do |p, i|
  text = p.text.strip
  preview = text.length > 60 ? "#{text[0..60]}..." : text
  puts "  #{i + 1}. #{preview}"
end

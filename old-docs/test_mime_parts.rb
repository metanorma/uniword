#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require_relative 'lib/uniword/infrastructure/mime_parser'

file_path = '/Users/mulgogi/src/mn/mn-samples-iso/_site/documents/international-standard/rice-2016/document-en.doc'

content = File.read(file_path, encoding: 'UTF-8')

# Extract boundary
boundary = content.match(/boundary="([^"]+)"/)[1]
puts "Boundary: #{boundary}"

# Split by boundary
parts = content.split(/--#{Regexp.escape(boundary)}/)
parts.reject! { |p| p.strip.empty? || p.strip == '--' }

puts "\nTotal MIME parts: #{parts.length}"
puts "\nPart summaries:"
parts.each_with_index do |part, idx|
  headers = part.split(/\r?\n\r?\n/, 2).first
  content_type = headers.match(/Content-Type:\s*(.+?)$/i)&.captures&.first&.strip
  content_location = headers.match(/Content-Location:\s*(.+?)$/i)&.captures&.first&.strip

  puts "\nPart #{idx + 1}:"
  puts "  Content-Type: #{content_type}"
  puts "  Content-Location: #{content_location}"
  puts "  Size: #{part.length} bytes"

  # Check if this part has WordSection
  if part.include?('WordSection')
    wordsection_count = part.scan('WordSection').count
    puts "  *** Contains #{wordsection_count} WordSection references ***"
  end

  # Check if this part has many paragraph tags
  p_count = part.scan(/<p[\s>]/).count
  puts "  Paragraph tags: #{p_count}" if p_count.positive?
end

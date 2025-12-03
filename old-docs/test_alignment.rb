# frozen_string_literal: true

require 'bundler/setup'
require './lib/uniword'

doc = Uniword::DocumentFactory.from_file('spec/fixtures/docx_gem/formatting.docx')
doc.paragraphs.each_with_index do |p, i|
  text = begin
    p.text[0..40]
  rescue StandardError
    ''
  end
  puts "Para #{i}: '#{text}' alignment=#{p.alignment.inspect} props=#{p.properties&.alignment.inspect}"
end

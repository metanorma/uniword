# frozen_string_literal: true

require_relative "lib/uniword"
require "nokogiri"

dotx_path = "references/word-resources/document-elements/Cover Pages.dotx"
xml = nil
Zip::File.open(dotx_path) do |zip|
  xml = zip.find_entry("word/glossary/document.xml").get_input_stream.read
end

glossary = Uniword::Glossary::GlossaryDocument.from_xml(xml)

# Check all docParts paragraph count
glossary.doc_parts.doc_part.each_with_index do |dp, i|
  body = dp.doc_part_body
  next unless body

  p_count = body.paragraphs&.count || 0
  sdt_count = body.sdts&.count || 0
  r_count = 0
  ac_count = 0
  (body.paragraphs || []).each do |p|
    r_count += p.runs&.count || 0
    p.runs&.each do |r|
      ac_count += 1 if r.alternate_content
    end
  end

  puts "DP[#{i}]: p=#{p_count} sdt=#{sdt_count} r=#{r_count} ac_in_runs=#{ac_count}"
end

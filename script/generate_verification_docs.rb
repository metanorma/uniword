#!/usr/bin/env ruby
# frozen_string_literal: true

# Generate verification DOCX files with known content.
# Open each in Microsoft Word and check File > Info > Properties to compare
# statistics against our calculated values.

require "uniword"
require "fileutils"

OUTPUT_DIR = File.join(Dir.tmpdir, "uniword_verify_stats")
FileUtils.mkdir_p(OUTPUT_DIR)

def build_simple_doc(filename, paragraph_texts)
  package = Uniword::Docx::Package.new
  package.document = Uniword::Wordprocessingml::DocumentRoot.new

  paragraph_texts.each do |text|
    para = Uniword::Wordprocessingml::Paragraph.new
    run = Uniword::Wordprocessingml::Run.new
    run.text = text
    para.runs << run
    package.document.body.paragraphs << para
  end

  profile = Uniword::Docx::Profile.load(:word_2024_en)
  Uniword::Docx::Reconciler.new(package, profile: profile).reconcile

  path = File.join(OUTPUT_DIR, filename)
  package.save(path)

  stats = Uniword::Docx::DocumentStatistics.new(package).calculate
  puts "=== #{filename} ==="
  puts "  Content: #{paragraph_texts.inspect}"
  puts "  Our stats: W=#{stats[:words]} C=#{stats[:characters]} CWS=#{stats[:characters_with_spaces]} P=#{stats[:paragraphs]} L=#{stats[:lines]}"
  puts "  Saved to: #{path}"
  puts
end

puts "Generating verification documents in #{OUTPUT_DIR}"
puts "=" * 60
puts

# Test 1: Single word
build_simple_doc("01_single_word.docx", ["Hello"])

# Test 2: Two words in one paragraph
build_simple_doc("02_two_words.docx", ["Hello World"])

# Test 3: Two paragraphs
build_simple_doc("03_two_paragraphs.docx", ["Hello", "World"])

# Test 4: Three paragraphs with empty one
build_simple_doc("04_with_empty_para.docx", ["Hello", "", "World"])

# Test 5: Longer text
build_simple_doc("05_longer_text.docx", [
                   "The quick brown fox jumps over the lazy dog.",
                   "This is a second paragraph with more text.",
                 ])

# Test 6: CJK text
build_simple_doc("06_cjk_text.docx", ["Hello 你好 World 世界"])

puts "=" * 60
puts "Please open each file in Microsoft Word and compare the statistics"
puts "in File > Info > Properties > Advanced Properties > Statistics."

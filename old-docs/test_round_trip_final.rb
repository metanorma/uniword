#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/uniword'
require 'tempfile'
require 'fileutils'

# Final validation of round-trip functionality
class RoundTripValidator
  def initialize
    @test_files_dir = '/Users/mulgogi/Documents/sampleDocument'
    @iso_docx_file = File.join(@test_files_dir, 'iso-wd-8601-2-2026.docx')
    @mhtml_file = File.join(@test_files_dir, 'document.doc')
    @temp_dir = Dir.mktmpdir('uniword_validation_')
    @results = {}
  end

  def run_all_tests
    puts '🔄 Round-Trip Functionality Validation'
    puts '======================================'
    puts

    test_iso_docx_round_trip
    test_mhtml_round_trip
    test_namespace_preservation
    test_unknown_element_preservation

    print_summary

    @results[:all_passed]
  ensure
    cleanup
  end

  private

  def test_iso_docx_round_trip
    puts '📄 Testing ISO 8601 DOCX Round-Trip...'

    unless File.exist?(@iso_docx_file)
      puts '   ⚠️  SKIPPED: Test file not found'
      @results[:iso_docx] = :skipped
      return
    end

    begin
      # Read original
      original_doc = Uniword::Document.open(@iso_docx_file)
      original_stats = document_stats(original_doc)

      # Save and read back
      temp_file = File.join(@temp_dir, 'iso_roundtrip.docx')
      original_doc.save(temp_file)
      roundtrip_doc = Uniword::Document.open(temp_file)
      roundtrip_stats = document_stats(roundtrip_doc)

      # Verify preservation
      text_preserved = original_stats[:text] == roundtrip_stats[:text]
      structure_preserved = original_stats[:paragraphs] == roundtrip_stats[:paragraphs] &&
                            original_stats[:tables] == roundtrip_stats[:tables] &&
                            original_stats[:hyperlinks] == roundtrip_stats[:hyperlinks]

      if text_preserved && structure_preserved
        puts '   ✅ PASSED: Content and structure preserved'
        puts "      📊 Stats: #{roundtrip_stats[:paragraphs]} paragraphs, #{roundtrip_stats[:tables]} tables"
        puts "      📝 Text: #{roundtrip_stats[:text_length]} characters preserved"
        @results[:iso_docx] = :passed
      else
        puts '   ❌ FAILED: Content or structure not preserved'
        puts "      Text preserved: #{text_preserved}"
        puts "      Structure preserved: #{structure_preserved}"
        @results[:iso_docx] = :failed
      end
    rescue StandardError => e
      puts "   ❌ ERROR: #{e.message}"
      @results[:iso_docx] = :error
    end

    puts
  end

  def test_mhtml_round_trip
    puts '📄 Testing MHTML Round-Trip...'

    unless File.exist?(@mhtml_file)
      puts '   ⚠️  SKIPPED: Test file not found'
      @results[:mhtml] = :skipped
      return
    end

    begin
      # Read original
      original_doc = Uniword::Document.open(@mhtml_file)
      original_stats = document_stats(original_doc)

      # Save and read back
      temp_file = File.join(@temp_dir, 'mhtml_roundtrip.docx')
      original_doc.save(temp_file)
      roundtrip_doc = Uniword::Document.open(temp_file)
      roundtrip_stats = document_stats(roundtrip_doc)

      # Verify preservation
      text_preserved = original_stats[:text] == roundtrip_stats[:text]
      structure_preserved = original_stats[:paragraphs] == roundtrip_stats[:paragraphs] &&
                            original_stats[:tables] == roundtrip_stats[:tables]

      if text_preserved && structure_preserved
        puts '   ✅ PASSED: Content and structure preserved'
        puts "      📊 Stats: #{roundtrip_stats[:paragraphs]} paragraphs, #{roundtrip_stats[:tables]} tables"
        puts "      📝 Text: #{roundtrip_stats[:text_length]} characters preserved"
        @results[:mhtml] = :passed
      else
        puts '   ❌ FAILED: Content or structure not preserved'
        @results[:mhtml] = :failed
      end
    rescue StandardError => e
      puts "   ❌ ERROR: #{e.message}"
      @results[:mhtml] = :error
    end

    puts
  end

  def test_namespace_preservation
    puts '🏷️  Testing Namespace Preservation...'

    begin
      # Create a simple document and save it
      doc = Uniword::Document.new
      para = doc.add_paragraph
      para.add_text('Test namespace preservation')

      temp_file = File.join(@temp_dir, 'namespace_test.docx')
      doc.save(temp_file)

      # Check the XML for required namespaces
      require 'zip'
      Zip::File.open(temp_file) do |zip|
        document_xml = zip.read('word/document.xml')

        has_math_ns = document_xml.include?('xmlns:m="http://schemas.openxmlformats.org/wordprocessingml/2006/math"')
        has_main_ns = document_xml.include?('xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"')
        has_rel_ns = document_xml.include?('xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"')

        if has_math_ns && has_main_ns && has_rel_ns
          puts '   ✅ PASSED: All required namespaces present'
          puts "      ✓ Math namespace (m): #{has_math_ns}"
          puts "      ✓ Main namespace (w): #{has_main_ns}"
          puts "      ✓ Relationships namespace (r): #{has_rel_ns}"
          @results[:namespaces] = :passed
        else
          puts '   ❌ FAILED: Missing required namespaces'
          puts "      Math namespace (m): #{has_math_ns}"
          puts "      Main namespace (w): #{has_main_ns}"
          puts "      Relationships namespace (r): #{has_rel_ns}"
          @results[:namespaces] = :failed
        end
      end
    rescue StandardError => e
      puts "   ❌ ERROR: #{e.message}"
      @results[:namespaces] = :error
    end

    puts
  end

  def test_unknown_element_preservation
    puts '❓ Testing Unknown Element Preservation...'

    unless File.exist?(@iso_docx_file)
      puts '   ⚠️  SKIPPED: Test file not found'
      @results[:unknown_elements] = :skipped
      return
    end

    begin
      # Read document with unknown elements
      doc = Uniword::Document.open(@iso_docx_file)
      original_unknown_count = count_unknown_elements(doc)

      # Save and read back
      temp_file = File.join(@temp_dir, 'unknown_test.docx')
      doc.save(temp_file)
      roundtrip_doc = Uniword::Document.open(temp_file)
      roundtrip_unknown_count = count_unknown_elements(roundtrip_doc)

      if original_unknown_count == roundtrip_unknown_count
        puts '   ✅ PASSED: Unknown elements preserved'
        puts "      📊 Unknown elements: #{roundtrip_unknown_count} preserved"
        @results[:unknown_elements] = :passed
      else
        puts '   ❌ FAILED: Unknown elements not preserved'
        puts "      Original: #{original_unknown_count}, Round-trip: #{roundtrip_unknown_count}"
        @results[:unknown_elements] = :failed
      end
    rescue StandardError => e
      puts "   ❌ ERROR: #{e.message}"
      @results[:unknown_elements] = :error
    end

    puts
  end

  def document_stats(doc)
    text_content = doc.paragraphs.map(&:text).join

    {
      paragraphs: doc.paragraphs.size,
      tables: doc.tables.size,
      text: text_content,
      text_length: text_content.length,
      hyperlinks: count_hyperlinks(doc)
    }
  end

  def count_unknown_elements(doc)
    count = 0
    doc.paragraphs.each do |para|
      para.runs.each do |run|
        count += 1 if run.is_a?(Uniword::UnknownElement)
      end
    end
    count
  end

  def count_hyperlinks(doc)
    count = 0
    doc.paragraphs.each do |para|
      para.runs.each do |run|
        count += 1 if run.is_a?(Uniword::Hyperlink)
      end
    end
    count
  end

  def print_summary
    puts '📋 Test Summary'
    puts '==============='

    total_tests = @results.size
    passed_tests = @results.values.count(:passed)
    failed_tests = @results.values.count(:failed)
    error_tests = @results.values.count(:error)
    skipped_tests = @results.values.count(:skipped)

    puts "   Total: #{total_tests}"
    puts "   ✅ Passed: #{passed_tests}"
    puts "   ❌ Failed: #{failed_tests}"
    puts "   💥 Errors: #{error_tests}"
    puts "   ⚠️  Skipped: #{skipped_tests}"
    puts

    @results[:all_passed] = failed_tests.zero? && error_tests.zero?

    if @results[:all_passed]
      puts '🎉 ALL TESTS PASSED! Round-trip functionality is working correctly.'
    else
      puts '⚠️  Some tests failed. Please review the output above.'
    end

    puts
  end

  def cleanup
    FileUtils.remove_entry(@temp_dir) if @temp_dir && Dir.exist?(@temp_dir)
  end
end

if __FILE__ == $PROGRAM_NAME
  validator = RoundTripValidator.new
  success = validator.run_all_tests
  exit(success ? 0 : 1)
end

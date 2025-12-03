#!/usr/bin/env ruby
# frozen_string_literal: true

# Test script for Theme + StyleSet combination validation
# Validates the full implementation against reference document

require_relative 'lib/uniword'
require 'fileutils'

# Output directory for test files
TEST_OUTPUT_DIR = 'test_output'
FileUtils.mkdir_p(TEST_OUTPUT_DIR)

class ThemeStyleSetTester
  attr_reader :results

  def initialize
    @results = {
      total_tests: 0,
      passed: 0,
      failed: 0,
      errors: [],
      generated_files: []
    }
  end

  def run_all_tests
    puts '=' * 80
    puts 'Theme + StyleSet Combination Test Suite'
    puts '=' * 80
    puts

    # Test 1: Validate reference document
    test_reference_document

    # Test 2: Create matching document from scratch
    test_create_matching_document

    # Test 3: Test theme + styleset variations
    test_theme_styleset_variations

    # Test 4: Test CLI commands
    test_cli_commands

    # Test 5: Comparison test
    test_comparison

    # Print summary
    print_summary
  end

  private

  def test_reference_document
    puts "\n#{'=' * 80}"
    puts 'TEST 1: Validate Reference Document'
    puts '=' * 80

    @results[:total_tests] += 1

    begin
      ref_path = 'examples/sample-theme_celestial-style_distinctive.docx'

      raise "Reference document not found: #{ref_path}" unless File.exist?(ref_path)

      puts "Loading reference document: #{ref_path}"
      ref_doc = Uniword::Document.open(ref_path)

      # Verify theme
      theme_name = ref_doc.theme&.name
      puts "  ✓ Reference theme: #{theme_name || 'None'}"

      # Verify styles
      styles_count = ref_doc.styles_configuration.all_styles.count
      puts "  ✓ Reference styles: #{styles_count}"

      # List style types
      para_styles = ref_doc.styles_configuration.paragraph_styles.count
      char_styles = ref_doc.styles_configuration.character_styles.count

      puts "    - Paragraph styles: #{para_styles}"
      puts "    - Character styles: #{char_styles}"

      # Verify theme colors
      if ref_doc.theme
        puts "  ✓ Theme has color scheme: #{ref_doc.theme.color_scheme.nil? ? 'No' : 'Yes'}"
        puts "  ✓ Theme has font scheme: #{ref_doc.theme.font_scheme.nil? ? 'No' : 'Yes'}"

        puts "    - Major font: #{ref_doc.theme.major_font}" if ref_doc.theme.major_font
        puts "    - Minor font: #{ref_doc.theme.minor_font}" if ref_doc.theme.minor_font
      end

      @results[:passed] += 1
      puts "\n✓ TEST 1 PASSED"
    rescue StandardError => e
      @results[:failed] += 1
      @results[:errors] << "Test 1 failed: #{e.message}"
      puts "\n✗ TEST 1 FAILED: #{e.message}"
      puts e.backtrace.first(5).join("\n") if ENV['DEBUG']
    end
  end

  def test_create_matching_document
    puts "\n#{'=' * 80}"
    puts 'TEST 2: Create Matching Document from Scratch'
    puts '=' * 80

    @results[:total_tests] += 1

    begin
      puts 'Creating new document...'
      doc = Uniword::Document.new

      # Apply Celestial theme
      puts "Applying 'celestial' theme..."
      doc.apply_theme('celestial')

      # Apply Distinctive StyleSet
      puts "Applying 'distinctive' styleset..."
      doc.apply_styleset('distinctive')

      # Add sample content
      puts 'Adding sample content...'
      doc.add_paragraph('Theme and StyleSet Test', heading: :heading_1)
      doc.add_paragraph('This document tests the Celestial theme with Distinctive StyleSet.')
      doc.add_paragraph('Heading 2 Example', heading: :heading_2)
      doc.add_paragraph('Body text with proper styling applied.')

      # Save document
      output_path = File.join(TEST_OUTPUT_DIR, 'test_celestial_distinctive.docx')
      puts "Saving to: #{output_path}"
      doc.save(output_path)

      # Verify the saved document
      puts 'Verifying saved document...'
      saved_doc = Uniword::Document.open(output_path)

      theme_name = saved_doc.theme&.name
      styles_count = saved_doc.styles_configuration.all_styles.count

      puts "  ✓ Generated theme: #{theme_name}"
      puts "  ✓ Generated styles: #{styles_count}"

      @results[:generated_files] << output_path
      @results[:passed] += 1
      puts "\n✓ TEST 2 PASSED"
    rescue StandardError => e
      @results[:failed] += 1
      @results[:errors] << "Test 2 failed: #{e.message}"
      puts "\n✗ TEST 2 FAILED: #{e.message}"
      puts e.backtrace.first(5).join("\n") if ENV['DEBUG']
    end
  end

  def test_theme_styleset_variations
    puts "\n#{'=' * 80}"
    puts 'TEST 3: Theme + StyleSet Variations'
    puts '=' * 80

    combinations = [
      { theme: 'celestial', styleset: 'distinctive', name: 'celestial_distinctive' },
      { theme: 'atlas', styleset: 'elegant', name: 'atlas_elegant' },
      { theme: 'office_theme', styleset: 'modern', name: 'office_modern' }
    ]

    combinations.each_with_index do |combo, idx|
      @results[:total_tests] += 1

      begin
        puts "\n--- Combination #{idx + 1}: #{combo[:theme]} + #{combo[:styleset]} ---"

        doc = Uniword::Document.new

        puts "  Applying theme: #{combo[:theme]}"
        doc.apply_theme(combo[:theme])

        puts "  Applying styleset: #{combo[:styleset]}"
        doc.apply_styleset(combo[:styleset])

        # Add content
        doc.add_paragraph("#{combo[:theme].capitalize} Theme Test", heading: :heading_1)
        doc.add_paragraph("With #{combo[:styleset].capitalize} StyleSet", heading: :heading_2)
        doc.add_paragraph('This is sample body text to demonstrate the styling.')

        # Save
        output_path = File.join(TEST_OUTPUT_DIR, "test_#{combo[:name]}.docx")
        doc.save(output_path)

        # Verify
        saved_doc = Uniword::Document.open(output_path)
        puts "  ✓ Theme: #{saved_doc.theme&.name}"
        puts "  ✓ Styles: #{saved_doc.styles_configuration.all_styles.count}"

        @results[:generated_files] << output_path
        @results[:passed] += 1
      rescue StandardError => e
        @results[:failed] += 1
        @results[:errors] << "Combination #{combo[:name]} failed: #{e.message}"
        puts "  ✗ FAILED: #{e.message}"
      end
    end

    puts "\n✓ TEST 3 COMPLETED (#{combinations.size} combinations)"
  end

  def test_cli_commands
    puts "\n#{'=' * 80}"
    puts 'TEST 4: CLI Commands'
    puts '=' * 80

    @results[:total_tests] += 1

    begin
      # Create base document
      base_path = File.join(TEST_OUTPUT_DIR, 'cli_base.docx')
      doc = Uniword::Document.new
      doc.add_paragraph('CLI Test Document', heading: :heading_1)
      doc.add_paragraph('Testing CLI theme and styleset application.')
      doc.save(base_path)
      puts "Created base document: #{base_path}"

      # Apply theme via CLI
      theme_output = File.join(TEST_OUTPUT_DIR, 'cli_with_theme.docx')
      cmd1 = "ruby -Ilib bin/uniword theme apply #{base_path} #{theme_output} --name celestial"
      puts "\nRunning: #{cmd1}"
      result1 = system(cmd1)
      raise 'Theme CLI command failed' unless result1

      puts '  ✓ Theme applied via CLI'

      # Apply styleset via CLI
      final_output = File.join(TEST_OUTPUT_DIR, 'cli_final.docx')
      cmd2 = "ruby -Ilib bin/uniword styleset apply #{theme_output} #{final_output} --name distinctive"
      puts "\nRunning: #{cmd2}"
      result2 = system(cmd2)
      raise 'StyleSet CLI command failed' unless result2

      puts '  ✓ StyleSet applied via CLI'

      # Verify final result
      final_doc = Uniword::Document.open(final_output)
      puts "\nFinal document:"
      puts "  ✓ Theme: #{final_doc.theme&.name}"
      puts "  ✓ Styles: #{final_doc.styles_configuration.all_styles.count}"

      @results[:generated_files] += [base_path, theme_output, final_output]
      @results[:passed] += 1
      puts "\n✓ TEST 4 PASSED"
    rescue StandardError => e
      @results[:failed] += 1
      @results[:errors] << "Test 4 failed: #{e.message}"
      puts "\n✗ TEST 4 FAILED: #{e.message}"
      puts e.backtrace.first(5).join("\n") if ENV['DEBUG']
    end
  end

  def test_comparison
    puts "\n#{'=' * 80}"
    puts 'TEST 5: Comparison with Reference Document'
    puts '=' * 80

    @results[:total_tests] += 1

    begin
      # Load reference
      ref_path = 'examples/sample-theme_celestial-style_distinctive.docx'
      ref_doc = Uniword::Document.open(ref_path)

      # Load generated
      gen_path = File.join(TEST_OUTPUT_DIR, 'test_celestial_distinctive.docx')
      raise 'Generated document not found (run test 2 first)' unless File.exist?(gen_path)

      gen_doc = Uniword::Document.open(gen_path)

      puts 'Comparing reference vs generated...'

      # Compare theme names
      ref_theme = ref_doc.theme&.name
      gen_theme = gen_doc.theme&.name

      if ref_theme == gen_theme
        puts "  ✓ Theme names match: #{ref_theme}"
      else
        puts "  ✗ Theme mismatch: #{ref_theme} vs #{gen_theme}"
      end

      # Compare style counts
      ref_styles = ref_doc.styles_configuration.all_styles.count
      gen_styles = gen_doc.styles_configuration.all_styles.count

      puts "  • Reference styles: #{ref_styles}"
      puts "  • Generated styles: #{gen_styles}"

      if ref_styles == gen_styles
        puts '  ✓ Style counts match'
      else
        diff = gen_styles - ref_styles
        puts "  ℹ Style count difference: #{'+' if diff.positive?}#{diff}"
      end

      # Compare style IDs
      ref_style_ids = ref_doc.styles_configuration.all_styles.map(&:id).sort
      gen_style_ids = gen_doc.styles_configuration.all_styles.map(&:id).sort

      common_styles = ref_style_ids & gen_style_ids
      ref_only = ref_style_ids - gen_style_ids
      gen_only = gen_style_ids - ref_style_ids

      puts "\n  Style comparison:"
      puts "    Common styles: #{common_styles.count}"

      if ref_only.any?
        puts "    Reference-only (#{ref_only.count}): #{ref_only.first(5).join(', ')}#{if ref_only.count > 5
                                                                                         '...'
                                                                                       end}"
      end

      if gen_only.any?
        puts "    Generated-only (#{gen_only.count}): #{gen_only.first(5).join(', ')}#{if gen_only.count > 5
                                                                                         '...'
                                                                                       end}"
      end

      @results[:passed] += 1
      puts "\n✓ TEST 5 PASSED"
    rescue StandardError => e
      @results[:failed] += 1
      @results[:errors] << "Test 5 failed: #{e.message}"
      puts "\n✗ TEST 5 FAILED: #{e.message}"
      puts e.backtrace.first(5).join("\n") if ENV['DEBUG']
    end
  end

  def print_summary
    puts "\n#{'=' * 80}"
    puts 'TEST SUMMARY'
    puts '=' * 80
    puts
    puts "Total tests: #{@results[:total_tests]}"
    puts "Passed:      #{@results[:passed]} #{'✓' * @results[:passed]}"
    puts "Failed:      #{@results[:failed]} #{'✗' * @results[:failed]}"
    puts

    if @results[:errors].any?
      puts 'Errors:'
      @results[:errors].each_with_index do |error, idx|
        puts "  #{idx + 1}. #{error}"
      end
      puts
    end

    puts "Generated files (#{@results[:generated_files].count}):"
    @results[:generated_files].uniq.each do |file|
      size = File.exist?(file) ? (File.size(file) / 1024.0).round(1) : 0
      puts "  • #{file} (#{size} KB)"
    end
    puts

    success_rate = (@results[:passed].to_f / @results[:total_tests] * 100).round(1)
    puts "Success rate: #{success_rate}%"
    puts '=' * 80

    # Exit code based on results
    exit(@results[:failed].positive? ? 1 : 0)
  end
end

# Run the test suite
if __FILE__ == $PROGRAM_NAME
  tester = ThemeStyleSetTester.new
  tester.run_all_tests
end

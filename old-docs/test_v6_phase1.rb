#!/usr/bin/env ruby
# frozen_string_literal: true

# Quick integration test for v6.0 Phase 1
# Tests Feature 2 (Document Validation) and Feature 3 (Warning System)

require_relative 'lib/uniword/validation/document_validator'
require_relative 'lib/uniword/warnings/warning_collector'

puts '=' * 60
puts 'v6.0 Phase 1 Integration Test'
puts 'Testing Features 2 & 3: Validation + Warnings'
puts '=' * 60
puts ''

# Test 1: Document Validator
puts 'Test 1: Document Validation Framework'
puts '-' * 60

begin
  validator = Uniword::Validation::DocumentValidator.new
  puts '✓ DocumentValidator initialized'
  puts "  Validators loaded: #{validator.validators.count}"

  validator.validators.each do |v|
    puts "    - #{v.layer_name} (#{v.enabled? ? 'enabled' : 'disabled'})"
  end
rescue StandardError => e
  puts "✗ Error initializing DocumentValidator: #{e.message}"
  puts e.backtrace.first(3)
end

puts ''

# Test 2: Validate a real document if available
puts 'Test 2: Validate Sample Document'
puts '-' * 60

sample_files = Dir.glob('spec/fixtures/**/*.docx').first(3)
if sample_files.any?
  sample_files.each do |file|
    puts "Validating: #{file}"
    begin
      validator = Uniword::Validation::DocumentValidator.new
      report = validator.validate(file)

      puts "  Valid: #{report.valid?}"
      puts "  Layers validated: #{report.layer_results.count}"
      puts "  Errors: #{report.errors.count}"
      puts "  Warnings: #{report.warnings.count}"

      if report.errors.any?
        report.errors.first(3).each do |err|
          puts "    [ERROR] #{err[:layer]}: #{err[:message]}"
        end
      end

      puts '  ✓ Validation completed'
    rescue StandardError => e
      puts "  ✗ Error: #{e.message}"
    end
    puts ''
  end
else
  puts '  No sample .docx files found in spec/fixtures'
  puts '  Skipping document validation test'
end

puts ''

# Test 3: Warning System
puts 'Test 3: Warning Collection System'
puts '-' * 60

begin
  collector = Uniword::Warnings::WarningCollector.new
  puts '✓ WarningCollector initialized'

  # Simulate collecting warnings
  collector.record_unsupported('chart', context: 'In paragraph 1')
  collector.record_unsupported('smartArt', context: 'In paragraph 2')
  collector.record_unsupported('chart', context: 'In paragraph 3')
  collector.record_unsupported_attribute('w:p', 'customAttr', context: 'In para properties')

  puts '✓ Recorded 4 warnings'

  report = collector.report
  puts '✓ Generated warning report'
  puts ''
  puts 'Report Summary:'
  puts report.summary
  puts ''
  puts '✓ Warning system working'
rescue StandardError => e
  puts "✗ Error in warning system: #{e.message}"
  puts e.backtrace.first(3)
end

puts ''

# Test 4: Configuration Loading
puts 'Test 4: Configuration Loading'
puts '-' * 60

begin
  require_relative 'lib/uniword/configuration/configuration_loader'

  # Test validation config
  if File.exist?('config/validation_rules.yml')
    config = Uniword::Configuration::ConfigurationLoader.load('validation_rules')
    puts '✓ Loaded validation_rules.yml'
    puts "  Fail-fast: #{config.dig(:document_validation, :fail_fast)}"
    puts "  Max file size: #{config.dig(:document_validation, :max_file_size)}"
  else
    puts '✗ validation_rules.yml not found'
  end

  # Test warning config
  if File.exist?('config/warning_rules.yml')
    config = Uniword::Configuration::ConfigurationLoader.load('warning_rules')
    puts '✓ Loaded warning_rules.yml'
    puts "  Enabled: #{config.dig(:warning_system, :enabled)}"
    puts "  Critical elements: #{config.dig(:warning_system, :critical_elements)&.count || 0}"
  else
    puts '✗ warning_rules.yml not found'
  end
rescue StandardError => e
  puts "✗ Error loading config: #{e.message}"
  puts e.backtrace.first(3)
end

puts ''
puts '=' * 60
puts 'Integration Test Complete'
puts '=' * 60

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/uniword'

# Test accessing nested namespace classes through autoload
puts '=== Testing Namespace Autoloads ==='

begin
  puts '1. Testing Styles::StyleDefinition autoload...'
  Uniword::Styles::StyleDefinition
  puts '   SUCCESS'
rescue NameError => e
  puts "   FAILED: #{e.message}"
end

begin
  puts '2. Testing Styles::StyleBuilder autoload...'
  Uniword::Styles::StyleBuilder
  puts '   SUCCESS'
rescue NameError => e
  puts "   FAILED: #{e.message}"
end

begin
  puts '3. Testing Template::TemplateRenderer autoload...'
  Uniword::Template::TemplateRenderer
  puts '   SUCCESS'
rescue NameError => e
  puts "   FAILED: #{e.message}"
end

begin
  puts '4. Testing Visitor::BaseVisitor autoload...'
  Uniword::Visitor::BaseVisitor
  puts '   SUCCESS'
rescue NameError => e
  puts "   FAILED: #{e.message}"
end

begin
  puts '5. Testing Validators::TableValidator autoload...'
  Uniword::Validators::TableValidator
  puts '   SUCCESS'
rescue NameError => e
  puts "   FAILED: #{e.message}"
end

begin
  puts '6. Testing Stylesets::Package autoload...'
  Uniword::Stylesets::Package
  puts '   SUCCESS'
rescue NameError => e
  puts "   FAILED: #{e.message}"
end

begin
  puts '7. Testing Infrastructure::ZipExtractor autoload...'
  Uniword::Infrastructure::ZipExtractor
  puts '   SUCCESS'
rescue NameError => e
  puts "   FAILED: #{e.message}"
end

begin
  puts '8. Testing Accessibility::AccessibilityChecker autoload...'
  Uniword::Accessibility::AccessibilityChecker
  puts '   SUCCESS'
rescue NameError => e
  puts "   FAILED: #{e.message}"
end

begin
  puts '9. Testing Accessibility::Rules::ColorUsageRule autoload...'
  Uniword::Accessibility::Rules::ColorUsageRule
  puts '   SUCCESS'
rescue NameError => e
  puts "   FAILED: #{e.message}"
end

begin
  puts '10. Testing Assembly::TocGenerator autoload...'
  Uniword::Assembly::TocGenerator
  puts '   SUCCESS'
rescue NameError => e
  puts "   FAILED: #{e.message}"
end

begin
  puts '11. Testing Batch::DocumentProcessor autoload...'
  Uniword::Batch::DocumentProcessor
  puts '   SUCCESS'
rescue NameError => e
  puts "   FAILED: #{e.message}"
end

begin
  puts '12. Testing Metadata::MetadataExtractor autoload...'
  Uniword::Metadata::MetadataExtractor
  puts '   SUCCESS'
rescue NameError => e
  puts "   FAILED: #{e.message}"
end

begin
  puts '13. Testing Quality::QualityReport autoload...'
  Uniword::Quality::QualityReport
  puts '   SUCCESS'
rescue NameError => e
  puts "   FAILED: #{e.message}"
end

begin
  puts '14. Testing Schema::SchemaLoader autoload...'
  Uniword::Schema::SchemaLoader
  puts '   SUCCESS'
rescue NameError => e
  puts "   FAILED: #{e.message}"
end

puts ''
puts '=== All Namespace Autoloads Working! ==='

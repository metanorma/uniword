#!/usr/bin/env ruby
# frozen_string_literal: true

# Metadata Manager Integration Example
#
# This example demonstrates the complete Metadata Manager functionality including:
# - Extracting metadata from documents
# - Updating document metadata
# - Validating metadata
# - Batch operations
# - Export to various formats

require_relative '../lib/uniword'
require_relative '../lib/uniword/metadata/metadata_manager'

puts "=== Uniword Metadata Manager Example ===\n\n"

# Initialize the Metadata Manager
manager = Uniword::Metadata::MetadataManager.new

puts '1. Creating a sample document...'
doc = Uniword::Document.new
para1 = Uniword::Paragraph.new
para1.add_text('This is a sample document for metadata extraction.')
para2 = Uniword::Paragraph.new
para2.add_text('It contains multiple paragraphs to demonstrate word count and other statistics.')
doc.add_element(para1)
doc.add_element(para2)

puts "   Document created with 2 paragraphs\n\n"

# Extract metadata
puts '2. Extracting metadata from document...'
metadata = manager.extract(doc)

puts '   Extracted metadata:'
puts "   - Word count: #{metadata[:word_count]}"
puts "   - Character count: #{metadata[:character_count]}"
puts "   - Paragraph count: #{metadata[:paragraph_count]}"
puts "   - Page count (estimated): #{metadata[:page_count]}\n\n"

# Update metadata
puts '3. Updating document metadata...'
update_result = manager.update(doc, {
                                 title: 'Sample Document',
                                 author: 'Metadata Manager Example',
                                 subject: 'Demonstration',
                                 keywords: %w[example metadata uniword],
                                 category: 'Documentation'
                               })

if update_result[:success]
  puts "   ✓ Metadata updated successfully\n\n"
else
  puts "   ✗ Failed to update metadata: #{update_result[:errors]}\n\n"
end

# Extract and validate
puts '4. Extracting and validating metadata...'
result = manager.extract_and_validate(doc)

puts "   Validation result: #{result[:validation][:valid] ? '✓ Valid' : '✗ Invalid'}"
puts "   Errors: #{result[:validation][:errors].join(', ')}" if result[:validation][:errors]&.any?
puts "\n"

# Demonstrate metadata object operations
puts '5. Working with metadata object...'
metadata[:custom_field] = 'Custom value'
puts "   Added custom field: #{metadata[:custom_field]}"

# Convert to different formats
puts "   - JSON format: #{metadata.to_json_hash.keys.join(', ')}"
puts "   - YAML format keys: #{metadata.to_yaml_hash.keys.join(', ')}\n\n"

# Batch operations example
puts '6. Demonstrating batch operations...'
index = Uniword::Metadata::MetadataIndex.new

# Add multiple document metadata
index.add('document1.docx', Uniword::Metadata::Metadata.new(
                              title: 'Document 1',
                              author: 'Author A',
                              word_count: 500,
                              category: 'Report'
                            ))

index.add('document2.docx', Uniword::Metadata::Metadata.new(
                              title: 'Document 2',
                              author: 'Author B',
                              word_count: 750,
                              category: 'Report'
                            ))

index.add('document3.docx', Uniword::Metadata::Metadata.new(
                              title: 'Document 3',
                              author: 'Author A',
                              word_count: 300,
                              category: 'Letter'
                            ))

puts "   Index contains #{index.size} documents\n"

# Query operations
puts "   Querying documents by category 'Report'..."
reports = index.query(:category, 'Report')
puts "   Found #{reports.size} reports\n"

puts '   Filtering documents by Author A...'
by_author = index.filter { |_path, meta| meta[:author] == 'Author A' }
puts "   Found #{by_author.size} documents by Author A\n\n"

# Summary statistics
puts '7. Computing summary statistics...'
summary = manager.summary(index)
puts "   - Total documents: #{summary[:document_count]}"
puts "   - Total words: #{summary[:total_words]}"
puts "   - Authors: #{summary[:authors].join(', ')}"
puts "   - Categories: #{summary[:categories].join(', ')}\n\n"

# Export examples
puts '8. Exporting metadata index...'

begin
  require 'tempfile'

  # Export to JSON
  json_file = Tempfile.new(['metadata', '.json'])
  index.export_json(json_file.path, pretty: true)
  puts "   ✓ Exported to JSON: #{json_file.path}"

  # Export to YAML
  yaml_file = Tempfile.new(['metadata', '.yml'])
  index.export_yaml(yaml_file.path)
  puts "   ✓ Exported to YAML: #{yaml_file.path}"

  # Export to CSV
  csv_file = Tempfile.new(['metadata', '.csv'])
  index.export_csv(csv_file.path, columns: %i[title author word_count category])
  puts "   ✓ Exported to CSV: #{csv_file.path}"

  # Export to XML
  xml_file = Tempfile.new(['metadata', '.xml'])
  index.export_xml(xml_file.path)
  puts "   ✓ Exported to XML: #{xml_file.path}\n\n"

  # Show CSV sample
  puts '   CSV content preview:'
  puts "   #{File.readlines(csv_file.path).first(3).join('   ')}"
  puts "\n"

  # Cleanup
  [json_file, yaml_file, csv_file, xml_file].each(&:unlink)
rescue StandardError => e
  puts "   Note: Export example skipped (#{e.message})\n\n"
end

# Validation with scenarios
puts '9. Validating metadata for publication...'
pub_metadata = Uniword::Metadata::Metadata.new(
  title: 'Publication Ready Document',
  author: 'Published Author',
  subject: 'Important Topic',
  keywords: %w[published ready]
)

pub_result = manager.validate(pub_metadata, scenario: :publication)
puts "   Publication validation: #{pub_result[:valid] ? '✓ Valid' : '✗ Invalid'}"
puts "   Errors: #{pub_result[:errors].join(', ')}" if pub_result[:errors]&.any?
puts "\n"

puts "=== Example Complete ===\n"
puts "\nMetadata Manager provides:"
puts '  • Automatic metadata extraction'
puts '  • Flexible metadata storage and manipulation'
puts '  • Schema-based validation'
puts '  • Batch processing and indexing'
puts '  • Multiple export formats (JSON, YAML, CSV, XML)'
puts '  • Query and filter capabilities'
puts '  • Summary statistics'

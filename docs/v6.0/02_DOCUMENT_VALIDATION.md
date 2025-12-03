# Feature 2: Document Validation Framework

## Objective

**Goal**: Validate if a file is a valid Word document according to OOXML specification.

**User Problem**:
- Files may be corrupted during transfer
- ZIP structure may be invalid
- Required OOXML parts may be missing
- XML may be malformed
- Relationships may be broken
- Content Types may be inconsistent

**Need**: Validate document integrity before processing to fail fast with clear errors

## Architecture Design

### Principle: Layered Validation

**Validation Layers** (MECE - each layer validates ONE aspect):

```
Layer 1: File Structure Validation
Layer 2: ZIP Integrity Validation
Layer 3: OOXML Part Validation
Layer 4: XML Schema Validation
Layer 5: Relationship Validation
Layer 6: Content Type Validation
Layer 7: Document Semantics Validation
```

### Implementation

```ruby
module Uniword
  module Validation
    # Document Validator - validate Word document integrity
    #
    # Responsibility: Validate document at all layers
    # Single Responsibility: Validation orchestration only
    #
    # External config: config/validation_rules.yml
    class DocumentValidator
      def initialize(config_file: 'config/validation_rules.yml')
        @config = load_config(config_file)
        @validators = initialize_validators
      end

      # Validate document file
      #
      # @param path [String] Path to .docx file
      # @return [ValidationReport] Detailed validation results
      def validate(path)
        report = ValidationReport.new(path)

        # Run validators in order (fail-fast if configured)
        @validators.each do |validator|
          next unless validator.enabled?

          result = validator.validate(path)
          report.add_layer_result(validator.layer_name, result)

          # Fail fast if critical layer fails
          break if result.critical_failure? && @config[:fail_fast]
        end

        report
      end

      # Quick validity check (boolean)
      def valid?(path)
        validate(path).valid?
      end

      private

      def initialize_validators
        [
          FileStructureValidator.new(@config),
          ZipIntegrityValidator.new(@config),
          OoxmlPartValidator.new(@config),
          XmlSchemaValidator.new(@config),
          RelationshipValidator.new(@config),
          ContentTypeValidator.new(@config),
          DocumentSemanticsValidator.new(@config)
        ]
      end
    end

    # Layer 1: File Structure Validator
    #
    # Responsibility: Validate file exists and is accessible
    # Single Responsibility: File-level validation only
    class FileStructureValidator < LayerValidator
      def layer_name
        'File Structure'
      end

      def validate(path)
        result = LayerValidationResult.new(layer_name)

        # Check file exists
        unless File.exist?(path)
          return result.add_error('File does not exist', critical: true)
        end

        # Check readable
        unless File.readable?(path)
          return result.add_error('File is not readable', critical: true)
        end

        # Check extension
        unless path.end_with?('.docx', '.doc')
          result.add_warning('Unusual file extension (expected .docx or .doc)')
        end

        # Check file size
        size = File.size(path)
        if size == 0
          result.add_error('File is empty', critical: true)
        elsif size > @config[:max_file_size]
          result.add_warning("File is very large (#{size} bytes)")
        end

        result
      end
    end

    # Layer 2: ZIP Integrity Validator
    #
    # Responsibility: Validate ZIP structure
    # Single Responsibility: ZIP validation only
    class ZipIntegrityValidator < LayerValidator
      def layer_name
        'ZIP Integrity'
      end

      def validate(path)
        result = LayerValidationResult.new(layer_name)

        begin
          # Try to open as ZIP
          Zip::File.open(path) do |zip_file|
            # Validate ZIP structure
            if zip_file.entries.empty?
              result.add_error('ZIP archive is empty', critical: true)
            end

            # Check for required entries
            required_entries = ['[Content_Types].xml', 'word/document.xml']
            required_entries.each do |entry_name|
              unless zip_file.find_entry(entry_name)
                result.add_error("Missing required file: #{entry_name}", critical: true)
              end
            end

            # Check for corrupted entries
            zip_file.entries.each do |entry|
              begin
                entry.get_input_stream { |io| io.read(1) }
              rescue => e
                result.add_error("Corrupted entry: #{entry.name} (#{e.message})")
              end
            end
          end
        rescue Zip::Error => e
          result.add_error("Invalid ZIP file: #{e.message}", critical: true)
        end

        result
      end
    end

    # Layer 3: OOXML Part Validator
    #
    # Responsibility: Validate required OOXML parts exist
    # Single Responsibility: Part existence validation only
    class OoxmlPartValidator < LayerValidator
      def layer_name
        'OOXML Parts'
      end

      def validate(path)
        result = LayerValidationResult.new(layer_name)

        Zip::File.open(path) do |zip|
          # Required parts (per ISO/IEC 29500)
          required_parts = {
            '[Content_Types].xml' => 'Content Types definition',
            'word/document.xml' => 'Main document content',
            '_rels/.rels' => 'Package relationships'
          }

          required_parts.each do |part_name, description|
            unless zip.find_entry(part_name)
              result.add_error("Missing #{description}: #{part_name}", critical: true)
            end
          end

          # Optional but common parts
          optional_parts = {
            'word/styles.xml' => 'Styles definition',
            'word/numbering.xml' => 'Numbering definition',
            'word/_rels/document.xml.rels' => 'Document relationships'
          }

          optional_parts.each do |part_name, description|
            unless zip.find_entry(part_name)
              result.add_info("Missing #{description}: #{part_name} (optional)")
            end
          end
        end

        result
      end
    end

    # Layer 4: XML Schema Validator
    #
    # Responsibility: Validate XML is well-formed
    # Single Responsibility: XML structure validation only
    class XmlSchemaValidator < LayerValidator
      def layer_name
        'XML Schema'
      end

      def validate(path)
        result = LayerValidationResult.new(layer_name)

        Zip::File.open(path) do |zip|
          # Validate each XML part
          zip.entries.select { |e| e.name.end_with?('.xml') }.each do |entry|
            xml_content = entry.get_input_stream.read

            begin
              doc = Nokogiri::XML(xml_content) { |config| config.strict }

              # Check for parsing errors
              unless doc.errors.empty?
                result.add_error("XML errors in #{entry.name}: #{doc.errors.first.message}")
              end
            rescue Nokogiri::XML::SyntaxError => e
              result.add_error("Malformed XML in #{entry.name}: #{e.message}")
            end
          end
        end

        result
      end
    end

    # Validation Report - aggregates all layer results
    class ValidationReport
      attr_reader :file_path, :layer_results

      def initialize(file_path)
        @file_path = file_path
        @layer_results = {}
      end

      def add_layer_result(layer_name, result)
        @layer_results[layer_name] = result
      end

      # Check if document is valid overall
      def valid?
        @layer_results.values.all?(&:valid?)
      end

      # Get all errors
      def errors
        @layer_results.values.flat_map(&:errors)
      end

      # Get all warnings
      def warnings
        @layer_results.values.flat_map(&:warnings)
      end

      # Has critical failures?
      def critical_failures?
        @layer_results.values.any?(&:critical_failures?)
      end

      # Generate summary
      def summary
        {
          valid: valid?,
          layers_validated: @layer_results.count,
          errors: errors.count,
          warnings: warnings.count,
          critical: critical_failures?
        }
      end

      # Export to JSON
      def to_json
        JSON.pretty_generate(summary.merge(
          layers: @layer_results.transform_values(&:to_h)
        ))
      end
    end
  end
end
```

### External Configuration (config/validation_rules.yml)

```yaml
document_validation:
  # General settings
  fail_fast: true              # Stop on first critical error
  max_file_size: 104857600     # 100MB

  # File structure validation
  file_structure:
    enabled: true
    check_extension: true
    check_size: true
    allowed_extensions: ['.docx', '.doc']

  # ZIP integrity validation
  zip_integrity:
    enabled: true
    check_entries: true
    check_corruption: true
    verify_compression: true

  # OOXML part validation
  ooxml_parts:
    enabled: true
    require_content_types: true
    require_document: true
    require_relationships: true
    warn_missing_optional: true

  # XML schema validation
  xml_schema:
    enabled: true
    strict_parsing: true
    check_encoding: true
    validate_namespaces: true

  # Relationship validation
  relationships:
    enabled: true
    check_targets_exist: true
    check_circular_refs: false
    validate_types: true

  # Content Type validation
  content_types:
    enabled: true
    check_consistency: true
    validate_extensions: true

  # Document semantics validation
  document_semantics:
    enabled: true
    check_required_elements: true
    validate_structure: true
    check_style_references: true
```

## File Structure

```
lib/uniword/validation/
  document_validator.rb              # NEW - Main orchestrator
  layer_validator.rb                # NEW - Base class for validators
  validation_report.rb              # NEW - Report aggregator
  layer_validation_result.rb        # NEW - Per-layer results

  validators/
    file_structure_validator.rb     # NEW - Layer 1
    zip_integrity_validator.rb      # NEW - Layer 2
    ooxml_part_validator.rb         # NEW - Layer 3
    xml_schema_validator.rb         # NEW - Layer 4
    relationship_validator.rb       # NEW - Layer 5
    content_type_validator.rb       # NEW - Layer 6
    document_semantics_validator.rb # NEW - Layer 7

spec/uniword/validation/
  document_validator_spec.rb         # NEW - Main tests
  layer_validator_spec.rb           # NEW - Base tests
  validation_report_spec.rb         # NEW - Report tests

  validators/
    file_structure_validator_spec.rb    # NEW
    zip_integrity_validator_spec.rb     # NEW
    ooxml_part_validator_spec.rb        # NEW
    xml_schema_validator_spec.rb        # NEW
    relationship_validator_spec.rb      # NEW
    content_type_validator_spec.rb      # NEW
    document_semantics_validator_spec.rb # NEW

spec/fixtures/validation/
  valid_document.docx                # NEW - Test fixtures
  missing_content_types.docx         # NEW
  corrupted_zip.docx                 # NEW
  malformed_xml.docx                 # NEW
  broken_relationships.docx          # NEW

config/
  validation_rules.yml               # NEW - External configuration
```

## Usage Example

```ruby
# Validate before processing
validator = Uniword::Validation::DocumentValidator.new

report = validator.validate('document.docx')

if report.valid?
  puts "Document is valid!"
  # Safe to process
  doc = Document.open('document.docx')
else
  puts "Document has issues:"
  puts "  Errors: #{report.errors.count}"
  puts "  Warnings: #{report.warnings.count}"

  report.errors.each do |error|
    puts "  [ERROR] #{error.layer}: #{error.message}"
  end

  # Don't process if critical failures
  if report.critical_failures?
    raise "Cannot process document - critical errors found"
  end
end

# Quick check
if validator.valid?('document.docx')
  # Process
end

# Export validation report
File.write('validation_report.json', report.to_json)
```

## Integration with Existing Code

```ruby
# DocumentFactory enhancement
class DocumentFactory
  def self.from_file(path, format: :auto, validate: false)
    # Optional validation before opening
    if validate
      validator = Validation::DocumentValidator.new
      report = validator.validate(path)

      unless report.valid?
        raise InvalidDocumentError.new(path, report.summary)
      end
    end

    # Existing code...
  end
end
```

## Success Criteria

- [ ] 7 layer validators implemented (MECE)
- [ ] ValidationReport with aggregation
- [ ] External YAML configuration
- [ ] Comprehensive test fixtures (5+ invalid documents)
- [ ] All validators have spec files
- [ ] 100% test coverage for validation
- [ ] Documentation with examples

## Architecture Benefits

✅ **MECE**: Each layer validates distinct aspect (no overlap)
✅ **Separation of Concerns**: Structure ≠ ZIP ≠ XML ≠ Relationships
✅ **Single Responsibility**: One validator = one layer
✅ **Open/Closed**: Add validators via configuration
✅ **External Configuration**: All rules in YAML
✅ **Fail-Fast**: Stop at first critical error (configurable)

## Timeline

**Total**: 2 weeks
- Week 1: Validators 1-4 (file, ZIP, parts, XML)
- Week 2: Validators 5-7 (relationships, content types, semantics)
- Testing throughout

This provides production-grade validation with clear, actionable error messages.
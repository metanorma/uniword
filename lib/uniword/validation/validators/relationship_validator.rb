# frozen_string_literal: true

require 'zip'
require 'nokogiri'
require_relative '../layer_validator'

module Uniword
  module Validation
    module Validators
      # Validates relationship integrity (targets exist, no broken refs).
      #
      # Responsibility: Validate relationship files and targets.
      # Single Responsibility: Only validates relationships.
      #
      # This is Layer 5 validation - validates that all relationship
      # files are valid and their targets exist.
      #
      # Checks:
      # - Relationship files are well-formed
      # - Relationship targets exist
      # - Relationship types are valid
      #
      # @example Validate relationships
      #   validator = RelationshipValidator.new(config)
      #   result = validator.validate('/path/to/document.docx')
      #   puts result.valid? # => true
      class RelationshipValidator < LayerValidator
        RELATIONSHIP_NAMESPACE = 'http://schemas.openxmlformats.org/package/2006/relationships'

        def layer_name
          'Relationships'
        end

        def validate(path)
          result = LayerValidationResult.new(layer_name)

          Zip::File.open(path) do |zip|
            validate_relationships(zip, result)
          end

          result
        rescue Zip::Error => e
          result.add_error(
            "Cannot open ZIP file: #{e.message}",
            critical: true
          )
          result
        end

        private

        def validate_relationships(zip, result)
          rel_entries = zip.entries.select { |e| e.name.end_with?('.rels') }

          if rel_entries.empty?
            result.add_warning('No relationship files found')
            return
          end

          rel_entries.each do |entry|
            validate_relationship_file(zip, entry, result)
          end
        end

        def validate_relationship_file(zip, entry, result)
          xml_content = entry.get_input_stream.read
          doc = Nokogiri::XML(xml_content)

          # Get the base directory for this .rels file
          base_dir = File.dirname(entry.name.sub('/_rels/', '/'))
          base_dir = '' if base_dir == '.'

          doc.xpath('//xmlns:Relationship', 'xmlns' => RELATIONSHIP_NAMESPACE).each do |rel|
            validate_relationship(zip, rel, base_dir, result)
          end
        rescue Nokogiri::XML::SyntaxError => e
          result.add_error(
            "Malformed relationship file #{entry.name}: #{e.message}"
          )
        rescue StandardError => e
          result.add_error(
            "Failed to validate #{entry.name}: #{e.message}"
          )
        end

        def validate_relationship(zip, rel_node, base_dir, result)
          target = rel_node['Target']
          type = rel_node['Type']
          target_mode = rel_node['TargetMode']

          # Skip external relationships
          return if target_mode == 'External'

          # Check if target exists
          if check_targets_exist? && target && !target.start_with?('#')
            target_path = resolve_target_path(base_dir, target)

            unless zip.find_entry(target_path)
              result.add_error(
                "Relationship target not found: #{target_path}"
              )
            end
          end

          # Validate relationship type
          if validate_types? && type
            validate_relationship_type(type, result)
          end
        end

        def resolve_target_path(base_dir, target)
          # Handle absolute paths (starting with /)
          return target[1..-1] if target.start_with?('/')

          # Handle relative paths
          if base_dir.empty?
            target
          else
            File.join(base_dir, target)
          end
        end

        def validate_relationship_type(type, result)
          # Just validate it's a URI-like string
          unless type.include?('/')
            result.add_warning(
              "Unusual relationship type: #{type}"
            )
          end
        end

        def check_targets_exist?
          layer_config[:check_targets_exist] != false
        end

        def validate_types?
          layer_config[:validate_types] != false
        end

        def layer_config
          @config[:relationships] || {}
        end
      end
    end
  end
end
# frozen_string_literal: true

require "yaml"

module Uniword
  module Generation
    # Extracts styles from DOCX files into serializable format.
    #
    # Reads styles from an existing DOCX via DocumentFactory and produces
    # a plain hash representation suitable for YAML serialization.
    #
    # @example Extract styles to hash
    #   styles = StyleExtractor.extract_from_docx("template.docx")
    #
    # @example Extract styles to YAML file
    #   StyleExtractor.extract_to_yaml("template.docx", "output.yml")
    class StyleExtractor
      # Extract styles from a DOCX file as a hash.
      #
      # @param docx_path [String] Path to source DOCX file
      # @return [Hash] Hash with :name and :styles keys
      # @raise [ArgumentError] if file does not exist
      def self.extract_from_docx(docx_path)
        validate_path(docx_path)

        doc = DocumentFactory.from_file(docx_path)
        config = doc.styles_configuration

        styles_data = config.styles.map do |style|
          style_to_hash(style)
        end

        {
          name: extract_name(docx_path),
          source_file: File.basename(docx_path),
          styles: styles_data
        }
      end

      # Extract styles from a DOCX file and write to YAML.
      #
      # @param docx_path [String] Path to source DOCX file
      # @param output_path [String] Path for output YAML file
      # @return [void]
      def self.extract_to_yaml(docx_path, output_path)
        data = extract_from_docx(docx_path)

        dir = File.dirname(output_path)
        FileUtils.mkdir_p(dir) unless Dir.exist?(dir)

        File.write(output_path, YAML.dump(stringify_keys(data)))
      end

      class << self
        private

        def validate_path(path)
          return if File.exist?(path)

          raise ArgumentError, "File not found: #{path}"
        end

        def extract_name(docx_path)
          File.basename(docx_path, ".*").gsub(/[_-]/, " ")
              .split.map(&:capitalize).join
        end

        def style_to_hash(style)
          data = { styleId: style.id }
          data[:name] = style.name&.val if style.name
          data[:type] = style.type if style.type
          data
        end

        def stringify_keys(hash)
          case hash
          when Hash
            hash.each_with_object({}) do |(k, v), result|
              result[k.to_s] = stringify_keys(v)
            end
          when Array
            hash.map { |item| stringify_keys(item) }
          else
            hash
          end
        end
      end
    end
  end
end

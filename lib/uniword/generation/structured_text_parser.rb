# frozen_string_literal: true

require "yaml"

module Uniword
  module Generation
    # Parses structured text files into content elements.
    #
    # Supports two input formats:
    # - YAML (.yml/.yaml): content array with element, text, style keys
    # - Markdown (.md): heading levels, notes, examples via conventions
    #
    # Returns an array of hashes, each with :element, :text, :style,
    # and optional :children keys.
    #
    # @example Parse YAML content
    #   elements = StructuredTextParser.parse("content.yml")
    #
    # @example Parse Markdown content
    #   elements = StructuredTextParser.parse("document.md")
    class StructuredTextParser
      # Parse a structured text file into content elements.
      #
      # @param input_path [String] Path to .yml, .yaml, or .md file
      # @return [Array<Hash>] Array of content element hashes
      # @raise [ArgumentError] if file format is unsupported
      def self.parse(input_path)
        validate_path(input_path)

        ext = File.extname(input_path).downcase
        content = File.read(input_path, encoding: "UTF-8")

        case ext
        when ".yml", ".yaml"
          parse_yaml(content)
        when ".md"
          parse_markdown(content)
        else
          raise ArgumentError,
                "Unsupported format: #{ext}. Use .yml, .yaml, or .md"
        end
      end

      class << self
        private

        def validate_path(path)
          return if File.exist?(path)

          raise ArgumentError, "File not found: #{path}"
        end

        def parse_yaml(content)
          data = YAML.safe_load(content)

          unless data.is_a?(Hash) && data["content"].is_a?(Array)
            raise ArgumentError,
                  "YAML must have a 'content' array at top level"
          end

          data["content"].map { |item| normalize_element(item) }
        end

        def parse_markdown(content)
          elements = []
          lines = content.lines(chomp: true)

          lines.each do |line|
            stripped = line.strip
            next if stripped.empty?
            next if stripped.start_with?("---")

            elements << parse_markdown_line(stripped)
          end

          elements
        end

        def parse_markdown_line(line)
          case line
          when /\A#{6}\s+(.+)/
            build_element("heading_6", $1.strip)
          when /\A#{5}\s+(.+)/
            build_element("heading_5", $1.strip)
          when /\A#{4}\s+(.+)/
            build_element("heading_4", $1.strip)
          when /\A#{3}\s+(.+)/
            build_element("heading_3", $1.strip)
          when /\A#{2}\s+(.+)/
            build_element("heading_2", $1.strip)
          when /\A#\s+(.+)/
            build_element("heading_1", $1.strip)
          when /\A>\s*(?:NOTE|Note)[:\s]*(.*)/
            text = $1.to_s.strip
            text = "NOTE" if text.empty?
            build_element("note", text)
          when /\A>\s*(?:EXAMPLE|Example)[:\s]*(.*)/
            text = $1.to_s.strip
            text = "EXAMPLE" if text.empty?
            build_element("example", text)
          when /\A>\s*(.+)/
            build_element("note", $1.strip)
          when /\A---\s*$/
            nil
          when /\A[*_-]{3,}\s*$/
            nil
          else
            build_element("body", line)
          end
        end

        def normalize_element(item)
          return build_element("body", "") unless item.is_a?(Hash)

          element = item["element"].to_s
          text = item["text"].to_s
          style = item["style"]

          result = { element: element, text: text }
          result[:style] = style if style
          result[:children] = item["children"] if item["children"]
          result
        end

        def build_element(element, text)
          { element: element, text: text }
        end
      end
    end
  end
end

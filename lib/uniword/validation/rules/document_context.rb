# frozen_string_literal: true

require "zip"
require "moxml"

module Uniword
  module Validation
    module Rules
      # Provides unified access to a DOCX package for validation rules.
      #
      # Lazy-loads and caches parsed XML parts. Rules use this to access
      # the document content without knowing about ZIP internals.
      #
      # @example Access a parsed part
      #   context.document_xml  # => Moxml::Document
      #   context.part_exists?("word/styles.xml")  # => true
      class DocumentContext
        W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
        R_NS = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
        RELS_NS = "http://schemas.openxmlformats.org/package/2006/relationships"
        CT_NS = "http://schemas.openxmlformats.org/package/2006/content-types"

        attr_reader :path

        # Initialize context for a DOCX file.
        #
        # @param path [String] Path to .docx file
        def initialize(path)
          @path = path
          @zip = nil
          @parsed_parts = {}
          @moxml = Moxml.new(:nokogiri)
        end

        # Open the ZIP archive.
        #
        # @return [Zip::File]
        def zip
          @zip ||= Zip::File.open(@path)
        end

        # Close the ZIP archive.
        def close
          @zip&.close
          @zip = nil
          @parsed_parts.clear
        end

        # List all entries in the ZIP.
        #
        # @return [Array<String>] Entry names
        def zip_entries
          zip.entries.map(&:name)
        end

        # Check if a part exists in the package.
        #
        # @param name [String] Part path (e.g., "word/document.xml")
        # @return [Boolean]
        def part_exists?(name)
          !!zip.find_entry(name)
        end

        # Get raw content of a part.
        #
        # @param name [String] Part path
        # @return [String, nil] Raw XML content
        def part_raw(name)
          entry = zip.find_entry(name)
          return nil unless entry

          entry.get_input_stream.read
        end

        # Get a parsed (Moxml) document for a part.
        # Results are cached.
        #
        # @param name [String] Part path
        # @return [Moxml::Document, nil]
        def part(name)
          return @parsed_parts[name] if @parsed_parts.key?(name)
          return @parsed_parts[name] = nil unless part_exists?(name)

          raw = part_raw(name)
          @parsed_parts[name] = raw ? @moxml.parse(raw) : nil
        rescue StandardError
          @parsed_parts[name] = nil
        end

        # Convenience: parsed word/document.xml
        def document_xml
          part("word/document.xml")
        end

        # Convenience: parsed word/styles.xml
        def styles_xml
          part("word/styles.xml")
        end

        # Convenience: parsed word/numbering.xml
        def numbering_xml
          part("word/numbering.xml")
        end

        # Convenience: parsed word/settings.xml
        def settings_xml
          part("word/settings.xml")
        end

        # Convenience: parsed word/fontTable.xml
        def font_table_xml
          part("word/fontTable.xml")
        end

        # Get all relationships from a .rels file.
        #
        # @param rels_path [String] Path to .rels file
        # @return [Array<Hash>] [{ id:, type:, target:, target_mode: }]
        def relationships(rels_path = "word/_rels/document.xml.rels")
          raw = part_raw(rels_path)
          return [] unless raw

          doc = Nokogiri::XML(raw)
          doc.xpath("//xmlns:Relationship", "xmlns" => RELS_NS).map do |rel|
            {
              id: rel["Id"],
              type: rel["Type"],
              target: rel["Target"],
              target_mode: rel["TargetMode"]
            }
          end
        end

        # Get all declared content types.
        #
        # @return [Hash] { extension => content_type, part_name => content_type }
        def content_types
          raw = part_raw("[Content_Types].xml")
          return {} unless raw

          doc = Nokogiri::XML(raw)
          types = {}

          doc.xpath("//xmlns:Default", "xmlns" => CT_NS).each do |node|
            types[node["Extension"]] = node["ContentType"] if node["Extension"]
          end

          doc.xpath("//xmlns:Override", "xmlns" => CT_NS).each do |node|
            types[node["PartName"]] = node["ContentType"] if node["PartName"]
          end

          types
        end

        # Collect all style IDs from styles.xml.
        #
        # @return [Set<String>] Style ID values
        def style_ids
          doc = styles_xml
          return Set.new unless doc

          ids = Set.new
          doc.root.xpath(".//w:style/@w:styleId", "w" => W_NS).each do |attr|
            ids << attr.value
          end
          ids
        end

        # Collect all numId values from numbering.xml.
        #
        # @return [Set<String>] numId values
        def numbering_ids
          doc = numbering_xml
          return Set.new unless doc

          ids = Set.new
          doc.root.xpath(".//w:num/@w:numId", "w" => W_NS).each do |attr|
            ids << attr.value
          end
          ids
        end
      end
    end
  end
end

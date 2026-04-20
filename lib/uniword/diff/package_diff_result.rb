# frozen_string_literal: true

require "json"

module Uniword
  module Diff
    # Value object holding a single XML change within a part.
    class XmlChange
      attr_reader :part, :category, :description

      def initialize(part:, category:, description:)
        @part = part
        @category = category
        @description = description
      end

      def to_h
        { part: @part, category: @category.to_s,
          description: @description }
      end
    end

    # Value object holding a changed part's metadata.
    class PartChange
      attr_reader :name, :old_size, :new_size
      attr_accessor :changes

      def initialize(name:, old_size:, new_size:, changes: [])
        @name = name
        @old_size = old_size
        @new_size = new_size
        @changes = changes
      end

      def size_delta
        @new_size - @old_size
      end

      def to_h
        result = {
          name: @name,
          old_size: @old_size,
          new_size: @new_size,
          size_delta: size_delta
        }
        result[:xml_changes] = @changes.map(&:to_h) if @changes.any?
        result
      end
    end

    # Value object holding the result of comparing two DOCX packages.
    #
    # Contains lists of added, removed, and modified ZIP parts, plus
    # detailed XML change descriptions for modified parts.
    #
    # @example
    #   result = PackageDiffer.new("bad.docx", "repaired.docx").diff
    #   puts result.summary
    #   puts result.to_json
    class PackageDiffResult
      attr_reader :old_path, :new_path,
                  :added_parts, :removed_parts,
                  :modified_parts, :unchanged_parts,
                  :xml_changes

      # Initialize a PackageDiffResult.
      #
      # @param old_path [String]
      # @param new_path [String]
      # @param added_parts [Array<String>]
      # @param removed_parts [Array<String>]
      # @param modified_parts [Array<PartChange>]
      # @param unchanged_parts [Array<String>]
      # @param xml_changes [Array<XmlChange>]
      def initialize(old_path:, new_path:,
                     added_parts:, removed_parts:,
                     modified_parts:, unchanged_parts:,
                     xml_changes:)
        @old_path = old_path
        @new_path = new_path
        @added_parts = added_parts
        @removed_parts = removed_parts
        @modified_parts = modified_parts
        @unchanged_parts = unchanged_parts
        @xml_changes = xml_changes
      end

      # Whether the two packages are identical.
      #
      # @return [Boolean]
      def empty?
        added_parts.empty? && removed_parts.empty? &&
          modified_parts.empty?
      end

      # Total number of changes.
      #
      # @return [Integer]
      def total_changes
        added_parts.size + removed_parts.size + modified_parts.size
      end

      # Human-readable summary.
      #
      # @return [String]
      def summary
        return "No differences found." if empty?

        parts = []
        parts << "#{added_parts.size} part(s) added" if added_parts.any?
        parts << "#{removed_parts.size} part(s) removed" if removed_parts.any?
        parts << "#{modified_parts.size} part(s) modified" if modified_parts.any?
        parts.join(", ")
      end

      # Serialize to JSON string.
      #
      # @return [String]
      def to_json(*_args)
        JSON.pretty_generate(to_h)
      end

      # Convert to plain Hash.
      #
      # @return [Hash]
      def to_h
        {
          old_path: @old_path,
          new_path: @new_path,
          summary: summary,
          added_parts: @added_parts,
          removed_parts: @removed_parts,
          modified_parts: @modified_parts.map(&:to_h),
          unchanged_count: @unchanged_parts.size,
          xml_changes: @xml_changes.map(&:to_h)
        }
      end
    end
  end
end

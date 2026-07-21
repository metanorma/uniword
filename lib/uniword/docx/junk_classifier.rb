# frozen_string_literal: true

module Uniword
  module Docx
    # Classify a package-relative path as junk or legitimate.
    #
    # Used by `Docx::PartLoader::RawPartLoader` to decide which
    # unclaimed ZIP entries to carry as `RawPart` and which to strip.
    # The classifier is the single source of truth for the junk
    # decision — adding new criteria means changing this class (or its
    # pattern constants), not the loader.
    #
    # Classification is two-armed:
    #
    # 1. *OS/tooling artifact* — path matches a known pattern
    #    (`__MACOSX/`, `.DS_Store`, `Thumbs.db`, `._*`, `~$*`). These
    #    are never legitimate document content; matched unconditionally
    #    even when a Default content type happens to apply.
    #
    # 2. *Undeclared part* — no Override and no Default extension match
    #    in the loaded `ContentTypes::Types`, AND no modelled
    #    relationship targets the path. This is the OPC rule: every
    #    part must have a content type declaration.
    #
    # Both arms return a human-readable reason string; the loader
    # records it on `Package#stripped_parts` for caller introspection.
    #
    # @example
    #   classifier = JunkClassifier.new(
    #     content_types: package.content_types,
    #     relationships_by_path: rel_targets,
    #   )
    #   classifier.reason("[trash]/0000.dat")
    #   # => "No content type declaration and no referencing relationship"
    #   classifier.reason("word/document.xml") # => nil
    class JunkClassifier
      # Path patterns for OS / tooling artifacts that are never
      # legitimate document content. Append to extend; the classifier
      # iterates them in order.
      OS_ARTIFACT_PATTERNS = [
        /\A__MACOSX\//,         # macOS zip metadata directory
        /\A\.DS_Store\z/,       # macOS Finder
        /Thumbs\.db\z/,         # Windows Explorer
        /\A\._/,                # macOS AppleDouble resource fork
        /\A~\$/,                # Office lock files
      ].freeze

      OS_ARTIFACT_REASON = "OS or tooling artifact"

      UNDECLARED_REASON =
        "No content type declaration and no referencing relationship"

      # @param content_types [ContentTypes::Types, nil] the loaded
      #   content types model (nil when absent — every path is then
      #   undeclared unless a relationship targets it)
      # @param relationships_by_path [Hash{String => true}, nil] set of
      #   paths targeted by some modelled relationship. Encoded as a
      #   hash for O(1) lookup; nil means "no relationships recorded"
      def initialize(content_types:, relationships_by_path: nil)
        @content_types = content_types
        @relationships_by_path = relationships_by_path || {}
      end

      # @param path [String] package-relative path
      # @return [String, nil] reason string when the path is junk;
      #   nil when it is legitimate
      def reason(path)
        os_artifact_reason(path) || undeclared_reason(path)
      end

      # @param path [String] package-relative path
      # @return [Boolean] true when the path is junk
      def junk?(path)
        !reason(path).nil?
      end

      private

      def os_artifact_reason(path)
        OS_ARTIFACT_REASON if OS_ARTIFACT_PATTERNS.any? do |pattern|
          pattern.match?(path)
        end
      end

      def undeclared_reason(path)
        return nil if content_type_declared?(path)
        return nil if referenced_by_relationship?(path)

        UNDECLARED_REASON
      end

      def content_type_declared?(path)
        @content_types&.content_type_for(path)
      end

      def referenced_by_relationship?(path)
        @relationships_by_path.key?(path)
      end
    end
  end
end

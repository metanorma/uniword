# frozen_string_literal: true

module Uniword
  module Assembly
    # Resolves cross-references and bookmark links in assembled documents.
    #
    # Responsibility: Update cross-references during document assembly.
    # Single Responsibility: Only handles reference resolution.
    #
    # The CrossReferenceResolver:
    # - Resolves bookmark references
    # - Updates cross-reference fields
    # - Handles page number references
    # - Maintains reference integrity
    # - Supports inter-component references
    #
    # @example Basic resolution
    #   resolver = CrossReferenceResolver.new
    #   resolver.resolve(document)
    #
    # @example With bookmark mapping
    #   resolver = CrossReferenceResolver.new
    #   resolver.add_bookmark_mapping('old_id', 'new_id')
    #   resolver.resolve(document)
    class CrossReferenceResolver
      # @return [Hash] Bookmark ID mappings
      attr_reader :bookmark_mappings

      # Initialize resolver.
      #
      # @example Create resolver
      #   resolver = CrossReferenceResolver.new
      def initialize
        @bookmark_mappings = {}
        @bookmark_registry = {}
      end

      # Resolve cross-references in document.
      #
      # @param document [Document] Document to process
      # @return [Document] Document with resolved references
      #
      # @example Resolve references
      #   resolver.resolve(document)
      def resolve(document)
        # First pass: collect all bookmarks
        collect_bookmarks(document)

        # Second pass: resolve references
        resolve_references(document)

        document
      end

      # Add bookmark ID mapping.
      #
      # @param old_id [String] Original bookmark ID
      # @param new_id [String] New bookmark ID
      # @return [void]
      #
      # @example Add mapping
      #   resolver.add_bookmark_mapping('intro', 'section_1_intro')
      def add_bookmark_mapping(old_id, new_id)
        @bookmark_mappings[old_id] = new_id
      end

      # Check if bookmark exists.
      #
      # @param bookmark_id [String] Bookmark ID
      # @return [Boolean] True if bookmark exists
      def bookmark_exists?(bookmark_id)
        resolved_id = resolve_bookmark_id(bookmark_id)
        @bookmark_registry.key?(resolved_id)
      end

      # Get bookmark by ID.
      #
      # @param bookmark_id [String] Bookmark ID
      # @return [Bookmark, nil] Bookmark or nil
      def get_bookmark(bookmark_id)
        resolved_id = resolve_bookmark_id(bookmark_id)
        @bookmark_registry[resolved_id]
      end

      # List all bookmarks.
      #
      # @return [Array<String>] Bookmark IDs
      def bookmark_ids
        @bookmark_registry.keys
      end

      # Clear all mappings and registry.
      #
      # @return [void]
      def clear
        @bookmark_mappings.clear
        @bookmark_registry.clear
      end

      private

      # Collect bookmarks from document.
      #
      # @param document [Document] Source document
      # @return [void]
      def collect_bookmarks(document)
        document.paragraphs.each do |paragraph|
          collect_paragraph_bookmarks(paragraph)
        end
      end

      # Collect bookmarks from paragraph.
      #
      # @param paragraph [Paragraph] Source paragraph
      # @return [void]
      def collect_paragraph_bookmarks(paragraph)
        paragraph.bookmark_starts.each do |bookmark|
          @bookmark_registry[bookmark.id] = bookmark
        end
      end

      # Resolve references in document.
      #
      # @param document [Document] Document to process
      # @return [void]
      def resolve_references(document)
        document.paragraphs.each do |paragraph|
          resolve_paragraph_references(paragraph)
        end
      end

      # Resolve references in paragraph.
      #
      # @param paragraph [Paragraph] Source paragraph
      # @return [void]
      def resolve_paragraph_references(paragraph)
        paragraph.hyperlinks.each do |hyperlink|
          resolve_hyperlink(hyperlink)
        end

        paragraph.simple_fields.each do |field|
          resolve_field(field)
        end
      end

      # Resolve hyperlink reference.
      #
      # @param hyperlink [Hyperlink] Hyperlink to resolve
      # @return [void]
      def resolve_hyperlink(hyperlink)
        return unless hyperlink.anchor

        # Resolve bookmark reference
        resolved_id = resolve_bookmark_id(hyperlink.anchor)

        # Update if mapping exists
        return unless resolved_id != hyperlink.anchor

        hyperlink.anchor = resolved_id
      end

      # Resolve field reference.
      #
      # @param field [Field] Field to resolve
      # @return [void]
      def resolve_field(field)
        return unless field.field_type == "REF"
        return unless field.bookmark_name

        # Resolve bookmark reference
        resolved_id = resolve_bookmark_id(field.bookmark_name)

        # Update if mapping exists
        return unless resolved_id != field.bookmark_name

        field.bookmark_name = resolved_id
      end

      # Resolve bookmark ID through mappings.
      #
      # @param bookmark_id [String] Original ID
      # @return [String] Resolved ID
      def resolve_bookmark_id(bookmark_id)
        @bookmark_mappings[bookmark_id] || bookmark_id
      end
    end
  end
end

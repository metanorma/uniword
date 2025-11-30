# frozen_string_literal: true

require_relative '../link_checker'

module Uniword
  module Validation
    module Checkers
      # Validates internal bookmark links and anchors.
      #
      # Responsibility: Validate internal document bookmarks exist.
      # Single Responsibility: Internal link validation only.
      #
      # Verifies:
      # - Bookmark targets exist in document
      # - Anchor names are valid
      # - Case sensitivity (configurable)
      #
      # Configuration options:
      # - case_sensitive: Whether bookmark names are case-sensitive
      # - check_heading_links: Whether to check heading bookmark references
      #
      # @example Create and use checker
      #   checker = InternalLinkChecker.new(config: {
      #     case_sensitive: false
      #   })
      #   result = checker.check(hyperlink, document)
      class InternalLinkChecker < LinkChecker
        # Default configuration values
        DEFAULTS = {
          case_sensitive: false,
          check_heading_links: true
        }.freeze

        # Check if this checker can validate the given link.
        #
        # @param link [Object] The link to check
        # @return [Boolean] true if link has an anchor but no URL
        #
        # @example
        #   checker.can_check?(hyperlink) # => true
        def can_check?(link)
          return false unless enabled?
          return false unless link.respond_to?(:anchor)

          # Internal links have anchor but no URL
          link.anchor && !link.respond_to?(:url).then do |has_url|
            has_url ? !link.url : true
          end
        end

        # Validate the internal link.
        #
        # @param link [Object] The link to validate
        # @param document [Object] The document containing bookmarks
        # @return [ValidationResult] The validation result
        #
        # @example
        #   result = checker.check(hyperlink, document)
        def check(link, document = nil)
          return ValidationResult.unknown(link, 'Checker disabled') unless enabled?

          unless document
            return ValidationResult.warning(
              link,
              'Cannot validate without document context'
            )
          end

          anchor = link.anchor
          return ValidationResult.failure(link, 'No anchor specified') unless anchor

          # Get bookmarks from document
          bookmarks = extract_bookmarks(document)

          # Check if bookmark exists
          if bookmark_exists?(anchor, bookmarks)
            ValidationResult.success(
              link,
              metadata: { anchor: anchor, bookmark_count: bookmarks.size }
            )
          else
            # Try to find similar bookmarks for suggestions
            suggestions = find_similar_bookmarks(anchor, bookmarks)
            message = "Bookmark not found: #{anchor}"
            message += ". Did you mean: #{suggestions.join(', ')}?" if suggestions.any?

            ValidationResult.failure(
              link,
              message,
              metadata: { anchor: anchor, suggestions: suggestions }
            )
          end
        end

        private

        # Extract bookmarks from document.
        #
        # @param document [Object] The document
        # @return [Array<String>] Bookmark names
        def extract_bookmarks(document)
          bookmarks = []

          # Extract from document.bookmarks if available
          if document.respond_to?(:bookmarks)
            case document.bookmarks
            when Hash
              bookmarks.concat(document.bookmarks.keys.map(&:to_s))
            when Array
              bookmarks.concat(document.bookmarks.map do |b|
                b.respond_to?(:name) ? b.name : b.to_s
              end)
            end
          end

          # Extract heading bookmarks if enabled
          if config_value(:check_heading_links, DEFAULTS[:check_heading_links])
            bookmarks.concat(extract_heading_bookmarks(document))
          end

          bookmarks.compact.uniq
        end

        # Extract heading bookmarks from document.
        #
        # @param document [Object] The document
        # @return [Array<String>] Heading bookmark names
        def extract_heading_bookmarks(document)
          return [] unless document.respond_to?(:paragraphs)

          document.paragraphs.select do |p|
            p.respond_to?(:style) && p.style&.match?(/^Heading/)
          end.map do |p|
            # Generate bookmark from heading text
            p.respond_to?(:text) ? heading_to_bookmark(p.text) : nil
          end.compact
        end

        # Convert heading text to bookmark name.
        #
        # @param text [String] Heading text
        # @return [String] Bookmark name
        def heading_to_bookmark(text)
          text.to_s.downcase.gsub(/[^a-z0-9_-]/, '_')
        end

        # Check if bookmark exists in list.
        #
        # @param anchor [String] Anchor name
        # @param bookmarks [Array<String>] Available bookmarks
        # @return [Boolean] true if bookmark exists
        def bookmark_exists?(anchor, bookmarks)
          case_sensitive = config_value(:case_sensitive, DEFAULTS[:case_sensitive])

          if case_sensitive
            bookmarks.include?(anchor)
          else
            bookmarks.any? { |b| b.casecmp?(anchor) }
          end
        end

        # Find similar bookmarks for suggestions.
        #
        # @param anchor [String] Anchor name
        # @param bookmarks [Array<String>] Available bookmarks
        # @return [Array<String>] Similar bookmark names
        def find_similar_bookmarks(anchor, bookmarks)
          case_sensitive = config_value(:case_sensitive, DEFAULTS[:case_sensitive])
          anchor_norm = case_sensitive ? anchor : anchor.downcase

          # Find bookmarks that partially match
          # Limit to 3 suggestions
          bookmarks.select do |b|
            b_norm = case_sensitive ? b : b.downcase
            b_norm.include?(anchor_norm) || anchor_norm.include?(b_norm)
          end.take(3)
        end
      end
    end
  end
end

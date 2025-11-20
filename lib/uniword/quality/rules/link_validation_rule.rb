# frozen_string_literal: true

require_relative '../quality_rule'

module Uniword
  module Quality
    # Checks for broken or invalid links.
    #
    # Responsibility: Validate hyperlinks in document.
    # Single Responsibility - only checks link validity.
    #
    # Validates:
    # - Internal links point to valid bookmarks
    # - External links have proper format
    # - Links are not broken (optional network check)
    #
    # @example Configuration
    #   link_validation:
    #     enabled: true
    #     check_internal: true
    #     check_external: false
    class LinkValidationRule < QualityRule
      def initialize(config = {})
        super
        @check_internal = @config.fetch(:check_internal, true)
        @check_external = @config.fetch(:check_external, false)
      end

      # Check document for link validation violations
      #
      # @param document [Document] The document to check
      # @return [Array<QualityViolation>] List of violations found
      def check(document)
        violations = []

        link_count = 0
        document.paragraphs.each_with_index do |para, para_index|
          para.hyperlinks.each do |link|
            link_count += 1

            # Check internal links (anchors/bookmarks)
            if @check_internal && internal_link?(link)
              unless valid_internal_link?(link, document)
                violations << create_violation(
                  severity: :error,
                  message: "Internal link #{link_count} references non-existent bookmark '#{link.anchor}'",
                  location: "Paragraph #{para_index + 1}, Link #{link_count}",
                  element: link
                )
              end
            end

            # Check external links
            if @check_external && external_link?(link)
              unless valid_url?(link.url)
                violations << create_violation(
                  severity: :warning,
                  message: "External link #{link_count} has invalid URL format: '#{link.url}'",
                  location: "Paragraph #{para_index + 1}, Link #{link_count}",
                  element: link
                )
              end
            end
          end
        end

        violations
      end

      private

      # Check if link is internal (bookmark reference)
      #
      # @param link [Hyperlink] The link to check
      # @return [Boolean] true if internal link
      def internal_link?(link)
        link.respond_to?(:anchor) && !link.anchor.nil? && !link.anchor.empty?
      end

      # Check if link is external (URL)
      #
      # @param link [Hyperlink] The link to check
      # @return [Boolean] true if external link
      def external_link?(link)
        link.respond_to?(:url) && !link.url.nil? && !link.url.empty?
      end

      # Validate internal link points to existing bookmark
      #
      # @param link [Hyperlink] The link to validate
      # @param document [Document] The document
      # @return [Boolean] true if bookmark exists
      def valid_internal_link?(link, document)
        return true unless link.anchor

        # Check if bookmark exists in document
        document.bookmarks.key?(link.anchor) ||
          document.bookmarks.key?(link.anchor.to_sym)
      end

      # Validate URL format
      #
      # @param url [String] The URL to validate
      # @return [Boolean] true if URL format is valid
      def valid_url?(url)
        return false if url.nil? || url.empty?

        # Basic URL format validation
        # Accepts http://, https://, mailto:, ftp://, etc.
        uri_pattern = %r{\A(https?|ftp|mailto)://}i
        url.match?(uri_pattern) || url.start_with?('mailto:')
      end
    end
  end
end
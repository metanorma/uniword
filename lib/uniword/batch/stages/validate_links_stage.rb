# frozen_string_literal: true

require_relative '../processing_stage'

module Uniword
  module Batch
    # Processing stage that validates document links.
    #
    # Responsibility: Check and report broken internal and external links.
    # Single Responsibility - only handles link validation.
    #
    # @example Use in pipeline
    #   stage = ValidateLinksStage.new(
    #     check_internal: true,
    #     check_external: false,
    #     report_broken: true
    #   )
    #   document = stage.process(document, context)
    class ValidateLinksStage < ProcessingStage
      # Initialize validate links stage
      #
      # @param options [Hash] Stage options
      # @option options [Boolean] :check_internal Check internal links
      # @option options [Boolean] :check_external Check external links
      # @option options [Boolean] :check_bookmarks Check bookmark references
      # @option options [Boolean] :report_broken Report broken links
      # @option options [String] :broken_link_action Action for broken links ('report', 'remove', 'disable')
      def initialize(options = {})
        super(options)
        @check_internal = options.fetch(:check_internal, true)
        @check_external = options.fetch(:check_external, false)
        @check_bookmarks = options.fetch(:check_bookmarks, true)
        @report_broken = options.fetch(:report_broken, true)
        @broken_link_action = options.fetch(:broken_link_action, 'report')
      end

      # Process document to validate links
      #
      # @param document [Document] Document to process
      # @param context [Hash] Processing context
      # @return [Document] Processed document
      def process(document, context = {})
        log "Validating links in #{context[:filename]}"

        broken_links = []

        # Collect all hyperlinks
        hyperlinks = collect_hyperlinks(document)

        # Validate each hyperlink
        hyperlinks.each do |link|
          next unless should_validate_link?(link)

          if link_is_broken?(link, document)
            broken_links << link
            handle_broken_link(link, document)
          end
        end

        # Report results
        if @report_broken && broken_links.any?
          log "Found #{broken_links.size} broken link(s)", level: :warn
          broken_links.each do |link|
            log "  - #{link[:type]}: #{link[:target]}", level: :warn
          end
        else
          log "All links valid"
        end

        document
      end

      # Get stage description
      #
      # @return [String] Description
      def description
        "Validate document links"
      end

      private

      # Collect all hyperlinks from document
      #
      # @param document [Document] Document to scan
      # @return [Array<Hash>] Array of link information
      def collect_hyperlinks(document)
        links = []

        # Scan paragraphs for hyperlinks
        document.paragraphs.each do |paragraph|
          paragraph.runs.each do |run|
            next unless run.is_a?(Uniword::Hyperlink)

            links << {
              type: determine_link_type(run),
              target: run.target || run.anchor,
              element: run,
              text: run.text
            }
          end
        end

        links
      end

      # Determine link type
      #
      # @param hyperlink [Hyperlink] Hyperlink element
      # @return [Symbol] Link type (:internal, :external, :bookmark)
      def determine_link_type(hyperlink)
        if hyperlink.anchor
          :bookmark
        elsif hyperlink.target && hyperlink.target.start_with?('#')
          :internal
        elsif hyperlink.target && (hyperlink.target.start_with?('http://') || hyperlink.target.start_with?('https://'))
          :external
        else
          :internal
        end
      end

      # Check if link should be validated
      #
      # @param link [Hash] Link information
      # @return [Boolean] true if should validate
      def should_validate_link?(link)
        case link[:type]
        when :internal
          @check_internal
        when :external
          @check_external
        when :bookmark
          @check_bookmarks
        else
          false
        end
      end

      # Check if link is broken
      #
      # @param link [Hash] Link information
      # @param document [Document] Document to check against
      # @return [Boolean] true if link is broken
      def link_is_broken?(link, document)
        case link[:type]
        when :bookmark
          !bookmark_exists?(link[:target], document)
        when :internal
          # Internal link validation would check if target exists
          false # Placeholder - would need document structure analysis
        when :external
          # External link validation would make HTTP request
          false # Placeholder - disabled by default for performance
        else
          false
        end
      end

      # Check if bookmark exists in document
      #
      # @param bookmark_name [String] Bookmark name
      # @param document [Document] Document to check
      # @return [Boolean] true if bookmark exists
      def bookmark_exists?(bookmark_name, document)
        return true unless document.respond_to?(:bookmarks)
        return true if document.bookmarks.nil?

        document.bookmarks.any? { |b| b.name == bookmark_name }
      end

      # Handle broken link
      #
      # @param link [Hash] Link information
      # @param document [Document] Document containing the link
      def handle_broken_link(link, document)
        case @broken_link_action
        when 'report'
          # Just report - no action needed
        when 'remove'
          remove_link(link)
        when 'disable'
          disable_link(link)
        end
      end

      # Remove broken link
      #
      # @param link [Hash] Link information
      def remove_link(link)
        # Would remove the hyperlink element
        # Placeholder - actual implementation depends on document structure
        log "Would remove link: #{link[:target]}", level: :info
      end

      # Disable broken link
      #
      # @param link [Hash] Link information
      def disable_link(link)
        # Would disable the hyperlink (keep text, remove link)
        # Placeholder - actual implementation depends on document structure
        log "Would disable link: #{link[:target]}", level: :info
      end
    end
  end
end
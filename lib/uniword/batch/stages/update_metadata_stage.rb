# frozen_string_literal: true

require_relative '../processing_stage'

module Uniword
  module Batch
    # Processing stage that updates document metadata.
    #
    # Responsibility: Update document properties and metadata.
    # Single Responsibility - only handles metadata updates.
    #
    # @example Use in pipeline
    #   stage = UpdateMetadataStage.new(
    #     update_author: true,
    #     update_modified_date: true,
    #     author: 'John Doe'
    #   )
    #   document = stage.process(document, context)
    class UpdateMetadataStage < ProcessingStage
      # Initialize update metadata stage
      #
      # @param options [Hash] Stage options
      # @option options [Boolean] :update_author Update author
      # @option options [Boolean] :update_modified_date Update modified date
      # @option options [Boolean] :update_revision_number Update revision number
      # @option options [String] :author Specific author name
      # @option options [String] :company Company name
      # @option options [String] :title Document title
      def initialize(options = {})
        super(options)
        @update_author = options.fetch(:update_author, true)
        @update_modified_date = options.fetch(:update_modified_date, true)
        @update_revision_number = options.fetch(:update_revision_number, true)
        @author = options[:author]
        @company = options[:company]
        @title = options[:title]
      end

      # Process document to update metadata
      #
      # @param document [Document] Document to process
      # @param context [Hash] Processing context
      # @return [Document] Processed document
      def process(document, context = {})
        log "Updating metadata in #{context[:filename]}"

        update_core_properties(document)
        update_extended_properties(document) if @company

        log "Metadata update complete"
        document
      end

      # Get stage description
      #
      # @return [String] Description
      def description
        "Update document metadata"
      end

      private

      # Update core document properties
      #
      # @param document [Document] Document to update
      def update_core_properties(document)
        # Note: Actual implementation depends on Document API
        # This is a placeholder that shows the intended structure

        if @update_author && document.respond_to?(:author=)
          document.author = @author || current_user
        end

        if @update_modified_date && document.respond_to?(:modified_date=)
          document.modified_date = Time.now
        end

        if @update_revision_number && document.respond_to?(:revision=)
          current_revision = document.respond_to?(:revision) ? document.revision : 0
          document.revision = (current_revision.to_i + 1).to_s
        end

        if @title && document.respond_to?(:title=)
          document.title = @title
        end
      end

      # Update extended document properties
      #
      # @param document [Document] Document to update
      def update_extended_properties(document)
        if @company && document.respond_to?(:company=)
          document.company = @company
        end
      end

      # Get current user name
      #
      # @return [String] Current user name
      def current_user
        ENV['USER'] || ENV['USERNAME'] || 'Unknown'
      end
    end
  end
end
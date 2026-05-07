# frozen_string_literal: true

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
        super
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
        return unless document.is_a?(Uniword::Wordprocessingml::DocumentRoot)

        cp = document.core_properties

        if @update_author
          cp.creator = Uniword::Ooxml::Types::DcCreatorType.new(
            @author || current_user,
          )
        end

        if @update_modified_date
          cp.modified = Uniword::Ooxml::Types::DctermsModifiedType.new(
            value: Time.now.to_s,
            type: "dcterms:W3CDTF",
          )
        end

        if @update_revision_number
          current = cp.revision.to_i
          cp.revision = Uniword::Ooxml::Types::CpRevisionType.new(
            (current + 1).to_s,
          )
        end

        return unless @title

        cp.title = Uniword::Ooxml::Types::DcTitleType.new(@title)
      end

      # Update extended document properties
      #
      # @param document [Document] Document to update
      def update_extended_properties(document)
        return unless @company && document.is_a?(Uniword::Wordprocessingml::DocumentRoot)

        app = document.app_properties
        return unless app

        app.company = @company
      end

      # Get current user name
      #
      # @return [String] Current user name
      def current_user
        ENV["USER"] || ENV["USERNAME"] || "Unknown"
      end
    end
  end
end

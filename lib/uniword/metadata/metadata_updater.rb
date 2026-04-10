# frozen_string_literal: true

# All classes autoloaded via lib/uniword/metadata.rb and lib/uniword/configuration.rb

module Uniword
  module Metadata
    # Updates document properties with metadata values.
    #
    # Responsibility: Update document properties from metadata.
    # Single Responsibility: Only handles metadata updates to documents.
    #
    # The MetadataUpdater:
    # - Updates core document properties
    # - Updates extended document properties
    # - Handles type conversions appropriately
    # - Validates update values before applying
    #
    # Does NOT handle: Extraction, validation, or indexing.
    # Those responsibilities belong to separate classes.
    #
    # @example Update document metadata
    #   updater = MetadataUpdater.new
    #   updater.update(document, {
    #     title: "New Title",
    #     author: "New Author"
    #   })
    #
    # @example Update with Metadata object
    #   metadata = Metadata.new(title: "Title", author: "Author")
    #   updater.update(document, metadata)
    class MetadataUpdater
      # Initialize a new MetadataUpdater.
      #
      # @example Create updater
      #   updater = MetadataUpdater.new
      def initialize
        # No configuration needed for updater
      end

      # Update document properties with metadata.
      #
      # @param document [Document] The document to update
      # @param metadata [Metadata, Hash] Metadata to apply
      # @return [void]
      # @raise [ArgumentError] if document is not valid
      #
      # @example Update document
      #   updater.update(document, {
      #     title: "New Title",
      #     author: "Jane Doe",
      #     keywords: ["ISO", "Standard"]
      #   })
      def update(document, metadata)
        validate_document(document)

        # Convert to Metadata if Hash
        meta = metadata.is_a?(Metadata) ? metadata : Metadata.new(metadata)

        # Update different property categories
        update_core_properties(document, meta)
        update_extended_properties(document, meta)
      end

      # Update document with only specified properties.
      #
      # @param document [Document] The document to update
      # @param properties [Hash] Properties to update
      # @return [void]
      #
      # @example Update specific properties
      #   updater.update_properties(document, {
      #     title: "New Title",
      #     author: "New Author"
      #   })
      def update_properties(document, properties)
        update(document, properties)
      end

      # Clear specific properties from document.
      #
      # @param document [Document] The document
      # @param keys [Array<Symbol, String>] Property keys to clear
      # @return [void]
      #
      # @example Clear properties
      #   updater.clear_properties(document, [:title, :author])
      def clear_properties(document, keys)
        keys.each do |key|
          clear_property(document, key.to_sym)
        end
      end

      private

      # Validate document.
      #
      # @param document [Object] The document to validate
      # @raise [ArgumentError] if document is invalid
      def validate_document(document)
        return if document.is_a?(Object)

        raise ArgumentError,
              "Document must be an object, got #{document.class}"
      end

      # Update core properties.
      #
      # @param document [Document] The document
      # @param metadata [Metadata] Metadata to apply
      def update_core_properties(document, metadata)
        core_props = document.core_properties

        # Update each core property using method access
        core_props.title = metadata[:title] if metadata[:title]
        core_props.subject = metadata[:subject] if metadata[:subject]
        core_props.keywords = metadata[:keywords] if metadata[:keywords]
        core_props.description = metadata[:description] if metadata[:description]
        core_props.creator = metadata[:creator] if metadata[:creator]
        core_props.last_modified_by = metadata[:last_modified_by] if metadata[:last_modified_by]

        # Handle created_at and modified_at which map to created/modified
        if metadata[:created_at]
          core_props.created ||= Uniword::Ooxml::Types::DctermsCreatedType.new
          core_props.created.value = metadata[:created_at]
        end
        return unless metadata[:modified_at]

        core_props.modified ||= Uniword::Ooxml::Types::DctermsModifiedType.new
        core_props.modified.value = metadata[:modified_at]
      end

      # Update extended properties.
      #
      # @param document [Document] The document
      # @param metadata [Metadata] Metadata to apply
      def update_extended_properties(document, metadata)
        # Initialize extended_properties hash if not present
        unless document.respond_to?(:extended_properties)
          # Add extended_properties accessor if document doesn't have it
          document.instance_variable_set(:@extended_properties, {})
          document.define_singleton_method(:extended_properties) do
            @extended_properties
          end
          document.define_singleton_method(:extended_properties=) do |props|
            @extended_properties = props
          end
        end

        ext_props = document.extended_properties || {}

        # Update each extended property
        update_if_present(ext_props, metadata, :company)
        update_if_present(ext_props, metadata, :category)
        update_if_present(ext_props, metadata, :manager)
        update_if_present(ext_props, metadata, :language)
        update_if_present(ext_props, metadata, :version)
        update_if_present(ext_props, metadata, :revision)
        update_if_present(ext_props, metadata, :status)

        document.extended_properties = ext_props
      end

      # Update property if present in metadata.
      #
      # @param properties [Hash] Properties hash to update
      # @param metadata [Metadata] Source metadata
      # @param key [Symbol] Property key
      def update_if_present(properties, metadata, key)
        return unless metadata.key?(key)

        value = metadata[key]
        properties[key] = value
      end

      # Clear a specific property from document.
      #
      # @param document [Document] The document
      # @param key [Symbol] Property key to clear
      def clear_property(document, key)
        # Determine which property collection this belongs to
        if core_property?(key)
          clear_from_collection(document, :core_properties, key)
        elsif extended_property?(key)
          clear_from_collection(document, :extended_properties, key)
        end
      end

      # Clear property from a collection.
      #
      # @param document [Document] The document
      # @param collection [Symbol] Collection name
      # @param key [Symbol] Property key
      def clear_from_collection(document, collection, key)
        return unless document.respond_to?(collection)

        props = document.send(collection)
        return unless props

        props.delete(key)
      end

      # Check if key is a core property.
      #
      # @param key [Symbol] Property key
      # @return [Boolean] true if core property
      def core_property?(key)
        CORE_PROPERTIES.include?(key)
      end

      # Check if key is an extended property.
      #
      # @param key [Symbol] Property key
      # @return [Boolean] true if extended property
      def extended_property?(key)
        EXTENDED_PROPERTIES.include?(key)
      end

      # Core property keys
      CORE_PROPERTIES = %i[
        title
        author
        subject
        keywords
        description
        creator
        created_at
        modified_at
        last_modified_by
      ].freeze

      # Extended property keys
      EXTENDED_PROPERTIES = %i[
        company
        category
        manager
        language
        version
        revision
        status
      ].freeze
    end
  end
end

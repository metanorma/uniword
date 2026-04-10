# frozen_string_literal: true

module Uniword
  module Builder
    # Builds Structured Document Tags (content controls).
    #
    # Supports text controls, date pickers, dropdown lists, bibliography
    # placeholders, and document part references.
    #
    # @example Create a text content control
    #   sdt = SdtBuilder.text(tag: 'title', alias: 'Document Title')
    #   doc.paragraph { |p| p << sdt.build }
    #
    # @example Create a date picker
    #   sdt = SdtBuilder.date(tag: 'date1', format: 'yyyy-MM-dd')
    #   doc.paragraph { |p| p << sdt.build }
    #
    # @example Create a bibliography placeholder
    #   sdt = SdtBuilder.bibliography
    #   doc.paragraph { |p| p << sdt.build }
    class SdtBuilder
      attr_reader :model

      def initialize
        @model = Wordprocessingml::StructuredDocumentTag.new
        @sdt_id_counter = 0
      end

      # Wrap an existing StructuredDocumentTag model
      #
      # @param model [Wordprocessingml::StructuredDocumentTag]
      # @return [SdtBuilder]
      def self.from_model(model)
        builder = allocate
        builder.instance_variable_set(:@model, model)
        builder
      end

      # Set the SDT identifier
      #
      # @param value [Integer] Unique ID (auto-generated if nil)
      # @return [self]
      def id(value = nil)
        properties.id = Wordprocessingml::StructuredDocumentTag::Id.new(
          value: value || next_id
        )
        self
      end

      # Set the developer tag
      #
      # @param value [String] Tag name
      # @return [self]
      def tag(value)
        properties.tag = Wordprocessingml::StructuredDocumentTag::Tag.new(
          value: value
        )
        self
      end

      # Set the display alias
      #
      # @param value [String] Alias name
      # @return [self]
      def alias(value)
        properties.alias_name = Wordprocessingml::StructuredDocumentTag::Alias.new(
          value: value
        )
        self
      end

      # Set the lock / content cannot be edited
      #
      # @param value [Boolean] Lock content (default true)
      # @return [self]
      def lock(_value = true)
        properties.temporary = Wordprocessingml::StructuredDocumentTag::Temporary.new
        self
      end

      # Set placeholder text showing the placeholder header
      #
      # @param value [Boolean] Show placeholder (default true)
      # @return [self]
      def showing_placeholder(_value = true)
        properties.showing_placeholder_header = Wordprocessingml::StructuredDocumentTag::ShowingPlaceholderHeader.new
        self
      end

      # Return the underlying StructuredDocumentTag model
      #
      # @return [Wordprocessingml::StructuredDocumentTag]
      def build
        # Auto-assign ID if not set
        unless properties.id
          properties.id = Wordprocessingml::StructuredDocumentTag::Id.new(
            value: next_id
          )
        end
        @model
      end

      # Access the properties object, initializing if needed
      #
      # @return [Wordprocessingml::StructuredDocumentTagProperties]
      def properties
        @model.properties ||= Wordprocessingml::StructuredDocumentTagProperties.new
        @model.properties
      end

      # --- Factory methods ---

      # Create a plain text content control
      #
      # @param tag [String, nil] Developer tag
      # @param alias_name [String, nil] Display name
      # @param placeholder_text [String, nil] Placeholder text
      # @param lock [Boolean] Lock content
      # @return [SdtBuilder]
      def self.text(tag: nil, alias_name: nil, placeholder_text: nil, lock: false)
        sdt = new
        sdt.tag(tag) if tag
        sdt.alias(alias_name) if alias_name
        sdt.lock if lock

        # Text control flag
        sdt.properties.text = Wordprocessingml::StructuredDocumentTag::Text.new

        sdt.showing_placeholder if placeholder_text
        sdt
      end

      # Create a date picker content control
      #
      # @param tag [String, nil] Developer tag
      # @param format [String] Date format (default 'M/d/yyyy')
      # @param locale [String] Locale (default 'en-US')
      # @param calendar [String] Calendar type (default 'gregorian')
      # @return [SdtBuilder]
      def self.date(tag: nil, format: 'M/d/yyyy', locale: 'en-US',
                    calendar: 'gregorian')
        sdt = new
        sdt.tag(tag) if tag

        # Date control
        date = Wordprocessingml::StructuredDocumentTag::Date.new
        date.date_format = Wordprocessingml::StructuredDocumentTag::DateFormat.new(
          value: format
        )
        date.lid = Wordprocessingml::StructuredDocumentTag::Lid.new(value: locale)
        date.store_mapped_data_as = Wordprocessingml::StructuredDocumentTag::StoreMappedDataAs.new(
          value: 'dateTime'
        )
        date.calendar = Wordprocessingml::StructuredDocumentTag::Calendar.new(
          value: calendar
        )
        sdt.properties.date = date
        sdt
      end

      # Create a bibliography placeholder
      #
      # @return [SdtBuilder]
      def self.bibliography
        sdt = new

        # Bibliography flag
        sdt.properties.bibliography = Wordprocessingml::StructuredDocumentTag::Bibliography.new

        # DocPartObj with bibliography gallery
        dpo = Wordprocessingml::StructuredDocumentTag::DocPartObj.new
        dpo.doc_part_gallery = Wordprocessingml::StructuredDocumentTag::DocPartGallery.new(
          value: 'Bibliographies'
        )
        dpo.doc_part_unique = Wordprocessingml::StructuredDocumentTag::DocPartUnique.new
        sdt.properties.doc_part_obj = dpo
        sdt
      end

      # Create a document part content control (e.g., Table of Contents)
      #
      # @param gallery [String] Gallery name (e.g., 'Table of Contents')
      # @param unique [Boolean] Mark as unique
      # @return [SdtBuilder]
      def self.doc_part(gallery:, unique: true)
        sdt = new

        dpo = Wordprocessingml::StructuredDocumentTag::DocPartObj.new
        dpo.doc_part_gallery = Wordprocessingml::StructuredDocumentTag::DocPartGallery.new(
          value: gallery
        )
        dpo.doc_part_unique = Wordprocessingml::StructuredDocumentTag::DocPartUnique.new if unique
        sdt.properties.doc_part_obj = dpo
        sdt
      end

      private

      def next_id
        @sdt_id_counter += 1
        @sdt_id_counter
      end
    end
  end
end

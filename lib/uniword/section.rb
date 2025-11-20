# frozen_string_literal: true

require "lutaml/model"
require_relative "section_properties"
require_relative "header"
require_relative "footer"

module Uniword
  # Represents a document section
  # Each section can have its own page setup, headers, and footers
  class Section < Lutaml::Model::Serializable
    attribute :properties, SectionProperties
    attribute :headers, Header, collection: true, default: -> { [] }
    attribute :footers, Footer, collection: true, default: -> { [] }

    def initialize(**attributes)
      super
      @properties ||= SectionProperties.a4_portrait
      @headers ||= []
      @footers ||= []
    end

    # Add a header to this section
    def add_header(header)
      raise ArgumentError, 'header must be a Header instance' unless header.is_a?(Header)

      headers << header
    end

    # Add a footer to this section
    def add_footer(footer)
      footers << footer
    end

    # Get header by type
    def get_header(type = "default")
      headers.find { |h| h.type == type }
    end

    # Get footer by type
    def get_footer(type = "default")
      footers.find { |f| f.type == type }
    end

    # Get or create header by type
    def header(type = "default")
      get_header(type) || begin
        h = Header.new(type: type)
        add_header(h)
        h
      end
    end

    # Get or create footer by type
    def footer(type = "default")
      get_footer(type) || begin
        f = Footer.new(type: type)
        add_footer(f)
        f
      end
    end

    # Convenience accessors for different header types
    def default_header
      get_header("default")
    end

    def default_header=(header)
      # Remove existing default header
      headers.reject! { |h| h.type == "default" }
      header.type = "default" if header
      add_header(header) if header
    end

    def first_header
      get_header("first")
    end

    def first_header=(header)
      headers.reject! { |h| h.type == "first" }
      header.type = "first" if header
      add_header(header) if header
    end

    def even_header
      get_header("even")
    end

    def even_header=(header)
      headers.reject! { |h| h.type == "even" }
      header.type = "even" if header
      add_header(header) if header
    end

    # Convenience accessors for different footer types
    def default_footer
      get_footer("default")
    end

    def default_footer=(footer)
      footers.reject! { |f| f.type == "default" }
      footer.type = "default" if footer
      add_footer(footer) if footer
    end

    def first_footer
      get_footer("first")
    end

    def first_footer=(footer)
      footers.reject! { |f| f.type == "first" }
      footer.type = "first" if footer
      add_footer(footer) if footer
    end

    def even_footer
      get_footer("even")
    end

    def even_footer=(footer)
      footers.reject! { |f| f.type == "even" }
      footer.type = "even" if footer
      add_footer(footer) if footer
    end

    # Check if section has any headers
    def has_headers?
      headers.any?
    end

    # Check if section has any footers
    def has_footers?
      footers.any?
    end

    # Get page margins as hash (docx-js compatibility)
    # Returns hash with margin values in twips
    #
    # @return [Hash] Margin configuration
    def page_margins
      ensure_properties
      {
        top: @properties.margin_top,
        bottom: @properties.margin_bottom,
        left: @properties.margin_left,
        right: @properties.margin_right,
        header: @properties.margin_header,
        footer: @properties.margin_footer
      }
    end

    # Set page margins from hash (docx-js compatibility)
    # Accepts hash with margin values in twips
    #
    # @param value [Hash] Margin configuration
    # @option value [Integer] :top Top margin in twips
    # @option value [Integer] :bottom Bottom margin in twips
    # @option value [Integer] :left Left margin in twips
    # @option value [Integer] :right Right margin in twips
    # @option value [Integer] :header Header margin in twips
    # @option value [Integer] :footer Footer margin in twips
    # @return [Hash] the value set
    def page_margins=(value)
      return unless value.is_a?(Hash)

      ensure_properties
      @properties.margin_top = value[:top] if value.key?(:top)
      @properties.margin_bottom = value[:bottom] if value.key?(:bottom)
      @properties.margin_left = value[:left] if value.key?(:left)
      @properties.margin_right = value[:right] if value.key?(:right)
      @properties.margin_header = value[:header] if value.key?(:header)
      @properties.margin_footer = value[:footer] if value.key?(:footer)
      value
    end

    private

    # Ensure properties object exists
    # Creates a new SectionProperties if needed
    #
    # @return [SectionProperties] the properties object
    def ensure_properties
      @properties ||= SectionProperties.new
    end
  end
end
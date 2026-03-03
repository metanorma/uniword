# frozen_string_literal: true

require_relative 'wordprocessingml/run'

module Uniword
  # Represents a hyperlink within a document
  #
  # Hyperlinks can be either external (URL) or internal (anchor/bookmark).
  # They contain one or more runs with formatted text.
  #
  # @example External hyperlink
  #   link = Hyperlink.new(url: "https://example.com", text: "Click here")
  #
  # @example Internal hyperlink (bookmark reference)
  #   link = Hyperlink.new(anchor: "bookmark1", text: "Go to section 1")
  #
  # @attr [String] url External URL (for external hyperlinks)
  # @attr [String] anchor Bookmark name (for internal hyperlinks)
  # @attr [String] tooltip Tooltip text shown on hover
  # @attr [String] relationship_id Relationship ID in OOXML
  # @attr [Array<Run>] runs Text runs within the hyperlink
  class Hyperlink < Run
    # OOXML namespace configuration
    xml do
      element 'hyperlink', mixed: true
      namespace Ooxml::Namespaces::WordProcessingML

      map_attribute 'anchor', to: :anchor
      map_attribute 'tooltip', to: :tooltip
      # NOTE: r:id attribute from Relationships namespace - handled by attribute_form_default
      # The relationship_id attribute maps to r:id in the output
      map_attribute 'id', to: :relationship_id
      map_element 'r', to: :runs
    end

    # External URL (not serialized directly to XML)
    attr_accessor :url

    # Internal anchor/bookmark reference
    attribute :anchor, :string

    # Tooltip text
    attribute :tooltip, :string

    # Relationship ID for external links
    attribute :relationship_id, :string

    # Text runs within the hyperlink
    attribute :runs, Run, collection: true, default: -> { [] }

    # Create a new Hyperlink instance
    #
    # @param attributes [Hash] Initial attributes
    # @option attributes [String] :url External URL
    # @option attributes [String] :anchor Internal bookmark reference
    # @option attributes [String] :text Simple text (creates a run)
    # @option attributes [String] :tooltip Tooltip text
    # @option attributes [Array<Run>] :runs Text runs
    # @return [Hyperlink] The new instance
    def initialize(attributes = {})
      # Handle simple text parameter
      if attributes[:text] && attributes[:runs].nil?
        text_content = attributes.delete(:text)
        run = Run.new(text: text_content)
        # Apply default hyperlink style
        run.properties = Wordprocessingml::RunProperties.new(
          color: '0563C1',
          underline: 'single'
        )
        attributes[:runs] = [run]
      end

      # Extract url before super (not a serializable attribute)
      @url = attributes.delete(:url)

      super
    end

    # Add a text run to the hyperlink
    #
    # @param run [Run] The run to add
    # @return [Array<Run>] The updated runs array
    def add_run(run)
      raise ArgumentError, 'run must be a Run instance' unless run.is_a?(Run)

      runs << run
    end

    # Get the plain text from all runs
    #
    # @return [String] Combined text
    def text
      runs.map(&:text).join
    end

    # Check if this is an external hyperlink
    #
    # @return [Boolean] true if has URL
    def external?
      !url.nil?
    end

    # Check if this is an internal hyperlink
    #
    # @return [Boolean] true if has anchor
    def internal?
      !anchor.nil?
    end

    # Accept a visitor for the visitor pattern
    #
    # @param visitor [Object] The visitor object
    # @return [Object] The result of the visit operation
    def accept(visitor)
      visitor.visit_hyperlink(self)
    end

    # Provide detailed inspection for debugging
    #
    # @return [String] A readable representation
    def inspect
      type = external? ? "external(#{url})" : "internal(#{anchor})"
      "#<Uniword::Hyperlink #{type} text=#{text.inspect}>"
    end

    protected

    # Validate hyperlink attributes
    #
    # @return [Boolean] true if valid
    def required_attributes_valid?
      # Must have either URL or anchor
      (url || anchor) && !runs.empty?
    end
  end
end

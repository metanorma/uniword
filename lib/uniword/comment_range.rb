# frozen_string_literal: true

require_relative 'element'

module Uniword
  # Represents a comment range marker in a Word document.
  #
  # Comments in Word documents are anchored to specific text ranges using
  # commentRangeStart and commentRangeEnd markers. These markers define
  # the beginning and end of the commented text.
  #
  # In OOXML:
  # - <w:commentRangeStart> marks the start of a commented range
  # - <w:commentRangeEnd> marks the end of a commented range
  # - <w:commentReference> provides the actual link to the comment
  #
  # @example Create comment range markers
  #   range_start = Uniword::CommentRange.new(
  #     comment_id: "1",
  #     marker_type: :start
  #   )
  #   range_end = Uniword::CommentRange.new(
  #     comment_id: "1",
  #     marker_type: :end
  #   )
  #
  # @attr [String] comment_id The ID of the associated comment
  # @attr [Symbol] marker_type Type of marker (:start, :end, :reference)
  #
  # @see Comment For the comment content
  class CommentRange < Element
    # OOXML namespace configuration
    xml do
      element 'commentRangeStart'
      namespace Ooxml::Namespaces::WordProcessingML

      map_attribute 'id', to: :comment_id
    end

    # Comment ID this range marker refers to
    attribute :comment_id, :string

    # Type of marker (:start, :end, :reference)
    attr_accessor :marker_type

    # Initialize a comment range marker
    #
    # @param attributes [Hash] Marker attributes
    # @option attributes [String] :comment_id Comment ID (required)
    # @option attributes [Symbol] :marker_type Marker type (:start, :end, :reference)
    def initialize(attributes = {})
      @marker_type = attributes.delete(:marker_type) || :start
      super(attributes)
    end

    # Accept a visitor for the visitor pattern
    #
    # @param visitor [Object] The visitor object
    # @return [Object] The result of the visit operation
    def accept(visitor)
      visitor.visit_comment_range(self)
    end

    # Check if this is a start marker
    #
    # @return [Boolean] true if start marker
    def start?
      marker_type == :start
    end

    # Check if this is an end marker
    #
    # @return [Boolean] true if end marker
    def end?
      marker_type == :end
    end

    # Check if this is a reference marker
    #
    # @return [Boolean] true if reference marker
    def reference?
      marker_type == :reference
    end

    # Get the XML element name based on marker type
    #
    # @return [String] The XML element name
    def xml_element_name
      case marker_type
      when :start
        'commentRangeStart'
      when :end
        'commentRangeEnd'
      when :reference
        'commentReference'
      else
        raise ArgumentError, "Invalid marker type: #{marker_type}"
      end
    end

    # Provide detailed inspection for debugging
    #
    # @return [String] A readable representation of the comment range
    def inspect
      "#<Uniword::CommentRange type=#{marker_type.inspect} comment_id=#{comment_id.inspect}>"
    end

    protected

    # Validate that comment range has required attributes
    #
    # @return [Boolean] true if valid
    def required_attributes_valid?
      !comment_id.nil? && !comment_id.empty? && !marker_type.nil?
    end
  end
end
# frozen_string_literal: true

require_relative 'element'

module Uniword
  # Represents a single revision (change) in a Word document.
  #
  # Revisions are part of Word's track changes feature, recording
  # insertions, deletions, and formatting changes with author and
  # timestamp information.
  #
  # In OOXML:
  # - Insertions: <w:ins>
  # - Deletions: <w:del>
  # - Format changes: <w:rPrChange>, <w:pPrChange>
  #
  # @example Create an insertion
  #   revision = Uniword::Revision.new(
  #     type: :insert,
  #     author: "John Doe",
  #     text: "New text"
  #   )
  #
  # @example Create a deletion
  #   revision = Uniword::Revision.new(
  #     type: :delete,
  #     author: "Jane Smith",
  #     text: "Deleted text"
  #   )
  #
  # @attr [Symbol] type Revision type (:insert, :delete, :format_change)
  # @attr [String] author Author name
  # @attr [String] date Revision date/time
  # @attr [String] revision_id Unique revision identifier
  # @attr [String] text Content affected by the revision
  #
  # @see TrackedChanges For revision collection management
  class Revision < Element
    # OOXML namespace configuration
    xml do
      root 'ins'
      namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

      map_attribute 'id', to: :revision_id
      map_attribute 'author', to: :author
      map_attribute 'date', to: :date
    end

    # Unique revision identifier
    attribute :revision_id, :string

    # Author name
    attribute :author, :string

    # Revision date/time
    attribute :date, :string

    # Revision type (:insert, :delete, :format_change)
    attr_accessor :type

    # Content affected by revision
    attr_accessor :content

    # Initialize a new revision
    #
    # @param attributes [Hash] Revision attributes
    # @option attributes [Symbol] :type Revision type
    # @option attributes [String] :author Author name
    # @option attributes [String] :text Text content
    # @option attributes [String] :date Revision date
    # @option attributes [String] :revision_id Unique ID
    def initialize(attributes = {})
      # Extract custom attributes before calling super
      @type = attributes.delete(:type) || :insert
      text_content = attributes.delete(:text)
      @content = attributes.delete(:content)

      super(attributes)

      # Auto-generate revision_id if not provided
      @revision_id ||= generate_revision_id

      # Set date to current time if not provided
      @date ||= format_date(Time.now)

      # Set content from text if provided
      if text_content && !text_content.empty?
        @content = text_content
      end
    end

    # Accept a visitor for the visitor pattern
    #
    # @param visitor [Object] The visitor object
    # @return [Object] The result of the visit operation
    def accept(visitor)
      visitor.visit_revision(self)
    end

    # Get text content
    #
    # @return [String] The text content
    def text
      content.to_s
    end

    # Check if this is an insertion
    #
    # @return [Boolean] true if insertion
    def insert?
      type == :insert
    end

    # Check if this is a deletion
    #
    # @return [Boolean] true if deletion
    def delete?
      type == :delete
    end

    # Check if this is a format change
    #
    # @return [Boolean] true if format change
    def format_change?
      type == :format_change
    end

    # Get the XML element name based on revision type
    #
    # @return [String] The XML element name
    def xml_element_name
      case type
      when :insert
        'ins'
      when :delete
        'del'
      when :format_change
        'rPrChange'
      else
        raise ArgumentError, "Invalid revision type: #{type}"
      end
    end

    # Provide detailed inspection for debugging
    #
    # @return [String] A readable representation of the revision
    def inspect
      text_preview = text[0..30]
      text_preview += '...' if text.length > 30
      "#<Uniword::Revision type=#{type.inspect} author=#{author.inspect} text=#{text_preview.inspect}>"
    end

    protected

    # Validate that revision has required attributes
    #
    # @return [Boolean] true if valid
    def required_attributes_valid?
      !author.nil? && !author.empty? &&
        !revision_id.nil? &&
        !type.nil? &&
        valid_type?
    end

    private

    # Check if type is valid
    #
    # @return [Boolean] true if valid type
    def valid_type?
      [:insert, :delete, :format_change].include?(type)
    end

    # Generate a unique revision ID
    #
    # @return [String] A unique revision ID
    def generate_revision_id
      # Use timestamp + random component for uniqueness
      "#{Time.now.to_i}_#{rand(10000)}"
    end

    # Format date for OOXML
    #
    # @param time [Time] The time object
    # @return [String] ISO 8601 formatted date string
    def format_date(time)
      return time if time.is_a?(String)
      time.utc.iso8601
    end
  end
end
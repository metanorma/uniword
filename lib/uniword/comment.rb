# frozen_string_literal: true

module Uniword
  # Represents a comment in a Word document.
  #
  # Comments are annotations attached to content ranges, containing author
  # information, timestamp, and comment text. They are part of Word's
  # review and collaboration features.
  #
  # In OOXML, comments are stored in word/comments.xml and referenced
  # via commentRangeStart, commentRangeEnd, and commentReference elements.
  #
  # @example Create a comment
  #   comment = Uniword::Comment.new(
  #     author: "John Doe",
  #     text: "This needs revision",
  #     date: Time.now
  #   )
  #
  # @example Add comment to paragraph
  #   para = Uniword::Paragraph.new.add_text("Text to comment")
  #   comment = Uniword::Comment.new(author: "Editor", text: "Review this")
  #   para.add_comment(comment)
  #
  # @attr [String] author Comment author name
  # @attr [String] text Comment text content
  # @attr [Time] date Comment creation date/time
  # @attr [String] initials Author initials (optional)
  # @attr [Integer] comment_id Unique comment identifier
  #
  # @see CommentRange For comment range markers
  # @see CommentsPart For comments collection
  class Comment < Element
    # OOXML namespace configuration for comments
    xml do
      element 'comment'
      namespace Ooxml::Namespaces::WordProcessingML

      map_attribute 'id', to: :comment_id
      map_attribute 'author', to: :author
      map_attribute 'date', to: :date
      map_attribute 'initials', to: :initials

      map_element 'p', to: :paragraphs
    end

    # Unique comment identifier (required in OOXML)
    attribute :comment_id, :string

    # Author name
    attribute :author, :string

    # Comment creation date/time
    attribute :date, :string

    # Author initials (optional)
    attribute :initials, :string

    # Comment content as paragraphs
    attribute :paragraphs, Paragraph, collection: true, default: -> { [] }

    # Initialize a new comment
    #
    # @param attributes [Hash] Comment attributes
    # @option attributes [String] :author Author name
    # @option attributes [String] :text Comment text (creates paragraph)
    # @option attributes [Time, String] :date Comment date
    # @option attributes [String] :initials Author initials
    # @option attributes [String] :comment_id Unique ID (auto-generated if not provided)
    def initialize(attributes = {})
      # Extract text before calling super to handle it specially
      text_content = attributes.delete(:text)

      super

      # Ensure paragraphs is initialized as array (lutaml-model handles this via default)
      @paragraphs ||= []

      # Auto-generate comment_id if not provided
      @comment_id ||= generate_comment_id

      # Set date to current time if not provided
      @date ||= format_date(Time.now)

      # Add text as a paragraph if provided
      return unless text_content && !text_content.empty?

      add_text(text_content)
    end

    # Accept a visitor for the visitor pattern
    #
    # @param visitor [Object] The visitor object
    # @return [Object] The result of the visit operation
    def accept(visitor)
      visitor.visit_comment(self)
    end

    # Add text to comment (creates a paragraph)
    #
    # @param text [String] The text content
    # @return [self] Returns self for method chaining
    def add_text(text)
      # Lazy load Paragraph class when needed
      para = Uniword::Paragraph.new
      para.add_text(text)
      paragraphs << para
      self
    end

    # Add a paragraph to the comment
    #
    # @param paragraph [Paragraph] The paragraph to add
    # @return [self] Returns self for method chaining
    def add_paragraph(paragraph)
      # Lazy load Paragraph class when needed
      unless paragraph.is_a?(Uniword::Paragraph)
        raise ArgumentError, 'paragraph must be a Paragraph instance'
      end

      paragraphs << paragraph
      self
    end

    # Get the plain text content of this comment
    # Concatenates text from all paragraphs
    #
    # @return [String] The combined text from all paragraphs
    def text
      paragraphs.map(&:text).join("\n")
    end

    # Check if comment is empty (has no paragraphs or all paragraphs are empty)
    #
    # @return [Boolean] true if empty
    def empty?
      paragraphs.empty? || paragraphs.all?(&:empty?)
    end

    # Provide detailed inspection for debugging
    #
    # @return [String] A readable representation of the comment
    def inspect
      text_preview = text[0..50]
      text_preview += '...' if text.length > 50
      "#<Uniword::Comment id=#{comment_id.inspect} author=#{author.inspect} text=#{text_preview.inspect}>"
    end

    protected

    # Validate that comment has required attributes
    #
    # @return [Boolean] true if valid
    def required_attributes_valid?
      !author.nil? && !author.empty? && !comment_id.nil?
    end

    private

    # Generate a unique comment ID
    #
    # @return [String] A unique comment ID
    def generate_comment_id
      # Use timestamp + random component for uniqueness
      "#{Time.now.to_i}_#{rand(10_000)}"
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

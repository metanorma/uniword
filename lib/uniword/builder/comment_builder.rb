# frozen_string_literal: true

module Uniword
  module Builder
    # Builds and configures Comment objects.
    #
    # @example Create a comment
    #   comment = CommentBuilder.new(author: 'Editor')
    #   comment << 'This needs review'
    #   comment.build
    class CommentBuilder
      attr_reader :model

      def initialize(author:, comment_id: nil, date: nil, initials: nil)
        @model = Comment.new(
          author: author,
          comment_id: comment_id,
          date: date,
          initials: initials
        )
      end

      # Wrap an existing Comment model
      def self.from_model(model)
        builder = allocate
        builder.instance_variable_set(:@model, model)
        builder
      end

      # Append text to the comment (creates a paragraph)
      #
      # @param element [String, Paragraph]
      # @return [self]
      def <<(element)
        case element
        when String
          para = Wordprocessingml::Paragraph.new
          para.runs << Wordprocessingml::Run.new(text: element)
          @model.paragraphs << para
        when Wordprocessingml::Paragraph
          @model.paragraphs << element
        else
          raise ArgumentError, "Cannot add #{element.class} to comment"
        end
        self
      end

      # Return the underlying Comment model
      def build
        @model
      end
    end
  end
end

# frozen_string_literal: true

module Uniword
  module FindReplace
    # Comments scope: text in `word/comments.xml`. Walks every
    # comment's paragraphs.
    class CommentScope < Scope
      # @return [Symbol]
      def name
        :comments
      end

      # @yieldparam text_element [Wordprocessingml::Text]
      # @yieldparam accessor [Scope::TextAccessor]
      def each_text_node
        comments = @document.comments&.comments
        return unless comments

        each_text_in_containers(comments) { |*a| yield(*a) }
      end
    end
  end
end

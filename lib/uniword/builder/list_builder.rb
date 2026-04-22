# frozen_string_literal: true

module Uniword
  module Builder
    # Builds lists (bulleted or numbered) within a document.
    #
    # @example Create a bullet list
    #   doc.list(type: :bullet) do |l|
    #     l.item('First item')
    #     l.item('Second item')
    #     l.item('Third item') { |p| p << Builder.text('bold', bold: true) }
    #   end
    #
    # @example Create a numbered list
    #   doc.list(type: :decimal) do |l|
    #     l.item('Step 1')
    #     l.item('Step 2')
    #     l.item('Sub-step', level: 1)
    #   end
    class ListBuilder
      # @return [Integer] The numbering ID assigned to this list
      attr_reader :num_id

      # @return [Symbol] The list type (:bullet, :decimal, :roman, :letter)
      attr_reader :type

      def initialize(document, type: :bullet)
        @document = document
        @type = type
        model = document.model
        model.numbering_configuration ||= Uniword::Wordprocessingml::NumberingConfiguration.new
        @num_id = model.numbering_configuration
                       .create_numbering(type)
      end

      # Add an item to the list
      #
      # @param text [String, nil] Optional text content
      # @param level [Integer] Nesting level (0-based, default 0)
      # @yield [ParagraphBuilder] Builder for item content
      # @return [ParagraphBuilder] The paragraph builder
      def item(text = nil, level: 0, &block)
        para = ParagraphBuilder.new
        para.numbering(@num_id, level)
        para << text if text
        block.call(para) if block_given?
        @document << para.build
        para
      end
    end
  end
end

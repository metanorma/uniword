# frozen_string_literal: true

module Uniword
  module Builder
    # Builds numbering definitions for lists.
    #
    # @example Define a numbered list
    #   doc.define_numbering do |n|
    #     n.level(0, format: 'decimal', text: '%1.')
    #     n.level(1, format: 'lowerLetter', text: '%2)')
    #   end
    class NumberingBuilder
      attr_reader :model

      def initialize(model = nil)
        @model = model || Wordprocessingml::NumberingConfiguration.new
      end

      # Wrap an existing NumberingConfiguration model
      def self.from_model(model)
        new(model)
      end

      # Define a numbering level
      #
      # @param level [Integer] Level number (0-based)
      # @param format [String] Number format ('decimal', 'lowerLetter', 'upperLetter', etc.)
      # @param text [String] Level text template (e.g., '%1.', '%2)')
      # @param start [Integer] Starting number (default 1)
      # @return [self]
      def level(level, format: 'decimal', text: '%1.', start: 1)
        @model.create_numbering(level, format, text, start)
        self
      end

      # Return the underlying NumberingConfiguration model
      def build
        @model
      end
    end
  end
end

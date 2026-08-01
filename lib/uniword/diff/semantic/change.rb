# frozen_string_literal: true

module Uniword
  module Diff
    module Semantic
      # One classified change. Severity defaults to :info; classifiers
      # can promote to :warning or :error.
      class Change
        KINDS = %i[added removed modified moved].freeze
        MODIFIERS = %i[text format structure].freeze

        # @return [Symbol] one of KINDS
        attr_reader :kind

        # @return [Symbol, nil] for :modified, one of MODIFIERS
        attr_reader :modifier

        # @return [Integer, nil] paragraph index in old (nil when
        #   the paragraph is new)
        attr_reader :old_index

        # @return [Integer, nil] paragraph index in new (nil when
        #   the paragraph was removed)
        attr_reader :new_index

        # @return [String, nil] human-readable summary
        attr_reader :description

        # @param kind [Symbol]
        # @param modifier [Symbol, nil]
        # @param old_index [Integer, nil]
        # @param new_index [Integer, nil]
        # @param description [String, nil]
        def initialize(kind:, modifier: nil, old_index: nil,
                       new_index: nil, description: nil)
          unless KINDS.include?(kind)
            raise ArgumentError,
                  "unknown kind #{kind.inspect}"
          end
          if modifier && !MODIFIERS.include?(modifier)
            raise ArgumentError, "unknown modifier #{modifier.inspect}"
          end

          @kind = kind
          @modifier = modifier
          @old_index = old_index
          @new_index = new_index
          @description = description
        end

        # @return [Hash]
        def to_h
          { kind: kind, modifier: modifier,
            old_index: old_index, new_index: new_index,
            description: description }
        end

        # @param other [Object]
        # @return [Boolean]
        def ==(other)
          other.is_a?(Change) && to_h == other.to_h
        end
      end
    end
  end
end

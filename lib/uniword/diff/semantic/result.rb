# frozen_string_literal: true

module Uniword
  module Diff
    module Semantic
      # Aggregated semantic diff result. Counts by kind and modifier;
      # full change list.
      class Result
        attr_reader :changes

        def initialize
          @changes = []
        end

        # @param change [Change]
        # @return [void]
        def add(change)
          @changes << change
        end

        # Count by kind (`:added`, `:removed`, `:modified`, `:moved`).
        #
        # @return [Hash{Symbol => Integer}]
        def by_kind
          @changes.group_by(&:kind).transform_values(&:count)
        end

        # For modified changes, count by modifier (`:text`,
        # `:format`, `:structure`).
        #
        # @return [Hash{Symbol => Integer}]
        def by_modifier
          modified = @changes.select { |c| c.kind == :modified }
          modified.group_by(&:modifier).transform_values(&:count)
        end

        # Total change count.
        #
        # @return [Integer]
        def count
          @changes.length
        end

        # True when no changes.
        #
        # @return [Boolean]
        def empty?
          @changes.empty?
        end
      end
    end
  end
end

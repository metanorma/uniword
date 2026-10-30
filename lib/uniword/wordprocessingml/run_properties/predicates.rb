# frozen_string_literal: true

module Uniword
  module Wordprocessingml
    class RunProperties < Lutaml::Model::Serializable
      # Boolean predicate methods for RunProperties.
      #
      # Every predicate reads through BooleanElement#on?, so all of them
      # agree on what "0", "off" and an absent w:val mean.
      module Predicates
        def bold?
          toggle_on?(bold)
        end

        def italic?
          toggle_on?(italic)
        end

        def strike?
          toggle_on?(strike)
        end

        def all_caps
          caps?
        end

        def caps?
          toggle_on?(caps)
        end

        def small_caps?
          toggle_on?(small_caps)
        end

        def shadow?
          toggle_on?(shadow)
        end

        def imprint?
          toggle_on?(imprint)
        end

        def emboss?
          toggle_on?(emboss)
        end

        def hidden?
          toggle_on?(hidden)
        end

        def outline?
          toggle_on?(outline)
        end

        private

        # Toggles arrive as BooleanElement wrappers when parsed and as plain
        # booleans when a caller assigns one directly.
        #
        # @param toggle [Object, nil] Wrapper, boolean, or nil when absent
        # @return [Boolean] true when the toggle is on
        def toggle_on?(toggle)
          return false if toggle.nil?
          return toggle.on? if toggle.is_a?(Uniword::Properties::BooleanElement)

          toggle == true
        end
      end
    end
  end
end

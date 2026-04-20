# frozen_string_literal: true

module Uniword
  module Wordprocessingml
    class RunProperties < Lutaml::Model::Serializable
      # Boolean predicate methods for RunProperties.
      #
      # Unwraps boolean property objects and returns true/false.
      module Predicates
        def bold?
          val = bold
          return false if val.nil?

          val = val.value if val.is_a?(Uniword::Properties::BooleanElement)
          val == true
        end

        def italic?
          val = italic
          return false if val.nil?

          val = val.value if val.is_a?(Uniword::Properties::BooleanElement)
          val == true
        end

        def strike?
          val = strike
          return false if val.nil?

          val = val.value if val.is_a?(Uniword::Properties::BooleanElement)
          val == true
        end

        def all_caps
          val = @all_caps || caps
          return false if val.nil?

          val = val.value if val.is_a?(Uniword::Properties::BooleanElement)
          val == true
        end

        def all_caps=(value)
          @all_caps = value
          self.caps = value.is_a?(Properties::Caps) ? value : Properties::Caps.new(value: value)
          value
        end

        def all_caps?
          caps?
        end

        def caps?
          val = caps
          return false if val.nil?

          val = val.value if val.is_a?(Uniword::Properties::BooleanElement)
          val == true
        end

        def small_caps?
          val = small_caps
          return false if val.nil?

          val = val.value if val.is_a?(Properties::SmallCaps)
          val == true
        end

        def shadow?
          val = shadow
          return false if val.nil?

          val = val.value if val.is_a?(Properties::Shadow)
          val == true
        end

        def imprint?
          val = imprint
          return false if val.nil?

          val = val.value if val.is_a?(Properties::Imprint)
          val == true
        end

        def emboss?
          val = emboss
          return false if val.nil?

          val = val.value if val.is_a?(Properties::Emboss)
          val == true
        end

        def hidden?
          val = hidden
          return false if val.nil?

          val = val.value if val.is_a?(Properties::Vanish)
          val == true
        end

        def outline?
          val = outline
          return false if val.nil?

          val = val.val if val.is_a?(Properties::Outline)
          val != "false"
        end
      end
    end
  end
end

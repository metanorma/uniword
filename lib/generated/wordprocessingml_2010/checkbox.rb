# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2010
      # Checkbox content control for Word 2010+
      #
      # Generated from OOXML schema: wordprocessingml_2010.yml
      # Element: <w14:checkbox>
      class Checkbox < Lutaml::Model::Serializable
          attribute :checked, String
          attribute :checked_state, CheckedState
          attribute :unchecked_state, UncheckedState

          xml do
            root 'checkbox'
            namespace 'http://schemas.microsoft.com/office/word/2010/wordml', 'w14'
            mixed_content

            map_element 'checked', to: :checked, render_nil: false
            map_element 'checkedState', to: :checked_state, render_nil: false
            map_element 'uncheckedState', to: :unchecked_state, render_nil: false
          end
      end
    end
  end
end

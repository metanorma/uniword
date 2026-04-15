# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml2010
    # Checkbox content control for Word 2010+
    #
    # Generated from OOXML schema: wordprocessingml_2010.yml
    # Element: <w14:checkbox>
    class Checkbox < Lutaml::Model::Serializable
      attribute :checked, :string
      attribute :checked_state, CheckedState
      attribute :unchecked_state, UncheckedState

      xml do
        element "checkbox"
        namespace Uniword::Ooxml::Namespaces::Word2010
        mixed_content

        map_element "checked", to: :checked, render_nil: false
        map_element "checkedState", to: :checked_state, render_nil: false
        map_element "uncheckedState", to: :unchecked_state, render_nil: false
      end
    end
  end
end

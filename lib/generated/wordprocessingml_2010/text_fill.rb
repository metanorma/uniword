# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2010
      # Text fill effect with gradients
      #
      # Generated from OOXML schema: wordprocessingml_2010.yml
      # Element: <w14:textFill>
      class TextFill < Lutaml::Model::Serializable
          attribute :solid_fill, String
          attribute :gradient_fill, String
          attribute :no_fill, String

          xml do
            root 'textFill'
            namespace 'http://schemas.microsoft.com/office/word/2010/wordml', 'w14'
            mixed_content

            map_element 'solidFill', to: :solid_fill, render_nil: false
            map_element 'gradFill', to: :gradient_fill, render_nil: false
            map_element 'noFill', to: :no_fill, render_nil: false
          end
      end
    end
  end
end

# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml2010
    # Text fill effect with gradients
    #
    # Generated from OOXML schema: wordprocessingml_2010.yml
    # Element: <w14:textFill>
    class TextFill < Lutaml::Model::Serializable
      attribute :solid_fill, :string
      attribute :gradient_fill, :string
      attribute :no_fill, :string

      xml do
        element "textFill"
        namespace Uniword::Ooxml::Namespaces::Word2010
        mixed_content

        map_element "solidFill", to: :solid_fill, render_nil: false
        map_element "gradFill", to: :gradient_fill, render_nil: false
        map_element "noFill", to: :no_fill, render_nil: false
      end
    end
  end
end

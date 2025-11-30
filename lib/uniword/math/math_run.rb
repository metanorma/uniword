# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Math run - text with formatting
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:r>
    class MathRun < Lutaml::Model::Serializable
      attribute :properties, MathRunProperties
      attribute :text, :string

      xml do
        element 'r'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'rPr', to: :properties, render_nil: false
        map_element 't', to: :text, render_nil: false
      end
    end
  end
end

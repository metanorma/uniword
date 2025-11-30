# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Math text content
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:t>
    class MathText < Lutaml::Model::Serializable
      attribute :value, String

      xml do
        element 't'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'value', to: :value, render_nil: false
      end
    end
  end
end

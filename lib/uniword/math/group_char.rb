# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Group character object (overbrace, underbrace)
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:groupChr>
    class GroupChar < Lutaml::Model::Serializable
      attribute :properties, GroupCharProperties
      attribute :element, Element

      xml do
        element 'groupChr'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'groupChrPr', to: :properties, render_nil: false
        map_element 'e', to: :element
      end
    end
  end
end

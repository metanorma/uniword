# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # Bar object (overbar, underbar)
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:bar>
      class Bar < Lutaml::Model::Serializable
          attribute :properties, BarProperties
          attribute :element, Element

          xml do
            root 'bar'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'
            mixed_content

            map_element 'barPr', to: :properties, render_nil: false
            map_element 'e', to: :element
          end
      end
    end
  end
end

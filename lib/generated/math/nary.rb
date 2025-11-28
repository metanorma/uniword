# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # N-ary operator (sum, integral, product)
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:nary>
      class Nary < Lutaml::Model::Serializable
          attribute :properties, NaryProperties
          attribute :sub, Sub
          attribute :sup, Sup
          attribute :element, Element

          xml do
            root 'nary'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'
            mixed_content

            map_element 'naryPr', to: :properties, render_nil: false
            map_element 'sub', to: :sub, render_nil: false
            map_element 'sup', to: :sup, render_nil: false
            map_element 'e', to: :element
          end
      end
    end
  end
end

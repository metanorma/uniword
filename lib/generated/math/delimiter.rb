# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # Delimiter object (parentheses, brackets, braces)
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:d>
      class Delimiter < Lutaml::Model::Serializable
          attribute :properties, DelimiterProperties
          attribute :elements, Element, collection: true, default: -> { [] }

          xml do
            root 'd'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'
            mixed_content

            map_element 'dPr', to: :properties, render_nil: false
            map_element 'e', to: :elements, render_nil: false
          end
      end
    end
  end
end

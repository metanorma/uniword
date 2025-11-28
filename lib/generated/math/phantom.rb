# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # Phantom object (zero width/height)
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:phant>
      class Phantom < Lutaml::Model::Serializable
          attribute :properties, PhantomProperties
          attribute :element, Element

          xml do
            root 'phant'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'
            mixed_content

            map_element 'phantPr', to: :properties, render_nil: false
            map_element 'e', to: :element
          end
      end
    end
  end
end

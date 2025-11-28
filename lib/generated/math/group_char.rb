# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # Group character object (overbrace, underbrace)
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:groupChr>
      class GroupChar < Lutaml::Model::Serializable
          attribute :properties, GroupCharProperties
          attribute :element, Element

          xml do
            root 'groupChr'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'
            mixed_content

            map_element 'groupChrPr', to: :properties, render_nil: false
            map_element 'e', to: :element
          end
      end
    end
  end
end

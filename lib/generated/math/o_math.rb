# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # Office Math object - container for mathematical expressions
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:oMath>
      class OMath < Lutaml::Model::Serializable
          attribute :elements, String, collection: true, default: -> { [] }

          xml do
            root 'oMath'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'
            mixed_content

            map_element '*', to: :elements, render_nil: false
          end
      end
    end
  end
end

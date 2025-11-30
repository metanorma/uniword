# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Drawingml
      # Complex script text font
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:cs>
      class ComplexScriptFont < Lutaml::Model::Serializable
          attribute :typeface, String
          attribute :charset, Integer

          xml do
            element 'cs'
            namespace Uniword::Ooxml::Namespaces::DrawingML

            map_attribute 'typeface', to: :typeface
            map_attribute 'charset', to: :charset
          end
      end
    end
end

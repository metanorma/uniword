# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Drawingml
      # East Asian text font
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:ea>
      class EastAsianFont < Lutaml::Model::Serializable
          attribute :typeface, String
          attribute :charset, Integer

          xml do
            element 'ea'
            namespace Uniword::Ooxml::Namespaces::DrawingML

            map_attribute 'typeface', to: :typeface
            map_attribute 'charset', to: :charset
          end
      end
    end
end

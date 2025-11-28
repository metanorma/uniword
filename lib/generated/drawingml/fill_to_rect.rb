# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Fill to rectangle insets
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:fillToRect>
      class FillToRect < Lutaml::Model::Serializable
          attribute :l, Integer
          attribute :t, Integer
          attribute :r, Integer
          attribute :b, Integer

          xml do
            root 'fillToRect'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :l
            map_attribute 'true', to: :t
            map_attribute 'true', to: :r
            map_attribute 'true', to: :b
          end
      end
    end
  end
end

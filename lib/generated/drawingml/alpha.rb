# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Alpha transparency
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:alpha>
      class Alpha < Lutaml::Model::Serializable
          attribute :val, Integer

          xml do
            root 'alpha'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end

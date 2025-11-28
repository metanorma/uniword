# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Miter line join
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:miter>
      class LineJoinMiter < Lutaml::Model::Serializable
          attribute :lim, Integer

          xml do
            root 'miter'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :lim
          end
      end
    end
  end
end

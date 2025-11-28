# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Preset dash pattern
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:prstDash>
      class PresetDash < Lutaml::Model::Serializable
          attribute :val, String

          xml do
            root 'prstDash'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end

# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # East Asian text font
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:ea>
      class EastAsianFont < Lutaml::Model::Serializable
          attribute :typeface, String
          attribute :charset, Integer

          xml do
            root 'ea'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :typeface
            map_attribute 'true', to: :charset
          end
      end
    end
  end
end

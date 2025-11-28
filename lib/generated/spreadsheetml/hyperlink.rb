# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Hyperlink definition
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:hyperlink>
      class Hyperlink < Lutaml::Model::Serializable
          attribute :ref, String
          attribute :id, String
          attribute :location, String
          attribute :tooltip, String
          attribute :display, String

          xml do
            root 'hyperlink'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :ref
            map_attribute 'true', to: :id
            map_attribute 'true', to: :location
            map_attribute 'true', to: :tooltip
            map_attribute 'true', to: :display
          end
      end
    end
  end
end

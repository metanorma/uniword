# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Cell formula element
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:f>
      class CellFormula < Lutaml::Model::Serializable
          attribute :t, String
          attribute :ref, String
          attribute :si, Integer
          attribute :text, String

          xml do
            root 'f'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :t
            map_attribute 'true', to: :ref
            map_attribute 'true', to: :si
            map_element '', to: :text, render_nil: false
          end
      end
    end
  end
end

# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Calculation properties
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:calcPr>
      class CalcProperties < Lutaml::Model::Serializable
          attribute :calc_mode, String
          attribute :calc_id, Integer
          attribute :full_calc_on_load, String

          xml do
            root 'calcPr'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :calc_mode
            map_attribute 'true', to: :calc_id
            map_attribute 'true', to: :full_calc_on_load
          end
      end
    end
  end
end

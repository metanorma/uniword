# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Calculation properties
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:calcPr>
    class CalcProperties < Lutaml::Model::Serializable
      attribute :calc_mode, :string
      attribute :calc_id, :integer
      attribute :full_calc_on_load, :string

      xml do
        element "calcPr"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute "calc-mode", to: :calc_mode
        map_attribute "calc-id", to: :calc_id
        map_attribute "full-calc-on-load", to: :full_calc_on_load
      end
    end
  end
end

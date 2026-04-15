# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Column properties
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:col>
    class Col < Lutaml::Model::Serializable
      attribute :min, :integer
      attribute :max, :integer
      attribute :width, :string
      attribute :style, :integer
      attribute :hidden, :string
      attribute :custom_width, :string

      xml do
        element "col"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute "min", to: :min
        map_attribute "max", to: :max
        map_attribute "width", to: :width
        map_attribute "style", to: :style
        map_attribute "hidden", to: :hidden
        map_attribute "custom-width", to: :custom_width
      end
    end
  end
end

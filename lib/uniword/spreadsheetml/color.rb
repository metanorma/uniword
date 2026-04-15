# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Color definition
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:color>
    class Color < Lutaml::Model::Serializable
      attribute :rgb, :string
      attribute :theme, :integer
      attribute :tint, :string
      attribute :indexed, :integer

      xml do
        element "color"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute "rgb", to: :rgb
        map_attribute "theme", to: :theme
        map_attribute "tint", to: :tint
        map_attribute "indexed", to: :indexed
      end
    end
  end
end

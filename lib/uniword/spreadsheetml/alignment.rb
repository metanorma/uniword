# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Cell alignment properties
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:alignment>
    class Alignment < Lutaml::Model::Serializable
      attribute :horizontal, :string
      attribute :vertical, :string
      attribute :text_rotation, :integer
      attribute :wrap_text, :string
      attribute :indent, :integer
      attribute :shrink_to_fit, :string

      xml do
        element "alignment"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute "horizontal", to: :horizontal
        map_attribute "vertical", to: :vertical
        map_attribute "text-rotation", to: :text_rotation
        map_attribute "wrap-text", to: :wrap_text
        map_attribute "indent", to: :indent
        map_attribute "shrink-to-fit", to: :shrink_to_fit
      end
    end
  end
end

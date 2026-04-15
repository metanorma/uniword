# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Adjust right indent property
    #
    # Represents w:adjustRightInd element in paragraph properties.
    # When present, adjusts right indent when document has
    # right-to-left formatting.
    #
    # Element: <w:adjustRightInd/> or <w:adjustRightInd w:val="false"/>
    class AdjustRightInd < Lutaml::Model::Serializable
      include BooleanElement

      attribute :val, :string, default: nil
      include BooleanValSetter

      xml do
        element "adjustRightInd"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val, render_nil: false, render_default: false
      end
    end
  end
end

# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Auto space for East Asian characters and Latin text
    #
    # Represents w:autoSpaceDE element in paragraph properties.
    # When present without w:val, auto-spacing is enabled.
    # When present with w:val="false", auto-spacing is disabled.
    #
    # Element: <w:autoSpaceDE/> or <w:autoSpaceDE w:val="false"/>
    class AutoSpaceDE < Lutaml::Model::Serializable
      include BooleanElement

      attribute :val, :string, default: nil
      include BooleanValSetter

      xml do
        element "autoSpaceDE"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val, render_nil: false, render_default: false
      end
    end
  end
end

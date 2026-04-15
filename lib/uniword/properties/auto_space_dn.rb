# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Auto space for East Asian characters and numeric text
    #
    # Represents w:autoSpaceDN element in paragraph properties.
    # When present without w:val, auto-spacing is enabled.
    # When present with w:val="false", auto-spacing is disabled.
    #
    # Element: <w:autoSpaceDN/> or <w:autoSpaceDN w:val="false"/>
    class AutoSpaceDN < Lutaml::Model::Serializable
      include BooleanElement

      attribute :val, :string, default: nil
      include BooleanValSetter

      xml do
        element "autoSpaceDN"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val, render_nil: false, render_default: false
      end
    end
  end
end

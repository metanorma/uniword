# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Widow control property
    #
    # Represents w:widowControl element in paragraph properties.
    # When present, prevents first/last line of paragraph from appearing
    # alone on a page.
    #
    # Element: <w:widowControl/> or <w:widowControl w:val="false"/>
    class WidowControl < Lutaml::Model::Serializable
      include BooleanElement

      attribute :val, :string, default: nil
      include BooleanValSetter

      xml do
        element "widowControl"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val, render_nil: false, render_default: false
      end
    end
  end
end

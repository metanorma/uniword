# frozen_string_literal: true

module Uniword
  module Drawingml
    # Represents extra color scheme list in a theme (DrawingML)
    #
    # This element is typically empty in most themes.
    class ExtraColorSchemeList < Lutaml::Model::Serializable
      # OOXML namespace configuration
      xml do
        element "extraClrSchemeLst"
        namespace Ooxml::Namespaces::DrawingML
      end

      def initialize(attributes = {})
        super
      end
    end
  end
end

# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Office Art Extension
    #
    # Complex type for extensions in Office Art documents.
    class OfficeArtExtension < Lutaml::Model::Serializable
      attribute :uri, :string
      attribute :use_local_dpi, UseLocalDpi

      xml do
        element "ext"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute "uri", to: :uri
        map_element "useLocalDpi", to: :use_local_dpi, render_nil: false
      end
    end
  end
end

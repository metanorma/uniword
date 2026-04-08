# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Office Art Extension
    #
    # Complex type for extensions in Office Art documents.
    class OfficeArtExtension < Lutaml::Model::Serializable
      attribute :uri, :string

      xml do
        element 'ext'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'uri', to: :uri
      end
    end
  end
end

# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Office Art Extension List
    #
    # Complex type containing a collection of extensions.
    class OfficeArtExtensionList < Lutaml::Model::Serializable
      attribute :extensions, OfficeArtExtension, collection: true, initialize_empty: true

      xml do
        element 'extLst'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_element 'ext', to: :extensions, render_nil: false
      end
    end
  end
end

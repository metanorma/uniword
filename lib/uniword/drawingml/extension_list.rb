# frozen_string_literal: true

module Uniword
  module Drawingml
      # Represents an extension list in DrawingML theme
      #
      # Contains a collection of extension elements.
      class ExtensionList < Lutaml::Model::Serializable
        # Collection of extensions
        attribute :extensions, Extension, collection: true

        # OOXML namespace configuration
        xml do
          element 'extLst'
          namespace Ooxml::Namespaces::DrawingML
          map_element 'ext', to: :extensions
        end

        def initialize(attributes = {})
          super
          @extensions ||= []
        end
      end
  end
end

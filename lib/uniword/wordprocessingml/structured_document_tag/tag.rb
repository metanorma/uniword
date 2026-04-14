# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    class StructuredDocumentTag
      # Developer tag for Structured Document Tag (can be empty)
      # Reference XML: <w:tag w:val=""/>
      class Tag < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element 'tag'
          namespace Ooxml::Namespaces::WordProcessingML
          map_attribute 'val', to: :value, render_nil: true, render_empty: true
        end
      end
    end
  end
end

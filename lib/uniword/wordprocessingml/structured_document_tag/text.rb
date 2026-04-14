# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    class StructuredDocumentTag
      # Text control flag for Structured Document Tag (empty element)
      # Reference XML: <w:text/>
      class Text < Lutaml::Model::Serializable
        attribute :multi_line, :string

        xml do
          element 'text'
          namespace Ooxml::Namespaces::WordProcessingML
          map_attribute 'multiLine', to: :multi_line, render_nil: false
        end
      end
    end
  end
end

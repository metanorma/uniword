# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    class StructuredDocumentTag
      # Display name for Structured Document Tag
      # Reference XML: <w:alias w:val="Title"/>
      class Alias < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element 'alias'
          namespace Ooxml::Namespaces::WordProcessingML
          map_attribute 'val', to: :value
        end
      end
    end
  end
end

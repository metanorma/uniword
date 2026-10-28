# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Ooxml
    module Types
      # String type in the schemaLibrary namespace (sl:uri,
      # sl:manifestLocation qualified attributes).
      class SchemaLibraryVal < Lutaml::Model::Type::String
        xml do
          namespace Uniword::Ooxml::Namespaces::SchemaLibrary
        end
      end
    end
  end
end

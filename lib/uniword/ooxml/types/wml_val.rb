# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Ooxml
    module Types
      # String type in the WordProcessingML namespace.
      # Binds mapped attribute rules to their qualified (URI, local)
      # identity — e.g. w:val on boolean/formatting elements — so
      # strict adapters (Leptris) match exactly what DOCX emits.
      class WmlVal < Lutaml::Model::Type::String
        xml do
          namespace Uniword::Ooxml::Namespaces::WordProcessingML
        end
      end
    end
  end
end

# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Ooxml
    module Types
      # Core Properties keywords element type
      # Declares cp: namespace for automatic propagation to XML serialization
      class CpKeywordsType < Lutaml::Model::Type::String
        xml do
          namespace Uniword::Ooxml::Namespaces::CoreProperties
        end
      end
    end
  end
end

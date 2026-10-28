# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Ooxml
    module Types
      # String type in the Additional Characteristics namespace.
      class CharacteristicsVal < Lutaml::Model::Type::String
        xml do
          namespace Uniword::Ooxml::Namespaces::Characteristics
        end
      end
    end
  end
end

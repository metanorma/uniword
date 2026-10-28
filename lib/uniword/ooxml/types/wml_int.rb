# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Ooxml
    module Types
      # Integer type in the WordProcessingML namespace (w:top, w:gutter,
      # w:sz et al. qualified attributes).
      class WmlInt < Lutaml::Model::Type::Integer
        xml do
          namespace Uniword::Ooxml::Namespaces::WordProcessingML
        end
      end
    end
  end
end

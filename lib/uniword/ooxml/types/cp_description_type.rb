# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Ooxml
    module Types
      # Dublin Core description element type
      # Declares dc: namespace for automatic propagation to XML serialization
      class DcDescriptionType < Lutaml::Model::Type::String
        xml do
          namespace Uniword::Ooxml::Namespaces::DublinCore
        end
      end
    end
  end
end

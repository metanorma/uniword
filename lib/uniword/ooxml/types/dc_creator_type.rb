# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Ooxml
    module Types
      # Dublin Core creator element type
      # Declares dc: namespace for automatic propagation to XML serialization
      class DcCreatorType < Lutaml::Model::Type::String
      end
    end
  end
end

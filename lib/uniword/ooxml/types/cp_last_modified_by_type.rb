# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Ooxml
    module Types
      # Core Properties lastModifiedBy element type
      # Declares cp: namespace for automatic propagation to XML serialization
      class CpLastModifiedByType < Lutaml::Model::Type::String
      end
    end
  end
end

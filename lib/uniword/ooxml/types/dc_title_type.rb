# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Ooxml
    module Types
      # Dublin Core title element type
      # Declares dc: namespace for automatic propagation to XML serialization
      class DcTitleType < Lutaml::Model::Type::String
      end
    end
  end
end

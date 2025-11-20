# frozen_string_literal: true

require 'lutaml/model'
require_relative '../namespaces'

module Uniword
  module Ooxml
    module Types
      # Dublin Core creator element type
      # Declares dc: namespace for automatic propagation to XML serialization
      class DcCreatorType < Lutaml::Model::Type::String
        xml_namespace Namespaces::DublinCore
      end
    end
  end
end
# frozen_string_literal: true

require 'lutaml/model'
require_relative '../namespaces'

module Uniword
  module Ooxml
    module Types
      # Core Properties revision element type
      # Declares cp: namespace for automatic propagation to XML serialization
      class CpRevisionType < Lutaml::Model::Type::String
        xml_namespace Namespaces::CoreProperties
      end
    end
  end
end

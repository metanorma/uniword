# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Namespaced custom type for relationship ID value
    # Used for r:id attributes which belong to the Relationships namespace
    class RelationshipIdValue < Lutaml::Model::Type::String
      include Lutaml::Xml::Type::Configurable

      xml do
        namespace Uniword::Ooxml::Namespaces::Relationships
      end
    end
  end
end

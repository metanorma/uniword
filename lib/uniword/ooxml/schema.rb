# frozen_string_literal: true

# OOXML Schema Support Module
#
# Contains classes for working with OOXML schema definitions.
module Uniword
  module Ooxml
    module Schema
      autoload :OoxmlSchema, "#{__dir__}/schema/ooxml_schema"
      autoload :ElementSerializer, "#{__dir__}/schema/element_serializer"
      autoload :ElementDefinition, "#{__dir__}/schema/element_definition"
      autoload :AttributeDefinition, "#{__dir__}/schema/attribute_definition"
      autoload :ChildDefinition, "#{__dir__}/schema/child_definition"
    end
  end
end

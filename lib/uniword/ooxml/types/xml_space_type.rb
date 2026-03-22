# frozen_string_literal: true

require 'lutaml/model'
require_relative '../namespaces'

module Uniword
  module Ooxml
    module Types
      # xml:space attribute type
      # This attribute is in the XML namespace and should NOT have a prefix
      # when serialized in most XML vocabularies (including OOXML)
      class XmlSpace < Lutaml::Model::Type::String
        xml do
          namespace Uniword::Ooxml::Namespaces::XML
        end
      end
    end
  end
end

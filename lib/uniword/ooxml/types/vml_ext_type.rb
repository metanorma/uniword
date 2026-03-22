# frozen_string_literal: true

require 'lutaml/model'
require_relative '../namespaces'

module Uniword
  module Ooxml
    module Types
      # v:ext attribute type
      # This attribute is in the VML namespace and should be serialized with v: prefix
      class VmlExt < Lutaml::Model::Type::String
        xml do
          namespace Uniword::Ooxml::Namespaces::Vml
        end
      end
    end
  end
end

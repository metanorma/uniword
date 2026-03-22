# frozen_string_literal: true

require 'lutaml/model'
require_relative '../namespaces'

module Uniword
  module Ooxml
    module Types
      # mc:Ignorable attribute type
      # This attribute is in the Markup Compatibility namespace and indicates
      # which namespaces should be ignored by processors that don't understand them.
      class McIgnorable < Lutaml::Model::Type::String
        xml do
          namespace Uniword::Ooxml::Namespaces::MarkupCompatibility
        end
      end
    end
  end
end

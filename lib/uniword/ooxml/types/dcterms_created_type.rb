# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Ooxml
    module Types
      # Dublin Core Terms created element type
      class DctermsCreatedType < Lutaml::Model::Serializable
        attribute :value, :string
        attribute :type, :string

        xml do
          element 'created'
          namespace Ooxml::Namespaces::DublinCoreTerms

          map_content to: :value
          map_attribute 'type', to: :type, namespace: 'http://www.w3.org/2001/XMLSchema-instance', prefix: 'xsi'
        end
      end
    end
  end
end

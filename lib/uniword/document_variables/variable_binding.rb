# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module DocumentVariables
    # Variable binding configuration for data sources
    #
    # Generated from OOXML schema: document_variables.yml
    # Element: <dv:variable_binding>
    class VariableBinding < Lutaml::Model::Serializable
      attribute :xpath, :string
      attribute :store_item_id, :string
      attribute :prefix_mappings, :string

      xml do
        element 'variable_binding'
        namespace Uniword::Ooxml::Namespaces::DocumentVariables

        map_attribute 'xpath', to: :xpath
        map_attribute 'storeItemID', to: :store_item_id
        map_attribute 'prefixMappings', to: :prefix_mappings
      end
    end
  end
end

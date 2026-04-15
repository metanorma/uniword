# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module DocumentVariables
    # Data type specification for variables
    #
    # Generated from OOXML schema: document_variables.yml
    # Element: <dv:data_type>
    class DataType < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "data_type"
        namespace Uniword::Ooxml::Namespaces::DocumentVariables

        map_attribute "val", to: :val
      end
    end
  end
end

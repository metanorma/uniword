# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # External Reference
    #
    # Complex type for a single external reference.
    class ExternalReference < Lutaml::Model::Serializable
      attribute :id, :string

      xml do
        element "externalReference"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute "id", to: :id
      end
    end
  end
end

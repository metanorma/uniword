# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Cell Style XFS (Cell Format Extensions)
    #
    # Complex type for cell style formatting definitions.
    class CellStyleXfs < Lutaml::Model::Serializable
      attribute :count, :integer
      attribute :xf, CellFormat, collection: true, initialize_empty: true

      xml do
        element 'cellStyleXfs'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute 'count', to: :count, render_nil: false
        map_element 'xf', to: :xf, render_nil: false
      end
    end
  end
end

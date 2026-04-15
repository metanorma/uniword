# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Merged cells collection
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:mergeCells>
    class MergeCells < Lutaml::Model::Serializable
      attribute :count, :integer
      attribute :cells, MergeCell, collection: true, initialize_empty: true

      xml do
        element "mergeCells"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_attribute "count", to: :count
        map_element "mergeCell", to: :cells, render_nil: false
      end
    end
  end
end

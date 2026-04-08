# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Table Styles
    #
    # Complex type for a collection of table styles.
    class TableStyles < Lutaml::Model::Serializable
      attribute :count, :integer
      attribute :table_style, TableStyleInfo, collection: true, initialize_empty: true

      xml do
        element 'tableStyles'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute 'count', to: :count, render_nil: false
        map_element 'tableStyle', to: :table_style, render_nil: false
      end
    end
  end
end

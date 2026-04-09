# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Shared string table
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:sst>
    class SharedStringTable < Lutaml::Model::Serializable
      attribute :count, :integer
      attribute :unique_count, :integer
      attribute :si_entries, :stringItem, collection: true, initialize_empty: true

      xml do
        element 'sst'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_attribute 'count', to: :count
        map_attribute 'unique-count', to: :unique_count
        map_element 'si', to: :si_entries, render_nil: false
      end
    end
  end
end

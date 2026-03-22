# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Column page breaks
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:colBreaks>
    class ColBreaks < Lutaml::Model::Serializable
      attribute :count, :integer
      attribute :breaks, :string, collection: true, initialize_empty: true

      xml do
        element 'colBreaks'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_attribute 'count', to: :count
        map_element 'brk', to: :breaks, render_nil: false
      end
    end
  end
end

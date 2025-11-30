# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Number formats collection
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:numFmts>
    class NumberFormats < Lutaml::Model::Serializable
      attribute :count, Integer
      attribute :formats, NumberFormat, collection: true, default: -> { [] }

      xml do
        element 'numFmts'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_attribute 'count', to: :count
        map_element 'numFmt', to: :formats, render_nil: false
      end
    end
  end
end

# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Auto filter settings
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:autoFilter>
    class AutoFilter < Lutaml::Model::Serializable
      attribute :ref, :string
      attribute :filter_columns, :string, collection: true, default: -> { [] }

      xml do
        element 'autoFilter'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_attribute 'ref', to: :ref
        map_element 'filterColumn', to: :filter_columns, render_nil: false
      end
    end
  end
end

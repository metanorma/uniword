# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Named ranges collection
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:definedNames>
    class DefinedNames < Lutaml::Model::Serializable
      attribute :names, DefinedName, collection: true, default: -> { [] }

      xml do
        element 'definedNames'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_element 'definedName', to: :names, render_nil: false
      end
    end
  end
end

# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Named ranges collection
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:definedNames>
      class DefinedNames < Lutaml::Model::Serializable
          attribute :names, DefinedName, collection: true, default: -> { [] }

          xml do
            root 'definedNames'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_element 'definedName', to: :names, render_nil: false
          end
      end
    end
  end
end

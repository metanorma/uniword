# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Protected ranges collection
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:protectedRanges>
      class ProtectedRanges < Lutaml::Model::Serializable
          attribute :ranges, String, collection: true, default: -> { [] }

          xml do
            root 'protectedRanges'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_element 'protectedRange', to: :ranges, render_nil: false
          end
      end
    end
  end
end

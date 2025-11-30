# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Protected ranges collection
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:protectedRanges>
    class ProtectedRanges < Lutaml::Model::Serializable
      attribute :ranges, :string, collection: true, default: -> { [] }

      xml do
        element 'protectedRanges'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_element 'protectedRange', to: :ranges, render_nil: false
      end
    end
  end
end

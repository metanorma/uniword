# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Font name
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:name>
    class FontName < Lutaml::Model::Serializable
      attribute :val, String

      xml do
        element 'name'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute 'val', to: :val
      end
    end
  end
end

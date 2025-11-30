# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Font size
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:sz>
    class FontSize < Lutaml::Model::Serializable
      attribute :val, String

      xml do
        element 'sz'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute 'val', to: :val
      end
    end
  end
end

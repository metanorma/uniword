# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Hyperlink definition
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:hyperlink>
    class Hyperlink < Lutaml::Model::Serializable
      attribute :ref, String
      attribute :id, String
      attribute :location, String
      attribute :tooltip, String
      attribute :display, String

      xml do
        element 'hyperlink'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute 'ref', to: :ref
        map_attribute 'id', to: :id
        map_attribute 'location', to: :location
        map_attribute 'tooltip', to: :tooltip
        map_attribute 'display', to: :display
      end
    end
  end
end

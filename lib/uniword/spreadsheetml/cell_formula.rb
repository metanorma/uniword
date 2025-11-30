# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Cell formula element
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:f>
    class CellFormula < Lutaml::Model::Serializable
      attribute :t, String
      attribute :ref, String
      attribute :si, Integer
      attribute :text, String

      xml do
        element 'f'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute 't', to: :t
        map_attribute 'ref', to: :ref
        map_attribute 'si', to: :si
        map_element '', to: :text, render_nil: false
      end
    end
  end
end

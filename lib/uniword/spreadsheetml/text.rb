# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Spreadsheetml
      # Text element
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:t>
      class Text < Lutaml::Model::Serializable
          attribute :text, String
          attribute :space, String

          xml do
            element 't'
            namespace Uniword::Ooxml::Namespaces::SpreadsheetML

            map_element '', to: :text, render_nil: false
            map_attribute 'space', to: :space
          end
      end
    end
end

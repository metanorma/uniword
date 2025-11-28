# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Text element
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:t>
      class Text < Lutaml::Model::Serializable
          attribute :text, String
          attribute :space, String

          xml do
            root 't'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_element '', to: :text, render_nil: false
            map_attribute 'true', to: :space
          end
      end
    end
  end
end

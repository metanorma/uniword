# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Hyperlinks collection
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:hyperlinks>
      class Hyperlinks < Lutaml::Model::Serializable
          attribute :links, Hyperlink, collection: true, default: -> { [] }

          xml do
            root 'hyperlinks'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_element 'hyperlink', to: :links, render_nil: false
          end
      end
    end
  end
end

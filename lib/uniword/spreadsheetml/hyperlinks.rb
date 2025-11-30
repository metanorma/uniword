# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Hyperlinks collection
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:hyperlinks>
    class Hyperlinks < Lutaml::Model::Serializable
      attribute :links, Hyperlink, collection: true, default: -> { [] }

      xml do
        element 'hyperlinks'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_element 'hyperlink', to: :links, render_nil: false
      end
    end
  end
end

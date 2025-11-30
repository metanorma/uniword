# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Comment authors list
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:authors>
    class Authors < Lutaml::Model::Serializable
      attribute :author_entries, String, collection: true, default: -> { [] }

      xml do
        element 'authors'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_element 'author', to: :author_entries, render_nil: false
      end
    end
  end
end

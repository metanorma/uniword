# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Comment authors list
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:authors>
      class Authors < Lutaml::Model::Serializable
          attribute :author_entries, String, collection: true, default: -> { [] }

          xml do
            root 'authors'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_element 'author', to: :author_entries, render_nil: false
          end
      end
    end
  end
end

# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Spreadsheetml
      # Cell comment
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:comment>
      class Comment < Lutaml::Model::Serializable
          attribute :ref, String
          attribute :author_id, Integer
          attribute :text, String

          xml do
            element 'comment'
            namespace Uniword::Ooxml::Namespaces::SpreadsheetML
            mixed_content

            map_attribute 'ref', to: :ref
            map_attribute 'author-id', to: :author_id
            map_element 'text', to: :text, render_nil: false
          end
      end
    end
end

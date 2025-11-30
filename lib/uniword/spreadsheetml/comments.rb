# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Spreadsheetml
      # Comments collection
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:comments>
      class Comments < Lutaml::Model::Serializable
          attribute :authors, Authors
          attribute :comment_list, CommentList

          xml do
            element 'comments'
            namespace Uniword::Ooxml::Namespaces::SpreadsheetML
            mixed_content

            map_element 'authors', to: :authors
            map_element 'commentList', to: :comment_list
          end
      end
    end
end

# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Comments collection
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:comments>
      class Comments < Lutaml::Model::Serializable
          attribute :authors, Authors
          attribute :comment_list, CommentList

          xml do
            root 'comments'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_element 'authors', to: :authors
            map_element 'commentList', to: :comment_list
          end
      end
    end
  end
end

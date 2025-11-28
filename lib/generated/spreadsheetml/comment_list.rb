# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # List of comments
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:commentList>
      class CommentList < Lutaml::Model::Serializable
          attribute :comment_entries, Comment, collection: true, default: -> { [] }

          xml do
            root 'commentList'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_element 'comment', to: :comment_entries, render_nil: false
          end
      end
    end
  end
end

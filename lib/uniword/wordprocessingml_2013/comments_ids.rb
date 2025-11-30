# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml2013
      # Collection of comment IDs
      #
      # Generated from OOXML schema: wordprocessingml_2013.yml
      # Element: <w15:commentsIds>
      class CommentsIds < Lutaml::Model::Serializable
          attribute :comment_id, String, collection: true, default: -> { [] }

          xml do
            element 'commentsIds'
            namespace Uniword::Ooxml::Namespaces::Word2012
            mixed_content

            map_element 'commentId', to: :comment_id, render_nil: false
          end
      end
    end
end

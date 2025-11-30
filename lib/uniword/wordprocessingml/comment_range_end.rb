# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Comment range end marker
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:commentRangeEnd>
      class CommentRangeEnd < Lutaml::Model::Serializable
          attribute :id, :string

          xml do
            element 'commentRangeEnd'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML

            map_attribute 'id', to: :id
          end
      end
    end
end

# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Comment reference marker
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:commentReference>
      class CommentReference < Lutaml::Model::Serializable
          attribute :id, :string

          xml do
            element 'commentReference'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML

            map_attribute 'id', to: :id
          end
      end
    end
end

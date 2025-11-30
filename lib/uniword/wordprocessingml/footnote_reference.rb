# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Footnote reference marker
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:footnoteReference>
      class FootnoteReference < Lutaml::Model::Serializable
          attribute :id, :string

          xml do
            element 'footnoteReference'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML

            map_attribute 'id', to: :id
          end
      end
    end
end

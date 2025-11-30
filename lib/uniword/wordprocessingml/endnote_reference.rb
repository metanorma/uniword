# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Endnote reference marker
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:endnoteReference>
      class EndnoteReference < Lutaml::Model::Serializable
          attribute :id, :string

          xml do
            element 'endnoteReference'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML

            map_attribute 'id', to: :id
          end
      end
    end
end

# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Drawing object non-visual properties
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:docPr>
      class DocPr < Lutaml::Model::Serializable
          attribute :id, :integer
          attribute :name, :string
          attribute :descr, :string

          xml do
            element 'docPr'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML

            map_attribute 'id', to: :id
            map_attribute 'name', to: :name
            map_attribute 'descr', to: :descr
          end
      end
    end
end

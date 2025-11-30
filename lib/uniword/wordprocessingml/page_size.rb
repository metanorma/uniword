# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Page dimensions
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:pgSz>
      class PageSize < Lutaml::Model::Serializable
          attribute :width, :integer
          attribute :height, :integer
          attribute :orientation, :string

          xml do
            element 'pgSz'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML

            map_attribute 'width', to: :width
            map_attribute 'height', to: :height
            map_attribute 'orientation', to: :orientation
          end
      end
    end
end

# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Page margin settings
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:pgMar>
      class PageMargins < Lutaml::Model::Serializable
          attribute :top, :integer
          attribute :bottom, :integer
          attribute :left, :integer
          attribute :right, :integer
          attribute :header, :integer
          attribute :footer, :integer
          attribute :gutter, :integer

          xml do
            element 'pgMar'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML

            map_attribute 'top', to: :top
            map_attribute 'bottom', to: :bottom
            map_attribute 'left', to: :left
            map_attribute 'right', to: :right
            map_attribute 'header', to: :header
            map_attribute 'footer', to: :footer
            map_attribute 'gutter', to: :gutter
          end
      end
    end
end

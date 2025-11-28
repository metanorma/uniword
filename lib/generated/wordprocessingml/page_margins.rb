# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
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
            root 'pgMar'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :top
            map_attribute 'true', to: :bottom
            map_attribute 'true', to: :left
            map_attribute 'true', to: :right
            map_attribute 'true', to: :header
            map_attribute 'true', to: :footer
            map_attribute 'true', to: :gutter
          end
      end
    end
  end
end

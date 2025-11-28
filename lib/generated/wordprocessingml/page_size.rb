# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
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
            root 'pgSz'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :width
            map_attribute 'true', to: :height
            map_attribute 'true', to: :orientation
          end
      end
    end
  end
end

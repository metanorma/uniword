# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Presentationml
      # Color scheme mapping for theme colors
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:color_map>
      class ColorMap < Lutaml::Model::Serializable
          attribute :bg1, :string
          attribute :tx1, :string
          attribute :bg2, :string
          attribute :tx2, :string

          xml do
            root 'color_map'
            namespace 'http://schemas.openxmlformats.org/presentationml/2006/main', 'p'

            map_attribute 'bg1', to: :bg1
            map_attribute 'tx1', to: :tx1
            map_attribute 'bg2', to: :bg2
            map_attribute 'tx2', to: :tx2
          end
      end
    end
  end
end

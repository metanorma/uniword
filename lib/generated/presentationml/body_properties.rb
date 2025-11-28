# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Presentationml
      # Properties for text body container
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:body_pr>
      class BodyProperties < Lutaml::Model::Serializable
          attribute :rot, :integer
          attribute :vert, :string
          attribute :anchor, :string
          attribute :anchor_ctr, :string
          attribute :wrap, :string

          xml do
            root 'body_pr'
            namespace 'http://schemas.openxmlformats.org/presentationml/2006/main', 'p'

            map_attribute 'rot', to: :rot
            map_attribute 'vert', to: :vert
            map_attribute 'anchor', to: :anchor
            map_attribute 'anchorCtr', to: :anchor_ctr
            map_attribute 'wrap', to: :wrap
          end
      end
    end
  end
end

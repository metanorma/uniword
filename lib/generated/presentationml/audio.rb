# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Presentationml
      # Audio element embedded in presentation
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:audio>
      class Audio < Lutaml::Model::Serializable
          attribute :embed, :string
          attribute :link, :string
          attribute :is_narration, :string

          xml do
            root 'audio'
            namespace 'http://schemas.openxmlformats.org/presentationml/2006/main', 'p'

            map_attribute 'embed', to: :embed
            map_attribute 'link', to: :link
            map_attribute 'isNarration', to: :is_narration
          end
      end
    end
  end
end

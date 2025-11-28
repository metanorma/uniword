# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Presentationml
      # Video element embedded in presentation
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:video>
      class Video < Lutaml::Model::Serializable
          attribute :embed, :string
          attribute :link, :string

          xml do
            root 'video'
            namespace 'http://schemas.openxmlformats.org/presentationml/2006/main', 'p'

            map_attribute 'embed', to: :embed
            map_attribute 'link', to: :link
          end
      end
    end
  end
end

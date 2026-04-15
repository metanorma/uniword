# frozen_string_literal: true

require "lutaml/model"

module Uniword
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
        element "audio"
        namespace Uniword::Ooxml::Namespaces::PresentationalML

        map_attribute "embed", to: :embed
        map_attribute "link", to: :link
        map_attribute "isNarration", to: :is_narration
      end
    end
  end
end

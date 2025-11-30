# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Binary Large Image or Picture reference
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:blip>
    class Blip < Lutaml::Model::Serializable
      attribute :embed, :string
      attribute :link, :string

      xml do
        element 'blip'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'embed', to: :embed
        map_attribute 'link', to: :link
      end
    end
  end
end

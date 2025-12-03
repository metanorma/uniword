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
      attribute :duotone, Duotone

      xml do
        element 'blip'
        namespace Uniword::Ooxml::Namespaces::DrawingML
        mixed_content

        map_attribute 'embed', to: :embed,
                      namespace: Uniword::Ooxml::Namespaces::Relationships,
                      render_nil: false
        map_attribute 'link', to: :link,
                      namespace: Uniword::Ooxml::Namespaces::Relationships,
                      render_nil: false
        map_element 'duotone', to: :duotone, render_nil: false
      end
    end
  end
end

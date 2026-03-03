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

        # r:embed and r:link attributes from Relationships namespace
        # Note: namespace handled by attribute name prefix in new lutaml-model
        map_attribute 'embed', to: :embed,
                               render_nil: false
        map_attribute 'link', to: :link,
                              render_nil: false
        map_element 'duotone', to: :duotone, render_nil: false
      end
    end
  end
end

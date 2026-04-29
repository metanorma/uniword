# frozen_string_literal: true

require "lutaml/model"
require "uniword/ooxml/types/relationship_id"

module Uniword
  module Drawingml
    # Binary Large Image or Picture reference
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:blip>
    class Blip < Lutaml::Model::Serializable
      attribute :embed, Ooxml::Types::RelationshipId
      attribute :link, Ooxml::Types::RelationshipId
      attribute :duotone, Duotone
      attribute :ext_lst, OfficeArtExtensionList

      xml do
        element "blip"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        # r:embed and r:link use Relationships namespace via RelationshipId type
        map_attribute "embed", to: :embed,
                               render_nil: false
        map_attribute "link", to: :link,
                              render_nil: false
        map_element "duotone", to: :duotone, render_nil: false
        map_element "extLst", to: :ext_lst, render_nil: false
      end
    end
  end
end

# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module VmlOffice
    # Ink annotation properties for VML
    #
    # Generated from OOXML schema: vml_office.yml
    # Element: <o:ink>
    class VmlInk < Lutaml::Model::Serializable
      attribute :i, String
      attribute :annotation, String
      attribute :contentType, String

      xml do
        element 'ink'
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute 'i', to: :i
        map_attribute 'annotation', to: :annotation
        map_attribute 'contentType', to: :contentType
      end
    end
  end
end

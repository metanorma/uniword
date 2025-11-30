# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Office
    # Ink annotation
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:ink>
    class Ink < Lutaml::Model::Serializable
      attribute :i, :string
      attribute :contentType, :string

      xml do
        element 'ink'
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute 'i', to: :i
        map_attribute 'contentType', to: :contentType
      end
    end
  end
end

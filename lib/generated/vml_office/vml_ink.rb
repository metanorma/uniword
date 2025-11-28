# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
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
            root 'ink'
            namespace 'urn:schemas-microsoft-com:vml', 'o'

            map_attribute 'true', to: :i
            map_attribute 'true', to: :annotation
            map_attribute 'true', to: :contentType
          end
      end
    end
  end
end

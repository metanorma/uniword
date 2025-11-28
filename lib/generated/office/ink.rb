# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Ink annotation
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:ink>
      class Ink < Lutaml::Model::Serializable
          attribute :i, String
          attribute :contentType, String

          xml do
            root 'ink'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :i
            map_attribute 'true', to: :contentType
          end
      end
    end
  end
end

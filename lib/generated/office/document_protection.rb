# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Document protection settings
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:DocumentProtection>
      class DocumentProtection < Lutaml::Model::Serializable
          attribute :edit, String
          attribute :formatting, String
          attribute :enforcement, String

          xml do
            root 'DocumentProtection'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :edit
            map_attribute 'true', to: :formatting
            map_attribute 'true', to: :enforcement
          end
      end
    end
  end
end

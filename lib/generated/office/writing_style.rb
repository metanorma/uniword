# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Writing style settings
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:writingstyle>
      class WritingStyle < Lutaml::Model::Serializable
          attribute :lang, String
          attribute :vendorID, String
          attribute :dllVersion, String
          attribute :nlcheck, String

          xml do
            root 'writingstyle'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :lang
            map_attribute 'true', to: :vendorID
            map_attribute 'true', to: :dllVersion
            map_attribute 'true', to: :nlcheck
          end
      end
    end
  end
end

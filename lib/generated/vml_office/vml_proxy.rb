# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module VmlOffice
      # Proxy element for referencing
      #
      # Generated from OOXML schema: vml_office.yml
      # Element: <o:proxy>
      class VmlProxy < Lutaml::Model::Serializable
          attribute :start, String
          attribute :end, String
          attribute :idref, String
          attribute :connectloc, String

          xml do
            root 'proxy'
            namespace 'urn:schemas-microsoft-com:vml', 'o'

            map_attribute 'true', to: :start
            map_attribute 'true', to: :end
            map_attribute 'true', to: :idref
            map_attribute 'true', to: :connectloc
          end
      end
    end
  end
end

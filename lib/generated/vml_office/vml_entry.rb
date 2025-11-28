# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module VmlOffice
      # Entry point for VML diagram
      #
      # Generated from OOXML schema: vml_office.yml
      # Element: <o:entry>
      class VmlEntry < Lutaml::Model::Serializable
          attribute :new, String
          attribute :old, String

          xml do
            root 'entry'
            namespace 'urn:schemas-microsoft-com:vml', 'o'

            map_attribute 'true', to: :new
            map_attribute 'true', to: :old
          end
      end
    end
  end
end

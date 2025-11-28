# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Form settings
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:forms>
      class Forms < Lutaml::Model::Serializable
          attribute :checked, String

          xml do
            root 'forms'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :checked
          end
      end
    end
  end
end

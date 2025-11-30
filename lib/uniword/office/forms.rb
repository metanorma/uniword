# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Office
      # Form settings
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:forms>
      class Forms < Lutaml::Model::Serializable
          attribute :checked, String

          xml do
            element 'forms'
            namespace Uniword::Ooxml::Namespaces::Office

            map_attribute 'checked', to: :checked
          end
      end
    end
end

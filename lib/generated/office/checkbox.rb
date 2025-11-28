# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Checkbox control
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:checkbox>
      class Checkbox < Lutaml::Model::Serializable
          attribute :checked, String
          attribute :value, String

          xml do
            root 'checkbox'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :checked
            map_attribute 'true', to: :value
          end
      end
    end
  end
end
